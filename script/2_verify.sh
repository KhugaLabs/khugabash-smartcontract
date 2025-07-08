#!/bin/bash

# Set the network to Base Sepolia
RPC_URL="https://api.testnet.abs.xyz"
CHAIN_ID="11124"
KHUGABASH_ADDRESS=0x40f8B40FdF79E79d56C4a008b983d344f0c1C39e
KTRIDGE_ADDRESS=0x37993643eB51667EF71279a3A1f4D6f0A21b87A7



# Verify the implementation contract
forge verify-contract $KHUGABASH_ADDRESS src/KhugaBash.sol:KhugaBash --verifier etherscan --verifier-url https://api-sepolia.abscan.org/api --etherscan-api-key TACK2D1RGYX9U7MC31SZWWQ7FCWRYQ96AD --zksync

forge verify-contract $KTRIDGE_ADDRESS src/KtridgeNFT.sol:KtridgeNFT --verifier etherscan --verifier-url https://api-sepolia.abscan.org/api --etherscan-api-key TACK2D1RGYX9U7MC31SZWWQ7FCWRYQ96AD --zksync