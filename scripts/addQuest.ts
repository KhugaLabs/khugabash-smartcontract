import { Wallet, Contract } from "zksync-ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync";
import { vars } from "hardhat/config";
import { ethers } from "ethers";

/**
 * Script to add a quest to the KhugaBash contract
 *
 * Usage:
 *   QUEST_ID="0x..." QUEST_NAME="Quest Name" npx hardhat run scripts/addQuest.ts --network abstractTestnet
 *
 * Or with all parameters:
 *   QUEST_ID="0x..." QUEST_NAME="..." QUEST_DESC="..." REWARD=100 IS_DAILY=true IMAGE_URL="..." npx hardhat run scripts/addQuest.ts --network abstractTestnet
 */
export default async function (hre: HardhatRuntimeEnvironment) {
    console.log(`\n=== Add Quest Script ===\n`);

    // Get proxy address
    const PROXY_ADDRESS = process.env.PROXY_ADDRESS || vars.get("PROXY_ADDRESS");
    if (!PROXY_ADDRESS) {
        throw new Error("Please set PROXY_ADDRESS environment variable or hardhat config");
    }

    // Get quest parameters from environment or hardhat vars
    const questId = process.env.QUEST_ID || vars.get("QUEST_ID");
    const questName = process.env.QUEST_NAME || vars.get("QUEST_NAME");
    const questDescription = process.env.QUEST_DESC || vars.get("QUEST_DESC") || "";
    const rewardAmount = process.env.REWARD ? BigInt(process.env.REWARD) : vars.get("REWARD");
    const isDaily = process.env.IS_DAILY === "true" || vars.get("IS_DAILY") === "true";
    const imageUrl = process.env.IMAGE_URL || vars.get("IMAGE_URL") || "";

    // Validate required parameters
    if (!questId) {
        throw new Error("Please set QUEST_ID (format: 0x... or use keccak256)");
    }
    if (!questName) {
        throw new Error("Please set QUEST_NAME");
    }
    if (!rewardAmount) {
        throw new Error("Please set REWARD (amount in wei)");
    }

    // Initialize wallet
    const wallet = new Wallet(vars.get("DEPLOYER_PRIVATE_KEY"));
    const deployer = new Deployer(hre, wallet);
    const provider = hre.ethers.provider;
    const signer = new Wallet(vars.get("DEPLOYER_PRIVATE_KEY"), provider);

    console.log(`Proxy Address: ${PROXY_ADDRESS}`);
    console.log(`Signer: ${signer.address}\n`);

    // Load KhugaBash contract
    const khugaBashArtifact = await deployer.loadArtifact("KhugaBash");
    const khugaBash = new Contract(PROXY_ADDRESS, khugaBashArtifact.abi, signer);

    // Display quest details
    console.log(`=== Quest Details ===`);
    console.log(`Quest ID: ${questId}`);
    console.log(`Name: ${questName}`);
    console.log(`Description: ${questDescription || "(none)"}`);
    console.log(`Reward: ${rewardAmount.toString()} wei`);
    console.log(`Is Daily: ${isDaily}`);
    console.log(`Image URL: ${imageUrl || "(none)"}`);
    console.log(`\n`);

    // Check if quest already exists
    const questExists = await khugaBash.checkBossExists(questId); // Using a similar function, or we can check differently

    try {
        const quest = await khugaBash.getQuestDetails(questId);
        if (quest && quest.name !== "") {
            console.log(`⚠️  Warning: Quest with ID ${questId} already exists with name "${quest.name}"`);
            const proceed = process.env.FORCE === "true";
            if (!proceed) {
                console.log(`\nSet FORCE=true to update this quest instead, or use a different QUEST_ID`);
                return;
            }
            console.log(`\nProceeding to update existing quest...\n`);
        }
    } catch (e) {
        // Quest doesn't exist, which is expected
    }

    // Add or update the quest
    try {
        console.log(`Adding quest to contract...`);

        const tx = await khugaBash.addQuest(
            questId,
            questName,
            questDescription,
            rewardAmount,
            isDaily,
            imageUrl,
            { gasLimit: 300000 }
        );

        console.log(`Transaction hash: ${tx.hash}`);
        console.log(`Waiting for confirmation...`);

        const receipt = await tx.wait();
        console.log(`Transaction confirmed in block: ${receipt.blockNumber}`);
        console.log(`Gas used: ${receipt.gasUsed.toString()}`);

        // Verify the quest was added
        console.log(`\nVerifying quest...`);
        const addedQuest = await khugaBash.getQuestDetails(questId);

        console.log(`\n✅ Quest added successfully!`);
        console.log(`\n=== Quest Details ===`);
        console.log(`ID: ${addedQuest[0]}`);
        console.log(`Name: ${addedQuest[1]}`);
        console.log(`Description: ${addedQuest[2]}`);
        console.log(`Reward: ${addedQuest[3].toString()} wei`);
        console.log(`Is Active: ${addedQuest[4]}`);
        console.log(`Is Daily: ${addedQuest[5]}`);
        console.log(`Image URL: ${addedQuest[6]}`);

        console.log(`\nYou can view on ABScan: https://sepolia.abscan.org/tx/${tx.hash}`);

    } catch (error: any) {
        console.error(`\n❌ Failed to add quest: ${error.message}`);
        if (error.message.includes("onlyOwner")) {
            console.error(`Error: Only the contract owner can add quests`);
            console.error(`Your address: ${signer.address}`);
        }
        throw error;
    }
}
