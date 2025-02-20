#!/bin/bash

# Set the network to Base Sepolia
RPC_URL="https://api.testnet.abs.xyz"
CHAIN_ID="11124"
CALLLDATA="0x8129fc1c"

if [ -z "$IMPL_ADDRESS" ]; then
    echo "Please provide the implementation address as an argument"
    exit 1
fi

# Deploy the proxy contract
forge create src/Proxy.sol:KhugaBashProxy \
   --rpc-url $RPC_URL \
   --account KID \
   --chain $CHAIN_ID \
   --zksync \
   --constructor-args $IMPL_ADDRESS $CALLLDATA \
   --verify
