const { ethers } = require("hardhat");

async function main() {
  // Get signers
  const [owner, backend, user] = await ethers.getSigners();
  
  // Deploy
  const KhugaBash = await ethers.getContractFactory("KhugaBash");
  const khugaBash = await upgrades.deployProxy(KhugaBash, [owner.address], { kind: "uups" });
  await khugaBash.waitForDeployment();
  
  await khugaBash.setBackendSigner(backend.address);
  const contractAddress = await khugaBash.getAddress();
  
  const EIP712_DOMAIN = {
    name: "KhugaBash",
    version: "1",
    chainId: 31337,
    verifyingContract: contractAddress
  };
  
  // Add a boss
  const bossId = ethers.keccak256(ethers.toUtf8Bytes("boss1"));
  await khugaBash.addBoss(bossId);
  
  // Register user
  const registerTypes = {
    RegisterPlayer: [{ name: "player", type: "address" }]
  };
  const registerSig = await backend.signTypedData(EIP712_DOMAIN, registerTypes, { player: user.address });
  await khugaBash.connect(user).registerPlayer(registerSig);
  
  // Test syncData with array
  const syncTypes = {
    SyncData: [
      { name: "player", type: "address" },
      { name: "bossIds", type: "bytes32[]" },
      { name: "score", type: "uint256" },
      { name: "timestamp", type: "uint256" }
    ]
  };
  
  const bossIds = [bossId];
  const timestamp = Math.floor(Date.now() / 1000);
  
  // Sign with backend
  const syncSig = await backend.signTypedData(
    EIP712_DOMAIN,
    syncTypes,
    { player: user.address, bossIds, score: 100, timestamp }
  );
  
  // Try to sync
  try {
    await khugaBash.connect(user).syncData(bossIds, 100, timestamp, syncSig);
    console.log("✓ syncData succeeded with correct array encoding");
  } catch (e) {
    console.log("✗ syncData failed:", e.message);
  }
}

main().catch(console.error);
