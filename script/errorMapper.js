const { keccak256, toUtf8Bytes } = require('ethers/lib/utils');

// List of custom error signatures
const errorSignatures = [
    "PlayerAlreadyRegistered()",
    "BossesNotSet()",
    "InvalidBosses()",
    "InvalidSignature()",
    "PlayerNotRegistered()",
    "BossNotExists()",
    "PlayerNotKilledBossYet()",
    "KtridgeSmartContractNotSet()",
    "SignatureAlreadyUsed()",
    "BossAlreadyExists()",
    "KtridgeAlreadyClaimed()",
    "OnlyKhugaBashCanMint()"
];

// Hash each error signature and compare with the error code
const errorCode = "0x18b54579";

errorSignatures.forEach(signature => {
    const hash = keccak256(toUtf8Bytes(signature)).slice(0, 10); // Get the first 4 bytes
    console.log(`${signature}: ${hash}`);
    if (hash === errorCode) {
        console.log(`Match found: ${signature}`);
    }
});