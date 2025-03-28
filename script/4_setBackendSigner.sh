#!/bin/bash

# Set the network to Base Sepolia
RPC_URL="https://api.testnet.abs.xyz"
CHAIN_ID="11124"
BACKEND_SIGNER=0xBE8665369c99Be217c7C37D0078e3f8a6F76d683
PROXY_ADDRESS=0x7dccDe46D5FDA077924b46025937C92D9ea82894

cast send $PROXY_ADDRESS "setBackendSigner(address)" $BACKEND_SIGNER --rpc-url $RPC_URL --account KhugaDeployer --chain $CHAIN_ID --zksync