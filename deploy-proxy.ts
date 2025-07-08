import { Wallet, Contract } from "zksync-ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync";
import { vars } from "hardhat/config";

export default async function (hre: HardhatRuntimeEnvironment) {
    console.log(`Running proxy deploy script`);

    const wallet = new Wallet(vars.get("DEPLOYER_PRIVATE_KEY"));
    const deployer = new Deployer(hre, wallet);

    // 1. Use the already deployed KhugaBash implementation address
    const khugaBashImplAddress = "0x3756ed2EB7067416c1ECAe3E8387D1F226D770D3"; // <-- Replace with your deployed address

    // 2. Deploy Proxy, with initializer data
    const khugaBashArtifact = await deployer.loadArtifact("KhugaBash");
    const proxyArtifact = await deployer.loadArtifact("KhugaBashProxy");
    const initializer = new Contract(
        khugaBashImplAddress,
        khugaBashArtifact.abi,
        wallet
    ).interface.encodeFunctionData("initialize", [wallet.address]);
    const proxy = await deployer.deploy(proxyArtifact, [
        khugaBashImplAddress,
        initializer,
    ]);
    console.log(`KhugaBashProxy deployed to ${await proxy.getAddress()}`);

    // 3. (Optional) Set KtridgeNFT address in KhugaBash via proxy
    // const ktridgeNFTAddress = "<YOUR_KTRIDGE_NFT_ADDRESS>";
    // const khugaBashProxy = new Contract(await proxy.getAddress(), khugaBashArtifact.abi, wallet);
    // await khugaBashProxy.setKtridgeNFT(ktridgeNFTAddress);
}