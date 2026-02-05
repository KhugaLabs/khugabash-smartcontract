import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import "@nomicfoundation/hardhat-chai-matchers";

describe("KhugaBash", function () {
    let owner: any, backend: any, user: any, ktridgeNFT: any, khugaBash: any;

    beforeEach(async function () {
        [owner, backend, user] = await ethers.getSigners();

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
    });
});