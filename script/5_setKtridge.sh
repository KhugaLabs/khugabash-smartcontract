#!/bin/bash

# Set the network to Base Sepolia
RPC_URL="https://api.testnet.abs.xyz"
CHAIN_ID="11124"
KTRIDGE_ADDRESS=0x37993643eB51667EF71279a3A1f4D6f0A21b87A7
PROXY_ADDRESS=0x7dccDe46D5FDA077924b46025937C92D9ea82894

cast send $PROXY_ADDRESS "setKtridgeNFT(address)" $KTRIDGE_ADDRESS --rpc-url $RPC_URL --account KhugaDeployer --chain $CHAIN_ID --zksync
cast send $KTRIDGE_ADDRESS "setKhugaBashAddress(address)" $PROXY_ADDRESS --rpc-url $RPC_URL --account KhugaDeployer --chain $CHAIN_ID --zksync
