#!/bin/bash

# Set the network to Base Sepolia
RPC_URL="https://api.testnet.abs.xyz"
CHAIN_ID="11124"
CALLLDATA="0x8129fc1c"
ADMIN_ADDRESS="0xBce4253a81B232cC41027dCbE33fDdA010dC33Aa"

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
   --constructor-args $IMPL_ADDRESS $ADMIN_ADDRESS $CALLLDATA \
   --verify \
   --verifier etherscan \
   --verifier-url https://api-sepolia.abscan.org/api \
   --etherscan-api-key TACK2D1RGYX9U7MC31SZWWQ7FCWRYQ96AD
