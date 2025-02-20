import { ethers } from 'ethers';

/**
 * @typedef {Object} SignerConfig
 * @property {string} contractName
 * @property {string} version
 * @property {number} chainId
 * @property {string} contractAddress
 */

/**
 * @param {ethers.Wallet} signerWallet
 * @param {string} playerAddress
 * @param {number} nonce
 * @param {SignerConfig} config
 * @returns {Promise<string>}
 */
export async function generateRegisterPlayerSignature(
    signerWallet,
    playerAddress,
    nonce,
    config
) {
    // EIP-712 Domain
    const domain = {
        name: config.contractName,
        version: config.version,
        chainId: config.chainId,
        verifyingContract: config.contractAddress,
    };

    // Define the types for EIP-712 signing
    const types = {
        PlayerRegistered: [
            { name: 'player', type: 'address' },
            { name: 'nonce', type: 'uint256' },
        ],
    };

    // Create the typed data
    const value = {
        player: playerAddress,
        nonce: nonce,
    };

    // Sign the typed data
    const signature = await signerWallet.signTypedData(domain, types, value);

    return signature;
}

// Example usage:
async function example() {
    const provider = new ethers.JsonRpcProvider('YOUR_RPC_URL');
    const privateKey = 'YOUR_PRIVATE_KEY';
    const signer = new ethers.Wallet(privateKey, provider);

    /** @type {SignerConfig} */
    const config = {
        contractName: 'KhugaBash',
        version: '1',
        chainId: 280, // zkSync Era Testnet
        contractAddress: 'YOUR_CONTRACT_ADDRESS',
    };

    const playerAddress = '0x...';
    const nonce = 1;

    const signature = await generateRegisterPlayerSignature(
        signer,
        playerAddress,
        nonce,
        config
    );

    console.log('Signature:', signature);
}