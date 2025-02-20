#!/bin/bash

# Set the network to Base Sepolia
RPC_URL="https://api.testnet.abs.xyz"
CHAIN_ID="11124"

if [ -z "$PROXY_ADDRESS" ]; then
    echo "Please provide the proxy address as an argument"
    exit 1
fi

cast call $PROXY_ADDRESS "paused()" --rpc-url $RPC_URL --chain $CHAIN_ID 