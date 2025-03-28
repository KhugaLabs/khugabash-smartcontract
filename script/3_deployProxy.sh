#!/bin/bash

# Set the network to Base Sepolia
RPC_URL="https://api.testnet.abs.xyz"
CHAIN_ID="11124"
CALLLDATA="0x8129fc1c"
KHUGABASH_ADDRESS=0x3b403b6f0e2e4a7F6CB6c0E3408B0Fd5b06807D3

# Deploy the proxy contract
forge create src/Proxy.sol:KhugaBashProxy \
   --rpc-url $RPC_URL \
   --account KhugaDeployer \
   --chain $CHAIN_ID \
   --zksync \
   --constructor-args $KHUGABASH_ADDRESS $CALLLDATA \
   --verify \
   --verifier etherscan \
   --verifier-url https://api-sepolia.abscan.org/api \
   --etherscan-api-key TACK2D1RGYX9U7MC31SZWWQ7FCWRYQ96AD
