import { ethers, upgrades } from "hardhat";

async function main() {
    const PROXY_ADDRESS = process.env.PROXY_ADDRESS;

    if (!PROXY_ADDRESS) {
        throw new Error("Please set PROXY_ADDRESS environment variable");
    }

    console.log("Upgrading KhugaBash contract...");
    console.log("Proxy address:", PROXY_ADDRESS);

    // Get current implementation address
    const currentImpl = await upgrades.erc1967.getImplementationAddress(PROXY_ADDRESS);
    console.log("Current implementation:", currentImpl);

    // Get current admin address (if any)
    try {
        const currentAdmin = await upgrades.erc1967.getAdminAddress(PROXY_ADDRESS);
        console.log("Current admin:", currentAdmin);
    } catch (error) {
        console.log("No admin detected (UUPS proxy)");
    }

    // Upgrade the proxy
    const KhugaBashV2 = await ethers.getContractFactory("KhugaBash");

    console.log("Deploying new implementation...");
    const proxy = await upgrades.upgradeProxy(PROXY_ADDRESS, KhugaBashV2, {
        timeout: 0,
    });

    console.log("KhugaBash upgraded successfully");
    console.log("Proxy address:", await proxy.getAddress());

    // Get new implementation address
    const newImpl = await upgrades.erc1967.getImplementationAddress(await proxy.getAddress());
    console.log("New implementation:", newImpl);

    // Verify the upgrade was successful
    if (currentImpl === newImpl) {
        console.warn("Warning: Implementation address did not change. Upgrade may not have been successful.");
    } else {
        console.log("✅ Upgrade verified: Implementation address changed successfully");
    }

    // Wait for a few block confirmations
    console.log("Waiting for block confirmations...");
    await proxy.deploymentTransaction()?.wait(5);

    console.log("\n=== Upgrade Summary ===");
    console.log("Proxy Address:", await proxy.getAddress());
    console.log("Previous Implementation:", currentImpl);
    console.log("New Implementation:", newImpl);
    console.log("\nPlease verify the contract on Etherscan/BscScan after deployment.");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
