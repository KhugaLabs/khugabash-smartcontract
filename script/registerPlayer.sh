#!/bin/bash

# Set the network to Base Sepolia
RPC_URL="https://api.testnet.abs.xyz"
CHAIN_ID="11124"

if [ -z "$PROXY_ADDRESS" ]; then
    echo "Please provide the proxy address as an argument"
    exit 1
fi

if [ -z "$NONCE" ]; then
    echo "Please provide the nonce as an argument"
    exit 1
fi

cast send $PROXY_ADDRESS "registerPlayer(uint256)" $NONCE --rpc-url $RPC_URL --account KhugaDeployer --chain $CHAIN_ID --zksync