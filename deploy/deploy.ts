import { Wallet, ContractFactory, Contract } from "zksync-ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync";
import { vars } from "hardhat/config";
import { ethers } from "ethers";

// An example of a deploy script that will deploy and call a simple contract.
export default async function (hre: HardhatRuntimeEnvironment) {
    console.log(`Running deploy script`);

    // Initialize the wallet using your private key.
    const wallet = new Wallet(vars.get("DEPLOYER_PRIVATE_KEY"));

    // Create deployer object and load the artifact of the contract we want to deploy.
    const deployer = new Deployer(hre, wallet);

    // 1. Deploy KtridgeNFT
    const ktridgeArtifact = await deployer.loadArtifact("KtridgeNFT");
    const ktridgeNFT = await deployer.deploy(ktridgeArtifact, [wallet.address]);
    console.log(`KtridgeNFT deployed to ${await ktridgeNFT.getAddress()}`);

    // 2. Deploy KhugaBash (implementation)
    const khugaBashArtifact = await deployer.loadArtifact("KhugaBash");
    const khugaBashImpl = await deployer.deploy(khugaBashArtifact);
    console.log(`KhugaBash implementation deployed to ${await khugaBashImpl.getAddress()}`);

    // 3. Deploy Proxy, with initializer data
    const proxyArtifact = await deployer.loadArtifact("KhugaBashProxy");
    const initializer = khugaBashImpl.interface.encodeFunctionData("initialize", [wallet.address]);
    const proxy = await deployer.deploy(proxyArtifact, [
        await khugaBashImpl.getAddress(),
        initializer,
    ]);
    console.log(`KhugaBashProxy deployed to ${await proxy.getAddress()}`);

    // 4. (Optional) Set KtridgeNFT address in KhugaBash via proxy
    // const khugaBashProxy = new Contract(await proxy.getAddress(), khugaBashArtifact.abi, wallet);
    // await khugaBashProxy.setKtridgeNFT(await ktridgeNFT.getAddress());
}