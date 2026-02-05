import { HardhatUserConfig } from "hardhat/config";
import "@matterlabs/hardhat-zksync";
import "@matterlabs/hardhat-zksync-verify";

const config: HardhatUserConfig = {
  zksolc: {
    version: "1.5.15",
    settings: {
      // find all available options in the official documentation
      // https://docs.zksync.io/build/tooling/hardhat/hardhat-zksync-solc#configuration
      codegen: "evmla", // Use EVM legacy assembly to match solc default behavior
    },
  },
  defaultNetwork: "abstractTestnet",
  networks: {
    abstractTestnet: {
      url: "https://api.testnet.abs.xyz",
      ethNetwork: "sepolia",
      zksync: true,
      chainId: 11124,
    },
    abstractMainnet: {
      url: "https://api.mainnet.abs.xyz",
      ethNetwork: "mainnet",
      zksync: true,
      chainId: 2741,
    },
  },
  etherscan: {
    apiKey: {
      // abstractTestnet: "TACK2D1RGYX9U7MC31SZWWQ7FCWRYQ96AD",
      abstractTestnet: "36GG3I5AJ9XM874CX5B45JIZREV1FC7IM5",
      abstractMainnet: "IEYKU3EEM5XCD76N7Y7HF9HG7M9ARZ2H4A",
    },
    customChains: [
      {
        network: "abstractTestnet",
        chainId: 11124,
        urls: {
          apiURL: "https://api.etherscan.io/v2/api",
          browserURL: "https://sepolia.abscan.org/",
        },
      },
      {
        network: "abstractMainnet",
        chainId: 2741,
        urls: {
          apiURL: "https://api.etherscan.io/v2/api",
          browserURL: "https://abscan.org/",
        },
      },
    ],
  },
  solidity: {
    version: "0.8.28",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      viaIR: true,
    },
  },
};

export default config;