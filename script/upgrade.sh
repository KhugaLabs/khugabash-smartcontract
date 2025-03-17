#!/bin/bash

# Set the network to Base Sepolia
RPC_URL="https://api.testnet.abs.xyz"
CHAIN_ID="11124"

if [ -z "$PROXY_ADDRESS" ]; then
    echo "Please provide the proxy address as an argument"
    exit 1
fi

if [ -z "$NEW_IMPLEMENTATION" ]; then
    echo "Please provide the new implementation address as an argument"
    exit 1
fi

cast send $PROXY_ADDRESS "upgradeToAndCall(address,bytes)" $NEW_IMPLEMENTATION 0x --rpc-url $RPC_URL --account KID --chain $CHAIN_ID --zksync