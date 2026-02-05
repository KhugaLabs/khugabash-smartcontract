import { ethers } from "ethers";

/**
 * Helper script to generate a quest ID (bytes32) from a string
 *
 * Usage:
 *   node scripts/generate-quest-id.ts "My Quest Name"
 *   or
 *   QUEST_NAME="Daily Login" node scripts/generate-quest-id.ts
 */

function generateQuestId(input: string): string {
    // Hash the input string to get bytes32
    const hash = ethers.keccak256(ethers.toUtf8Bytes(input));
    return hash;
}

function main() {
    const input = process.argv[2] || process.env.QUEST_NAME;

    if (!input) {
        console.log("\n=== Quest ID Generator ===\n");
        console.log("Usage:");
        console.log("  node scripts/generate-quest-id.ts \"Quest Name\"");
        console.log("  or");
        console.log("  QUEST_NAME=\"My Quest\" node scripts/generate-quest-id.ts\n");
        console.log("Examples:");
        console.log('  node scripts/generate-quest-id.ts "Daily Login"');
        console.log('  node scripts/generate-quest-id.ts "Kill 5 Bosses"');
        console.log('  node scripts/generate-quest-id.ts "Collect 100 Coins"\n');
        return;
    }

    const questId = generateQuestId(input);

    console.log(`\n=== Quest ID Generated ===\n`);
    console.log(`Input: "${input}"`);
    console.log(`Quest ID: ${questId}`);
    console.log(`\nUse this in your addQuest command:`);
    console.log(`QUEST_ID="${questId}" QUEST_NAME="${input}" ...\n`);
}

main();
