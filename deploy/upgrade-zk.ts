import { Wallet, Contract } from "zksync-ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync";
import { vars } from "hardhat/config";
import { ethers } from "ethers";

// Upgrade script for UUPS KhugaBash proxy on zkSync Abstract Testnet
export default async function (hre: HardhatRuntimeEnvironment) {
    console.log(`\n=== KhugaBash UUPS Upgrade Script (zkSync) ===\n`);

    // Get the proxy address from environment variable
    const PROXY_ADDRESS = process.env.PROXY_ADDRESS || vars.get("PROXY_ADDRESS");

    if (!PROXY_ADDRESS) {
        throw new Error("Please set PROXY_ADDRESS environment variable or hardhat config");
    }

    console.log(`Proxy Address: ${PROXY_ADDRESS}`);

    // Initialize the wallet using deployer private key
    const wallet = new Wallet(vars.get("DEPLOYER_PRIVATE_KEY"));

    // Create deployer object
    const deployer = new Deployer(hre, wallet);

    // Get the provider and signer
    const provider = hre.ethers.provider;
    const signer = new Wallet(vars.get("DEPLOYER_PRIVATE_KEY"), provider);

    console.log(`\nDeployer/Signer Address: ${signer.address}`);

    // Load KhugaBash artifact to interact with proxy
    const khugaBashArtifact = await deployer.loadArtifact("KhugaBash");

    // Connect to proxy using KhugaBash ABI (UUPS proxies delegate calls to implementation)
    const khugaBash = new Contract(PROXY_ADDRESS, khugaBashArtifact.abi, signer);

    console.log(`\nChecking current proxy state...`);

    // Get current implementation address
    const currentImplSlot = "0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc";
    const currentImpl = await provider.getStorage(PROXY_ADDRESS, currentImplSlot);
    const currentImplAddress = ethers.getAddress("0x" + currentImpl.substring(26));
    console.log(`Current Implementation: ${currentImplAddress}`);

    // Verify this wallet is the owner (UUPS uses owner for upgrade authorization)
    const owner = await khugaBash.owner();
    console.log(`Contract Owner: ${owner}`);

    if (owner.toLowerCase() !== signer.address.toLowerCase()) {
        throw new Error(`Wallet (${signer.address}) is not the contract owner (${owner}). Only the owner can upgrade UUPS proxies.`);
    }

    console.log(`\n✅ Wallet verified as contract owner (UUPS upgrade authorized)`);

    // Deploy new implementation
    console.log(`\nDeploying new KhugaBash implementation...`);
    const khugaBashArtifact2 = await deployer.loadArtifact("KhugaBash");
    const newImpl = await deployer.deploy(khugaBashArtifact2);
    const newImplAddress = await newImpl.getAddress();
    console.log(`New Implementation: ${newImplAddress}`);

    // For UUPS, we call upgradeTo via ERC1967Upgrade interface
    console.log(`\nUpgrading UUPS proxy to new implementation...`);
    console.log(`Calling upgradeToAndCall(${newImplAddress}, "0x") on proxy...`);

    try {
        // Call upgradeToAndCall with empty data (no initialization needed)
        const upgradeTx = await khugaBash.upgradeToAndCall(newImplAddress, "0x", {
            gasLimit: 3000000  // Set a reasonable gas limit
        });
        console.log(`Upgrade transaction hash: ${upgradeTx.hash}`);

        // Wait for confirmation
        console.log(`Waiting for confirmation...`);
        const receipt = await upgradeTx.wait();

        console.log(`Transaction confirmed in block: ${receipt.blockNumber}`);
        console.log(`Gas used: ${receipt.gasUsed.toString()}`);

    } catch (error: any) {
        console.error(`Upgrade failed: ${error.message}`);
        throw error;
    }

    // Verify upgrade
    const newImplSlot = await provider.getStorage(PROXY_ADDRESS, currentImplSlot);
    const newImplStored = ethers.getAddress("0x" + newImplSlot.substring(26));

    console.log(`\n=== Upgrade Complete ===`);
    console.log(`Proxy: ${PROXY_ADDRESS}`);
    console.log(`Old Implementation: ${currentImplAddress}`);
    console.log(`New Implementation: ${newImplStored}`);

    if (newImplStored.toLowerCase() === newImplAddress.toLowerCase()) {
        console.log(`\n✅ Upgrade verified successfully!`);
        console.log(`\nYou can verify on ABScan: https://sepolia.abscan.org/address/${PROXY_ADDRESS}`);
        console.log(`\nNew implementation: https://sepolia.abscan.org/address/${newImplAddress}`);
    } else {
        throw new Error(`Upgrade verification failed! Expected ${newImplAddress}, got ${newImplStored}`);
    }
}
