#!/bin/bash

# Set the network to Base Sepolia
RPC_URL="https://api.testnet.abs.xyz"
CHAIN_ID="11124"
PROXY_ADDRESS=0x7dccDe46D5FDA077924b46025937C92D9ea82894
BOSS_TO_ADD=0x0000000000000000000000000000000000000000000000000000000000000001

cast send $PROXY_ADDRESS "addBoss(bytes32)" $BOSS_TO_ADD --rpc-url $RPC_URL --account KhugaDeployer --chain $CHAIN_ID --zksync