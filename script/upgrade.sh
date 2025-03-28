#!/bin/bash

# Set the network to Base Sepolia
RPC_URL="https://api.testnet.abs.xyz"
CHAIN_ID="11124"
PROXY_ADDRESS=0x7dccDe46D5FDA077924b46025937C92D9ea82894
NEW_IMPLEMENTATION=0x66De1d1a94661bB9DeBe8bC26a8DEB3515c82d54

cast send $PROXY_ADDRESS "upgradeToAndCall(address,bytes)" $NEW_IMPLEMENTATION 0x --rpc-url $RPC_URL --account KhugaDeployer --chain $CHAIN_ID --zksync