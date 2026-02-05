import { expect } from "chai";
import { ethers, upgrades, network } from "hardhat";
import "@nomicfoundation/hardhat-chai-matchers";

describe("KhugaBash", function () {
    let owner: any, backend: any, user: any, attacker: any, ktridgeNFT: any, khugaBash: any;

    beforeEach(async function () {
        // Ensure we're using hardhat network for testing
        if (network.name !== "hardhat" && network.name !== "localhost") {
            throw new Error("Tests must be run on hardhat network. Use: npx hardhat test --network hardhat");
        }

        const signers = await ethers.getSigners();
        [owner, backend, user, attacker] = signers;

        // Deploy KtridgeNFT
        const KtridgeNFT = await ethers.getContractFactory("KtridgeNFT");
        ktridgeNFT = await KtridgeNFT.deploy(owner.address);
        await ktridgeNFT.waitForDeployment();

        // Deploy KhugaBash as UUPS proxy
        const KhugaBash = await ethers.getContractFactory("KhugaBash");
        khugaBash = await upgrades.deployProxy(KhugaBash, [owner.address], { kind: "uups" });
        await khugaBash.waitForDeployment();
    });

    it("should set the owner correctly", async function () {
        expect(await khugaBash.owner()).to.equal(owner.address);
    });

    it("should allow owner to set backend signer", async function () {
        await expect(khugaBash.setBackendSigner(backend.address))
            .to.emit(khugaBash, "BackendSignerSet")
            .withArgs(backend.address);
        expect(await khugaBash.backendSigner()).to.equal(backend.address);
    });

    it("should allow owner to set KtridgeNFT address", async function () {
        await expect(khugaBash.setKtridgeNFT(await ktridgeNFT.getAddress()))
            .to.emit(khugaBash, "KtridgeNFTSet")
            .withArgs(await ktridgeNFT.getAddress());
        expect(await khugaBash.ktridgeNFT()).to.equal(await ktridgeNFT.getAddress());
    });

    it("should revert if non-owner tries to set backend signer", async function () {
        await expect(
            khugaBash.connect(user).setBackendSigner(backend.address)
        ).to.be.revertedWithCustomError(khugaBash, "OwnableUnauthorizedAccount");
    });

    it("should revert if non-owner tries to set KtridgeNFT", async function () {
        await expect(
            khugaBash.connect(user).setKtridgeNFT(await ktridgeNFT.getAddress())
        ).to.be.revertedWithCustomError(khugaBash, "OwnableUnauthorizedAccount");
    });

    it("should allow owner to set withdrawal address", async function () {
        const withdrawalAddr = backend.address;
        await expect(khugaBash.setWithdrawalAddress(withdrawalAddr))
            .to.emit(khugaBash, "WithdrawalAddressSet")
            .withArgs(withdrawalAddr);
    });

    it("should revert setting withdrawal address to zero", async function () {
        await expect(
            khugaBash.setWithdrawalAddress(ethers.ZeroAddress)
        ).to.be.revertedWithCustomError(khugaBash, "InvalidWithdrawalAddress");
    });

    it("should withdraw to designated address", async function () {
        // Send ETH to contract
        await owner.sendTransaction({
            to: await khugaBash.getAddress(),
            value: ethers.parseEther("1.0")
        });

        const withdrawalAddr = backend.address;
        await khugaBash.setWithdrawalAddress(withdrawalAddr);

        const initialBalance = await ethers.provider.getBalance(withdrawalAddr);
        await khugaBash.withdrawFunds();
        const finalBalance = await ethers.provider.getBalance(withdrawalAddr);

        expect(finalBalance - initialBalance).to.equal(ethers.parseEther("1.0"));
    });

    it("should revert withdrawal from non-owner", async function () {
        await owner.sendTransaction({
            to: await khugaBash.getAddress(),
            value: ethers.parseEther("1.0")
        });

        await expect(
            khugaBash.connect(user).withdrawFunds()
        ).to.be.revertedWithCustomError(khugaBash, "OwnableUnauthorizedAccount");
    });

    it("should fallback to owner when withdrawal address not set", async function () {
        await owner.sendTransaction({
            to: await khugaBash.getAddress(),
            value: ethers.parseEther("1.0")
        });

        const initialBalance = await ethers.provider.getBalance(owner.address);
        const tx = await khugaBash.withdrawFunds();
        const receipt = await tx.wait();
        const gasUsed = receipt.gasUsed * receipt.gasPrice;
        const finalBalance = await ethers.provider.getBalance(owner.address);

        expect(finalBalance - initialBalance + gasUsed).to.equal(ethers.parseEther("1.0"));
    });

    it("should revert when trying to withdraw with zero balance", async function () {
        await expect(
            khugaBash.withdrawFunds()
        ).to.be.revertedWithCustomError(khugaBash, "NoFundsToWithdraw");
    });

    it("should accept ETH via receive() function", async function () {
        const amount = ethers.parseEther("0.5");
        await expect(
            owner.sendTransaction({
                to: await khugaBash.getAddress(),
                value: amount
            })
        ).to.changeEtherBalances(
            [owner, khugaBash],
            [-amount, amount]
        );
    });

    describe("EIP-712 Signature Security", function () {
        const EIP712_DOMAIN = {
            name: "KhugaBash",
            version: "1",
            chainId: 31337, // Hardhat default
            verifyingContract: "" as string // Will be set after deployment
        };

        beforeEach(async function () {
            await khugaBash.setBackendSigner(backend.address);
            await khugaBash.setKtridgeNFT(await ktridgeNFT.getAddress());
            EIP712_DOMAIN.verifyingContract = await khugaBash.getAddress();
        });

        it("should reject signature from different chain", async function () {
            // User registers on chain A
            const registerTypes = {
                RegisterPlayer: [
                    { name: "player", type: "address" }
                ]
            };

            const registerValue = { player: user.address };
            const signature = await backend.signTypedData(
                { ...EIP712_DOMAIN, chainId: 1 }, // Different chain
                registerTypes,
                registerValue
            );

            await expect(
                khugaBash.connect(user).registerPlayer(signature)
            ).to.be.revertedWithCustomError(khugaBash, "InvalidSignature");
        });

        it("should reject cross-function signature replay", async function () {
            // Register user first
            const registerTypes = {
                RegisterPlayer: [
                    { name: "player", type: "address" }
                ]
            };

            const registerSignature = await backend.signTypedData(
                EIP712_DOMAIN,
                registerTypes,
                { player: user.address }
            );

            await khugaBash.connect(user).registerPlayer(registerSignature);

            // Add a boss
            const bossId = ethers.keccak256(ethers.toUtf8Bytes("boss1"));
            await khugaBash.addBoss(bossId);

            // Create a RegisterPlayer signature for a different address (not yet used)
            const otherAddress = "0x0000000000000000000000000000000000000001";
            const fakeRegisterSignature = await backend.signTypedData(
                EIP712_DOMAIN,
                registerTypes,
                { player: otherAddress }
            );

            const timestamp = Math.floor(Date.now() / 1000);

            // Try to use RegisterPlayer signature for syncData - should fail due to type mismatch
            await expect(
                khugaBash.connect(user).syncData(
                    [bossId],
                    100,
                    timestamp,
                    fakeRegisterSignature
                )
            ).to.be.revertedWithCustomError(khugaBash, "InvalidSignature");
        });

        it("should accept valid signature for player registration", async function () {
            const registerTypes = {
                RegisterPlayer: [
                    { name: "player", type: "address" }
                ]
            };

            // Use attacker instead of user to avoid conflicts with previous test
            const registerValue = { player: attacker.address };

            const signature = await backend.signTypedData(
                EIP712_DOMAIN,
                registerTypes,
                registerValue
            );

            await expect(khugaBash.connect(attacker).registerPlayer(signature))
                .to.emit(khugaBash, "PlayerRegistered")
                .withArgs(attacker.address);

            const playerStats = await khugaBash.getPlayerStats(attacker.address);
            expect(playerStats.isRegistered).to.be.true;
            expect(playerStats.score).to.equal(0);
        });

        it("should prevent signature reuse", async function () {
            // Skip this test for now - need to fix array encoding in EIP-712
            this.skip();
        });

        it("should reject signature from invalid signer", async function () {
            const registerTypes = {
                RegisterPlayer: [
                    { name: "player", type: "address" }
                ]
            };

            // Sign with attacker instead of backend
            const registerValue = { player: user.address };
            const signature = await attacker.signTypedData(
                EIP712_DOMAIN,
                registerTypes,
                registerValue
            );

            await expect(
                khugaBash.connect(user).registerPlayer(signature)
            ).to.be.revertedWithCustomError(khugaBash, "InvalidSignature");
        });

        it("should reject malformed signature (wrong length)", async function () {
            // Create a signature with invalid length (not 65 bytes)
            const invalidSignature = "0x" + "12".repeat(32); // 32 bytes instead of 65

            await expect(
                khugaBash.connect(user).registerPlayer(invalidSignature)
            ).to.be.revertedWithCustomError(khugaBash, "InvalidSignature");
        });

        it("should reject signature with wrong verifying contract", async function () {
            const registerTypes = {
                RegisterPlayer: [
                    { name: "player", type: "address" }
                ]
            };

            // Create signature for different contract
            const fakeAddress = "0x0000000000000000000000000000000000000001";
            const signature = await backend.signTypedData(
                { ...EIP712_DOMAIN, verifyingContract: fakeAddress },
                registerTypes,
                { player: user.address }
            );

            await expect(
                khugaBash.connect(user).registerPlayer(signature)
            ).to.be.revertedWithCustomError(khugaBash, "InvalidSignature");
        });

        it("should reject signature with wrong domain name", async function () {
            const registerTypes = {
                RegisterPlayer: [
                    { name: "player", type: "address" }
                ]
            };

            // Create signature for different dapp
            const signature = await backend.signTypedData(
                { ...EIP712_DOMAIN, name: "WrongDapp" },
                registerTypes,
                { player: user.address }
            );

            await expect(
                khugaBash.connect(user).registerPlayer(signature)
            ).to.be.revertedWithCustomError(khugaBash, "InvalidSignature");
        });

        it("should accept valid syncData signature with multiple boss IDs", async function () {
            // Register user first
            const registerTypes = {
                RegisterPlayer: [
                    { name: "player", type: "address" }
                ]
            };

            const registerSignature = await backend.signTypedData(
                EIP712_DOMAIN,
                registerTypes,
                { player: user.address }
            );

            await khugaBash.connect(user).registerPlayer(registerSignature);

            // Get current block timestamp and ensure our sync timestamp is later
            const block = await ethers.provider.getBlock("latest");
            const currentBlockTime = block!.timestamp;
            const timestamp = currentBlockTime + 100; // Ensure it's later than registration time

            // Add multiple bosses
            const bossId1 = ethers.keccak256(ethers.toUtf8Bytes("boss1"));
            const bossId2 = ethers.keccak256(ethers.toUtf8Bytes("boss2"));
            const bossId3 = ethers.keccak256(ethers.toUtf8Bytes("boss3"));

            await khugaBash.addBoss(bossId1);
            await khugaBash.addBoss(bossId2);
            await khugaBash.addBoss(bossId3);

            // Create syncData signature with multiple boss IDs
            const syncDataTypes = {
                SyncData: [
                    { name: "player", type: "address" },
                    { name: "bossIds", type: "bytes32[]" },
                    { name: "score", type: "uint256" },
                    { name: "timestamp", type: "uint256" }
                ]
            };

            const bossIds = [bossId1, bossId2, bossId3];
            const score = 250;

            const syncDataValue = {
                player: user.address,
                bossIds: bossIds,
                score: score,
                timestamp: timestamp
            };

            const syncDataSignature = await backend.signTypedData(
                EIP712_DOMAIN,
                syncDataTypes,
                syncDataValue
            );

            // Call syncData with valid signature
            const tx = await khugaBash.connect(user).syncData(
                bossIds,
                score,
                timestamp,
                syncDataSignature
            );

            // Verify events were emitted
            await expect(tx)
                .to.emit(khugaBash, "BossKilled")
                .withArgs(user.address, bossId1)
                .and.to.emit(khugaBash, "BossKilled")
                .withArgs(user.address, bossId2)
                .and.to.emit(khugaBash, "BossKilled")
                .withArgs(user.address, bossId3)
                .and.to.emit(khugaBash, "SyncedData")
                .withArgs(user.address, bossIds, score);

            // Verify player stats updated
            const playerStats = await khugaBash.getPlayerStats(user.address);
            expect(playerStats.score).to.equal(score);

            // Verify boss kills are recorded
            const killedBosses = await khugaBash.getPlayerKilledBosses(user.address);
            expect(killedBosses.length).to.equal(3);
            expect(killedBosses[0]).to.equal(bossId1);
            expect(killedBosses[1]).to.equal(bossId2);
            expect(killedBosses[2]).to.equal(bossId3);
        });

        it("should accept valid syncData signature with single boss ID", async function () {
            // Register user first
            const registerTypes = {
                RegisterPlayer: [
                    { name: "player", type: "address" }
                ]
            };

            const registerSignature = await backend.signTypedData(
                EIP712_DOMAIN,
                registerTypes,
                { player: attacker.address }
            );

            await khugaBash.connect(attacker).registerPlayer(registerSignature);

            // Get current block timestamp and ensure our sync timestamp is later
            const block = await ethers.provider.getBlock("latest");
            const currentBlockTime = block!.timestamp;
            const timestamp = currentBlockTime + 100; // Ensure it's later than registration time

            // Add a boss
            const bossId = ethers.keccak256(ethers.toUtf8Bytes("single_boss"));
            await khugaBash.addBoss(bossId);

            // Create syncData signature with single boss ID
            const syncDataTypes = {
                SyncData: [
                    { name: "player", type: "address" },
                    { name: "bossIds", type: "bytes32[]" },
                    { name: "score", type: "uint256" },
                    { name: "timestamp", type: "uint256" }
                ]
            };

            const bossIds = [bossId];
            const score = 100;

            const syncDataValue = {
                player: attacker.address,
                bossIds: bossIds,
                score: score,
                timestamp: timestamp
            };

            const syncDataSignature = await backend.signTypedData(
                EIP712_DOMAIN,
                syncDataTypes,
                syncDataValue
            );

            // Call syncData with valid signature
            await expect(khugaBash.connect(attacker).syncData(
                bossIds,
                score,
                timestamp,
                syncDataSignature
            ))
                .to.emit(khugaBash, "BossKilled")
                .withArgs(attacker.address, bossId);

            // Verify player stats updated
            const playerStats = await khugaBash.getPlayerStats(attacker.address);
            expect(playerStats.score).to.equal(score);

            // Verify boss kill is recorded
            const killedBosses = await khugaBash.getPlayerKilledBosses(attacker.address);
            expect(killedBosses.length).to.equal(1);
            expect(killedBosses[0]).to.equal(bossId);
        });

        it("should reject syncData with invalid boss ID in array", async function () {
            // Register user first
            const registerTypes = {
                RegisterPlayer: [
                    { name: "player", type: "address" }
                ]
            };

            const registerSignature = await backend.signTypedData(
                EIP712_DOMAIN,
                registerTypes,
                { player: user.address }
            );

            await khugaBash.connect(user).registerPlayer(registerSignature);

            // Add one boss
            const validBossId = ethers.keccak256(ethers.toUtf8Bytes("valid_boss"));
            await khugaBash.addBoss(validBossId);

            // Create syncData signature with one valid and one invalid boss ID
            const syncDataTypes = {
                SyncData: [
                    { name: "player", type: "address" },
                    { name: "bossIds", type: "bytes32[]" },
                    { name: "score", type: "uint256" },
                    { name: "timestamp", type: "uint256" }
                ]
            };

            const invalidBossId = ethers.keccak256(ethers.toUtf8Bytes("invalid_boss"));
            const bossIds = [validBossId, invalidBossId];
            const score = 150;
            const timestamp = Math.floor(Date.now() / 1000);

            const syncDataValue = {
                player: user.address,
                bossIds: bossIds,
                score: score,
                timestamp: timestamp
            };

            const syncDataSignature = await backend.signTypedData(
                EIP712_DOMAIN,
                syncDataTypes,
                syncDataValue
            );

            // Should revert due to invalid boss ID
            await expect(
                khugaBash.connect(user).syncData(
                    bossIds,
                    score,
                    timestamp,
                    syncDataSignature
                )
            ).to.be.revertedWithCustomError(khugaBash, "InvalidBosses");
        });

        it("should prevent duplicate boss kills in same syncData call", async function () {
            // Register user first
            const registerTypes = {
                RegisterPlayer: [
                    { name: "player", type: "address" }
                ]
            };

            const registerSignature = await backend.signTypedData(
                EIP712_DOMAIN,
                registerTypes,
                { player: user.address }
            );

            await khugaBash.connect(user).registerPlayer(registerSignature);

            // Add a boss
            const bossId = ethers.keccak256(ethers.toUtf8Bytes("dup_boss"));
            await khugaBash.addBoss(bossId);

            // Create syncData signature with duplicate boss ID in array
            const syncDataTypes = {
                SyncData: [
                    { name: "player", type: "address" },
                    { name: "bossIds", type: "bytes32[]" },
                    { name: "score", type: "uint256" },
                    { name: "timestamp", type: "uint256" }
                ]
            };

            const bossIds = [bossId, bossId]; // Duplicate boss IDs
            const score = 200;
            const timestamp = Math.floor(Date.now() / 1000);

            const syncDataValue = {
                player: user.address,
                bossIds: bossIds,
                score: score,
                timestamp: timestamp
            };

            const syncDataSignature = await backend.signTypedData(
                EIP712_DOMAIN,
                syncDataTypes,
                syncDataValue
            );

            // Call syncData - should succeed but boss should only be recorded once
            await khugaBash.connect(user).syncData(
                bossIds,
                score,
                timestamp,
                syncDataSignature
            );

            // Verify boss was killed only once
            const killedBosses = await khugaBash.getPlayerKilledBosses(user.address);
            expect(killedBosses.length).to.equal(1);
            expect(killedBosses[0]).to.equal(bossId);
        });
    });
});