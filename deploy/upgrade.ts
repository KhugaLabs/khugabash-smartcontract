import { Wallet } from "zksync-ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync";
import { vars } from "hardhat/config";

export default async function (hre: HardhatRuntimeEnvironment) {
    console.log("Running upgrade script");

    const wallet = new Wallet(vars.get("DEPLOYER_PRIVATE_KEY"));
    const deployer = new Deployer(hre, wallet);

    // 1. The address of your deployed proxy
    const proxyAddress = "0xafcA524Dc2CDd7C21cD1de4E837c8c813c8322CC"; // <-- Replace with your proxy address

    // 2. Deploy the new implementation
    const khugaBashArtifact = await deployer.loadArtifact("KhugaBash");
    const newImpl = await deployer.deploy(khugaBashArtifact);
    console.log(`New KhugaBash implementation deployed to ${await newImpl.getAddress()}`);

    // 3. Call upgradeTo on the proxy (as the owner)
    const { Contract } = require("zksync-ethers");
    const connectedWallet = wallet.connect(hre.ethers.provider);
    const proxy = new Contract(proxyAddress, khugaBashArtifact.abi, connectedWallet);
    const tx = await proxy.upgradeToAndCall(await newImpl.getAddress(), "0x");
    await tx.wait();

    console.log("Proxy upgraded successfully!");
}