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
        ).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("should revert if non-owner tries to set KtridgeNFT", async function () {
        await expect(
            khugaBash.connect(user).setKtridgeNFT(await ktridgeNFT.getAddress())
        ).to.be.revertedWith("Ownable: caller is not the owner");
    });

    // Add more tests for registration, syncData, mintKtridge, etc.
});