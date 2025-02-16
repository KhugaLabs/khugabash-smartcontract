# Khuga Bash Smart Contract

An upgradeable smart contract system for the Khuga Bash game, built with Solidity and Go. The system manages player points, stats, and leaderboards on Ethereum Layer 2 networks.

## Features

- Upgradeable smart contract using OpenZeppelin's UUPS pattern
- On-chain points system
- Player stat upgrades (Health & Power)
- Global leaderboard
- Go-based backend API
- Comprehensive test suite

## Smart Contract Architecture

The smart contract system consists of:

- `KhugaBash.sol`: Main game contract with points, stats, and leaderboard logic
- UUPS proxy pattern for upgradeability
- Security features:
  - ReentrancyGuard
  - Pausable
  - Access Control

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation.html)
- [Go](https://golang.org/doc/install) (1.21 or later)
- [Node.js](https://nodejs.org/) (for deployment scripts)

## Installation

1. Clone the repository:
   ```bash
   git clone git@github.com:KhugaLabs/KhugaBashSC.git
   cd KhugaBashSC
   ```

2. Install dependencies:
   ```bash
   # Install Foundry dependencies
   forge install

   # Install Go dependencies
   go mod tidy
   ```

3. Configure environment:
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

## Development

### Smart Contract

1. Compile contracts:
   ```bash
   forge build --zksync
   ```

2. Run tests:
   ```bash
   forge test
   ```

### Backend

1. Generate contract bindings:
   ```bash
   jq .abi zkout/KhugaBash.sol/KhugaBash.json > zkout/KhugaBash.sol/KhugaBash.abi.json
   abigen --abi zkout/KhugaBash.sol/KhugaBash.abi.json --pkg backend --type KhugaBash --out backend/khugabash.go
   ```

2. Backend code generated `backend/khugabash.go`

## Testing

### Smart Contract Tests

```bash
forge test
```

## Deployment

1. Add private key using wallet keystore
   ```bash
   cast wallet import <myKeystore> --interactive
   ```
   Enter your wallet’s private key when prompted and provide a password to encrypt it.

2. Generate the initialization calldata
   ```bash
   cast calldata "initialize()"
   ```

3. Deploy implementation contract:
   ```bash
   forge create src/KhugaBash.sol:KhugaBash \
   --rpc-url https://api.testnet.abs.xyz \
   --account <myKeystore> \
   --chain 11124 \
   --zksync
   ```

4. Deploy proxy contract:
   ```bash
   forge create src/Proxy.sol:KhugaBashProxy \
   --rpc-url https://api.testnet.abs.xyz \
   --account <myKeystore> \
   --chain 11124 \
   --zksync \
   --constructor-args <IMPL_ADDRESS> "<calldata>"
   ```

5. Verify smart contract:
   ```bash
   forge verify-contract <PROXY_CONTRACT_ADDRESS> \
    src/KhugaBash.sol:KhugaBash \
    --verifier etherscan \
    --verifier-url https://api-sepolia.abscan.org/api \
    --etherscan-api-key TACK2D1RGYX9U7MC31SZWWQ7FCWRYQ96AD \
    --zksync
   ```
   Use API_KEY: TACK2D1RGYX9U7MC31SZWWQ7FCWRYQ96AD for Abstract testnet

6. Start the backend server:
   ```bash
   go run backend/main.go
   ```

## Upgrade the Contract

1. Deploy new implementation contract:
   ```bash
   forge create src/KhugaBash.sol:KhugaBash --rpc-url <RPC_URL> --account <myKeystore> --chain 11124 --zksync
   ```

2. Upgrade proxy contract:
   ```bash
   cast send <PROXY_CONTRACT_ADDRESS> "upgradeTo(address)" <IMPLEMENTATION_CONTRACT_ADDRESS> --rpc-url <RPC_URL> --account <myKeystore>
   ```

## Security Considerations

- All state-changing functions are protected against reentrancy
- Owner-only functions for critical operations
- Pausable functionality for emergency situations

## License

MIT License
