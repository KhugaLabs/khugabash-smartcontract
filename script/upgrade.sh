#!/bin/bash

# Set the network to Base Sepolia
RPC_URL="https://api.testnet.abs.xyz"
CHAIN_ID="11124"
PROXY_ADDRESS=0x7dccDe46D5FDA077924b46025937C92D9ea82894
NEW_IMPLEMENTATION=0x40f8B40FdF79E79d56C4a008b983d344f0c1C39e

cast send $PROXY_ADDRESS "upgradeToAndCall(address,bytes)" $NEW_IMPLEMENTATION 0x --rpc-url $RPC_URL --account KhugaDeployer --chain $CHAIN_ID --zksync