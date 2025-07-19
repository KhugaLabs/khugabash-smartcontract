# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a Hardhat Ignition module that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/Lock.ts
```

## Generate Golang Code

1. Create abi.json from smartcontract json

```bash
cat deployments-zk/abstractTestnet/contracts/KhugaBash.sol/KhugaBash.json | jq '.abi' > khuga_bash_abi.json
```

2. Generate code using abigen

```bash
abigen --abi khuga_bash_abi.json --pkg khugabash --type KhugaBash --out golang-backend/khugabash.go
```