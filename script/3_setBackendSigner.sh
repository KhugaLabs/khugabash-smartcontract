#!/bin/bash

# Set the network to Base Sepolia
RPC_URL="https://api.testnet.abs.xyz"
CHAIN_ID="11124"
BACKEND_SIGNER="0xBce4253a81B232cC41027dCbE33fDdA010dC33Aa"

if [ -z "$PROXY_ADDRESS" ]; then
    echo "Please provide the proxy address as an argument"
    exit 1
fi

cast send $PROXY_ADDRESS "setBackendSigner(address)" $BACKEND_SIGNER --rpc-url $RPC_URL --account KID --chain $CHAIN_ID --zksync