#!/bin/bash

# Set the network to Base Sepolia
RPC_URL="https://api.testnet.abs.xyz"
CHAIN_ID="11124"

# Deploy new implementation
forge create src/KhugaBash.sol:KhugaBash --rpc-url $RPC_URL --account KID --chain $CHAIN_ID --zksync
