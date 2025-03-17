#!/bin/bash

# Set the network to Base Sepolia
RPC_URL="https://api.testnet.abs.xyz"
CHAIN_ID="11124"

if [ -z "$KHUGABASH_ADDRESS" ]; then
    echo "Please provide the khugabash address as an argument"
    exit 1
fi

if [ -z "$CATRIDGE_ADDRESS" ]; then
    echo "Please provide the catridge address as an argument"
    exit 1
fi



# Verify the implementation contract
forge verify-contract $KHUGABASH_ADDRESS src/KhugaBash.sol:KhugaBash --verifier etherscan --verifier-url https://api-sepolia.abscan.org/api --etherscan-api-key TACK2D1RGYX9U7MC31SZWWQ7FCWRYQ96AD --zksync

forge verify-contract $CATRIDGE_ADDRESS src/CatridgeNFT.sol:CatridgeNFT --verifier etherscan --verifier-url https://api-sepolia.abscan.org/api --etherscan-api-key TACK2D1RGYX9U7MC31SZWWQ7FCWRYQ96AD --zksync