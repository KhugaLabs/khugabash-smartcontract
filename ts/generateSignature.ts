import { Provider, Wallet, types } from 'zksync-ethers';
import * as dotenv from 'dotenv';

type SignerConfig = {
    contractName: string;
    version: string;
    chainId: number;
    contractAddress: string;
}

export async function generateRegisterPlayerSignature(
    signerWallet: Wallet,
    playerAddress: string,
    nonce: number,
    config: SignerConfig
) {
    const domain = {
        name: config.contractName,
        version: config.version,
        chainId: config.chainId,
        verifyingContract: config.contractAddress,
    };

    const types = {
        PlayerRegistered: [
            { name: 'player', type: 'address' },
            { name: 'nonce', type: 'uint256' },
        ],
    };

    const value = {
        player: playerAddress,
        nonce: nonce,
    };

    return await signerWallet.signTypedData(domain, types, value);
}

dotenv.config();

async function main() {
    // Load environment variables
    const PRIVATE_KEY = process.env.PRIVATE_KEY;
    const RPC_URL = process.env.RPC_URL;
    const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS;

    if (!PRIVATE_KEY || !RPC_URL || !CONTRACT_ADDRESS) {
        throw new Error('Missing environment variables');
    }

    // Setup provider and signer
    const provider = new Provider(RPC_URL);
    const signer = new Wallet(PRIVATE_KEY, provider);

    // Configuration
    const config = {
        contractName: 'KhugaBash',
        version: '1',
        chainId: 11124, // zkSync Era Testnet - adjust for your network
        contractAddress: CONTRACT_ADDRESS,
    };

    // Example player address and nonce
    const playerAddress = process.argv[2]; // Get from command line argument
    const nonce = parseInt(process.argv[3]); // Get from command line argument

    if (!playerAddress || isNaN(nonce)) {
        throw new Error('Please provide player address and nonce as arguments');
    }

    try {
        const signature = await generateRegisterPlayerSignature(
            signer,
            playerAddress,
            nonce,
            config
        );

        console.log('Generated Signature:');
        console.log('Player Address:', playerAddress);
        console.log('Nonce:', nonce);
        console.log('Signature:', signature);
    } catch (error) {
        console.error('Error generating signature:', error);
    }
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
}); 