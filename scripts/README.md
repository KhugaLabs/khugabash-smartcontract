# KhugaBash Quest Management Scripts

This directory contains scripts to manage quests on the KhugaBash contract.

## Scripts

### 1. generate-quest-id.ts
Generate a unique quest ID (bytes32) from a quest name.

**Usage:**
```bash
node scripts/generate-quest-id.ts "Quest Name"
```

**Examples:**
```bash
node scripts/generate-quest-id.ts "Daily Login Challenge"
node scripts/generate-quest-id.ts "Kill 5 Bosses"
node scripts/generate-quest-id.ts "Collect 100 Coins"
```

### 2. addQuest.ts
Add a new quest to the KhugaBash contract.

**Required Environment Variables:**
```bash
PROXY_ADDRESS=0x...          # Your deployed proxy address
DEPLOYER_PRIVATE_KEY=0x...   # Your deployer private key
QUEST_ID=0x...               # Quest ID (use generate-quest-id.ts)
QUEST_NAME="..."             # Quest name
REWARD=1000000000000000000  # Reward amount in wei
```

**Optional Environment Variables:**
```bash
QUEST_DESC="..."   # Quest description (default: empty)
IS_DAILY=true     # Is this a daily quest? (default: false)
IMAGE_URL="..."   # Image URL for the quest (default: empty)
FORCE=true        # Update existing quest (default: false)
```

**Usage Examples:**

### Example 1: Add a simple quest
```bash
# Generate quest ID first
QUEST_ID=$(node scripts/generate-quest-id.ts "Daily Login" | grep "Quest ID:" | cut -d' ' -f3)

# Add the quest
QUEST_ID="$QUEST_ID" \
QUEST_NAME="Daily Login" \
REWARD="1000000000000000000" \
npx hardhat run scripts/addQuest.ts --network abstractTestnet
```

### Example 2: Add a daily quest with description
```bash
# Generate quest ID
QUEST_ID=$(node scripts/generate-quest-id.ts "Kill 5 Bosses" | grep "Quest ID:" | cut -d' ' -f3)

# Add the daily quest
QUEST_ID="$QUEST_ID" \
QUEST_NAME="Kill 5 Bosses" \
QUEST_DESC="Defeat 5 bosses in a single day" \
REWARD="5000000000000000000" \
IS_DAILY=true \
IMAGE_URL="https://example.com/boss-quest.png" \
npx hardhat run scripts/addQuest.ts --network abstractTestnet
```

### Example 3: Using hardhat vars (recommended)
```bash
# Set variables once
npx hardhat vars set PROXY_ADDRESS
npx hardhat vars set DEPLOYER_PRIVATE_KEY
npx hardhat vars set QUEST_ID
npx hardhat vars set QUEST_NAME
npx hardhat vars set REWARD

# Run the script
npx hardhat run scripts/addQuest.ts --network abstractTestnet
```

## Quest Types

### Regular Quests
Can be completed once per player.
```bash
IS_DAILY=false
```

### Daily Quests
Can be completed once per day by each player.
```bash
IS_DAILY=true
```

## Reward Amount Guide

Common reward amounts in wei:
- 0.001 ETH = 1000000000000000 wei
- 0.01 ETH = 10000000000000000 wei
- 0.1 ETH = 100000000000000000 wei
- 1 ETH = 1000000000000000000 wei

## Updating Existing Quests

To update an existing quest, use the `FORCE` flag:
```bash
FORCE=true QUEST_ID="..." QUEST_NAME="..." REWARD="..." npx hardhat run scripts/addQuest.ts --network abstractTestnet
```

## Verification

After adding a quest, verify it on:
- ABScan: https://sepolia.abscan.org/address/YOUR_PROXY_ADDRESS
- Use `getQuestDetails(questId)` to view quest details

## Error Handling

Common errors:
- **"onlyOwner"**: Your wallet is not the contract owner
- **"QuestAlreadyExists"**: Quest ID already exists (use FORCE=true to update)
- **"InvalidQuestId"**: Quest ID is zero address (use generate-quest-id.ts)

## Quick Start

1. Generate a quest ID:
```bash
node scripts/generate-quest-id.ts "My First Quest"
```

2. Set your environment variables (use hardhat vars for security):
```bash
npx hardhat vars set PROXY_ADDRESS
npx hardhat vars set DEPLOYER_PRIVATE_KEY
npx hardhat vars set QUEST_NAME
npx hardhat vars set REWARD
```

3. Add the quest:
```bash
npx hardhat run scripts/addQuest.ts --network abstractTestnet
```

4. Verify on ABScan:
```bash
echo "https://sepolia.abscan.org/address/YOUR_PROXY_ADDRESS"
```
