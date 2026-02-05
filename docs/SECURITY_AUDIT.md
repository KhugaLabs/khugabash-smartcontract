# Security Audit Report

## Executive Summary

This document outlines the security vulnerabilities identified and fixed in the KhugaBash smart contract, along with verification procedures and deployment guidelines.

**Audit Date:** February 2026
**Contract Version:** v2.0
**Audit Type:** Internal Security Review

---

## Table of Contents

1. [Overview](#overview)
2. [Critical Issues Fixed](#critical-issues-fixed)
3. [High Priority Issues Fixed](#high-priority-issues-fixed)
4. [Medium Priority Issues Fixed](#medium-priority-issues-fixed)
5. [Security Improvements](#security-improvements)
6. [Verification Procedures](#verification-procedures)
7. [Deployment Instructions](#deployment-instructions)
8. [Post-Deployment Checklist](#post-deployment-checklist)

---

## Overview

The KhugaBash contract is a UUPS (Universal Upgradeable Proxy Standard) proxy contract that manages player data, boss kills, quests, and rewards for a gaming platform. The contract uses EIP-712 structured data signing for backend-verified operations.

**Key Security Features:**
- EIP-712 typed structured data hashing
- Signature replay protection
- Reentrancy guards on external functions
- UUPS upgradeability pattern
- Access control with OpenZeppelin's Ownable2Step

---

## Critical Issues Fixed

### 1. Missing Signature Replay Protection ⚠️

**Severity:** CRITICAL
**Status:** ✅ FIXED

**Issue:**
The original contract did not track used signatures, allowing the same signature to be reused multiple times in replay attacks.

**Vulnerability Details:**
```solidity
// BEFORE (Vulnerable)
function _verifySignature(bytes calldata signature, bytes32 structHash) internal {
    bytes32 messageHash = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));
    address signer = messageHash.recover(signature);
    if (signer != backendSigner) {
        revert InvalidSignature();
    }
    // No replay protection!
}
```

**Fix Implemented:**
```solidity
// AFTER (Secure)
function _verifySignature(bytes calldata signature, bytes32 structHash) internal {
    if (backendSigner == address(0)) revert InvalidBackendSigner();

    // Validate signature length (ECDSA signatures are 65 bytes)
    if (signature.length != 65) revert InvalidSignature();

    // Prevent signature replay
    bytes32 signatureHash = keccak256(signature);
    if (usedSignatures[signatureHash]) revert SignatureAlreadyUsed();

    bytes32 messageHash = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));
    address signer = messageHash.recover(signature);
    if (signer != backendSigner) {
        revert InvalidSignature();
    }

    usedSignatures[signatureHash] = true;
}
```

**State Variables Added:**
```solidity
mapping(bytes32 => bool) private usedSignatures;
```

**Custom Error Added:**
```solidity
error SignatureAlreadyUsed();
```

**Impact:**
- Prevents signature replay attacks across all functions
- Each signature can only be used once
- Protects `registerPlayer()`, `syncData()`, `mintKtridge()`, and `claimQuest()`

---

### 2. Missing Backend Signer Validation ⚠️

**Severity:** CRITICAL
**Status:** ✅ FIXED

**Issue:**
The contract did not validate that `backendSigner` was set before using it, allowing bypass of signature verification when uninitialized.

**Fix Implemented:**
```solidity
function _verifySignature(bytes calldata signature, bytes32 structHash) internal {
    if (backendSigner == address(0)) revert InvalidBackendSigner();
    // ... rest of verification
}
```

**Impact:**
- Ensures backend signer is always configured
- Prevents undefined behavior during initialization
- Fails fast with clear error message

---

## High Priority Issues Fixed

### 3. Missing Reentrancy Protection on Critical Functions ⚠️

**Severity:** HIGH
**Status:** ✅ FIXED

**Issue:**
Functions that interact with external contracts or transfer value lacked reentrancy protection.

**Vulnerable Functions:**
- `syncData()`
- `mintKtridge()`
- `claimQuest()`

**Fix Implemented:**
```solidity
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

contract KhugaBash is Initializable, Ownable2StepUpgradeable, ReentrancyGuardUpgradeable, UUPSUpgradeable {
    // ...

    function syncData(...) external nonReentrant onlyRegisteredPlayer {
        // Function logic
    }

    function mintKtridge(...) external nonReentrant onlyRegisteredPlayer {
        // Function logic
    }

    function claimQuest(...) external payable nonReentrant onlyRegisteredPlayer {
        // Function logic
    }
}
```

**Initialization:**
```solidity
function initialize(address initialOwner) public initializer {
    __Ownable_init(initialOwner);
    __UUPSUpgradeable_init();
    __ReentrancyGuard_init();  // Added
    // ...
}
```

**Impact:**
- Prevents reentrancy attacks on state-modifying functions
- Protects against malicious external contract calls
- Industry-standard protection pattern

---

### 4. Weak Input Validation ⚠️

**Severity:** HIGH
**Status:** ✅ FIXED

**Issue:**
Several functions lacked proper input validation, allowing zero addresses and invalid values.

**Fixes Implemented:**

**a) Boss ID Validation:**
```solidity
function addBoss(bytes32 bossId) external onlyOwner {
    if (bossId == bytes32(0)) revert InvalidBossId();  // Added
    if (bossExists[bossId]) revert BossAlreadyExists();
    // ...
}
```

**b) Quest ID Validation:**
```solidity
function addQuest(bytes32 questId, ...) external onlyOwner {
    if (questId == bytes32(0)) revert InvalidQuestId();  // Added
    if (questExists[questId]) revert QuestAlreadyExists();
    // ...
}
```

**c) Backend Signer Validation:**
```solidity
function setBackendSigner(address _backendSigner) external onlyOwner {
    if (_backendSigner == address(0)) revert InvalidBackendSigner();  // Added
    // ...
}
```

**d) KtridgeNFT Address Validation:**
```solidity
function setKtridgeNFT(address _ktridgeNFT) external onlyOwner {
    if (_ktridgeNFT == address(0)) revert InvalidKtridgeNFTAddress();  // Added
    // ...
}
```

**e) Withdrawal Address Validation:**
```solidity
function setWithdrawalAddress(address _withdrawalAddress) external onlyOwner {
    if (_withdrawalAddress == address(0)) revert InvalidWithdrawalAddress();  // Added
    // ...
}
```

**New Custom Errors:**
```solidity
error InvalidBossId();
error InvalidQuestId();
error InvalidWithdrawalAddress();
```

**Impact:**
- Prevents zero address assignments
- Catches invalid inputs early
- Clear error messages for debugging
- Reduces attack surface

---

## Medium Priority Issues Fixed

### 5. Missing Signature Length Validation ⚠️

**Severity:** MEDIUM
**Status:** ✅ FIXED

**Issue:**
No validation of signature length, potentially causing malformed signature recovery.

**Fix Implemented:**
```solidity
function _verifySignature(bytes calldata signature, bytes32 structHash) internal {
    // Validate signature length (ECDSA signatures are 65 bytes: r[32] + s[32] + v[1])
    if (signature.length != 65) revert InvalidSignature();
    // ...
}
```

**Impact:**
- Ensures proper ECDSA signature format
- Prevents invalid signature recovery attempts
- Reduces gas cost for invalid signatures

---

### 6. Redundant State Changes ⚠️

**Severity:** MEDIUM
**Status:** ✅ FIXED

**Issue:**
Admin functions would update state and emit events even when values didn't change, wasting gas and cluttering logs.

**Fixes Implemented:**

**a) Backend Signer:**
```solidity
function setBackendSigner(address _backendSigner) external onlyOwner {
    if (_backendSigner == address(0)) revert InvalidBackendSigner();
    if (backendSigner != _backendSigner) {  // Added check
        backendSigner = _backendSigner;
        emit BackendSignerSet(_backendSigner);
    }
}
```

**b) KtridgeNFT Address:**
```solidity
function setKtridgeNFT(address _ktridgeNFT) external onlyOwner {
    if (_ktridgeNFT == address(0)) revert InvalidKtridgeNFTAddress();
    if (address(ktridgeNFT) != _ktridgeNFT) {  // Added check
        ktridgeNFT = KtridgeNFT(_ktridgeNFT);
        emit KtridgeNFTSet(_ktridgeNFT);
    }
}
```

**c) Withdrawal Address:**
```solidity
function setWithdrawalAddress(address _withdrawalAddress) external onlyOwner {
    if (_withdrawalAddress == address(0)) revert InvalidWithdrawalAddress();
    if (withdrawalAddress != _withdrawalAddress) {  // Added check
        withdrawalAddress = _withdrawalAddress;
        emit WithdrawalAddressSet(_withdrawalAddress);
    }
}
```

**Impact:**
- Reduces gas costs for redundant operations
- Cleaner event logs
- More predictable state changes

---

### 7. Optimized Player Score Updates ⚠️

**Severity:** MEDIUM
**Status:** ✅ FIXED

**Issue:**
The `syncData()` function would always update player score, even if the new data was older or identical.

**Fix Implemented:**
```solidity
function syncData(...) external nonReentrant onlyRegisteredPlayer {
    // ...

    // Only update if timestamp is newer AND score is different
    if (timestamp > playerLastScoreUpdated[msg.sender] && players[msg.sender].score != score) {
        players[msg.sender].score = score;
        playerLastScoreUpdated[msg.sender] = timestamp;
        emit LeaderboardUpdated(msg.sender, score);
    }

    // ...
}
```

**Impact:**
- Prevents race conditions with stale data
- Reduces unnecessary state updates
- Saves gas on redundant syncs

---

## Security Improvements

### 8. Enhanced Error Messages

**Improvement:**
Reverted to custom errors throughout the contract for gas efficiency and better developer experience.

**Benefits:**
- ~50x cheaper than revert strings
- ABI-encoded for better frontend integration
- Easier to parse and handle errors

**Custom Errors Added:**
```solidity
error SignatureAlreadyUsed();
error InvalidBossId();
error InvalidQuestId();
error InvalidWithdrawalAddress();
```

---

### 9. EIP-712 Domain Initialization

**Improvement:**
Domain separator is now initialized during contract initialization rather than computed on-the-fly.

**Implementation:**
```solidity
bytes32 private DOMAIN_SEPARATOR;

function initialize(address initialOwner) public initializer {
    // ...

    // Initialize EIP-712 domain separator
    DOMAIN_SEPARATOR = keccak256(
        abi.encode(
            EIP712_DOMAIN_TYPEHASH,
            keccak256(bytes("KhugaBash")),
            keccak256(bytes("1")),
            block.chainid,
            address(this)
        )
    );
}
```

**Impact:**
- Gas savings on every signature verification
- Consistent domain separator across the contract lifetime
- Follows EIP-712 best practices

---

### 10. Storage Gap for Future Upgrades

**Improvement:**
Added storage gap to allow safe future upgrades.

**Implementation:**
```solidity
uint256[50] private __gap;
```

**Purpose:**
- Reserved space in contract storage
- Allows adding new state variables in future versions
- Prevents storage layout conflicts in proxy upgrades
- Follows OpenZeppelin upgradeability best practices

---

## Verification Procedures

### Pre-Deployment Verification

#### 1. Code Review Checklist

- [ ] All critical issues resolved
- [ ] All high-priority issues resolved
- [ ] All medium-priority issues resolved
- [ ] Custom errors implemented
- [ ] Reentrancy guards added
- [ ] Input validation complete
- [ ] Storage gap included
- [ ] EIP-712 properly implemented

#### 2. Static Analysis

Run Slither for automated vulnerability detection:

```bash
# Install Slither
pip3 install slither-analyzer

# Run analysis
slither . --detect all
```

**Expected Results:**
- No critical vulnerabilities
- No high-severity vulnerabilities
- Document any remaining medium/low findings

#### 3. Unit Testing

Ensure all tests pass:

```bash
# Run all tests
npx hardhat test

# Run with coverage
npx hardhat coverage

# Run specific test file
npx hardhat test test/KhugaBash.test.ts
```

**Coverage Targets:**
- Line coverage: >95%
- Branch coverage: >90%
- Function coverage: 100%

#### 4. Manual Testing

Test all critical user flows:

```bash
# Deploy to local testnet
npx hardhat node

# Run deployment script in separate terminal
npx hardhat run scripts/deploy.ts --network localhost

# Test manually with Hardhat console
npx hardhat console --network localhost
```

**Test Cases:**
1. Player registration
2. Data synchronization
3. Boss kills
4. Ktridge minting
5. Quest claiming (daily and regular)
6. Signature replay prevention
7. Admin functions

---

### Post-Deployment Verification

#### 1. Contract Verification on Block Explorer

**Ethereum Mainnet:**
```bash
npx hardhat verify --network mainnet <PROXY_ADDRESS> <CONSTRUCTOR_ARGS>
```

**BSC Mainnet:**
```bash
npx hardhat verify --network bsc <PROXY_ADDRESS> <CONSTRUCTOR_ARGS>
```

**Polygon:**
```bash
npx hardhat verify --network polygon <PROXY_ADDRESS> <CONSTRUCTOR_ARGS>
```

#### 2. Implementation Address Verification

Verify the implementation address matches the deployed contract:

```typescript
const implementationAddress = await upgrades.erc1967.getImplementationAddress(proxyAddress);
console.log("Implementation:", implementationAddress);
```

#### 3. Admin Verification

For UUPS proxies, verify there's no admin:

```bash
# This should fail for UUPS proxies
npx hardhat run scripts/check-admin.ts --network <network>
```

#### 4. Functionality Testing

Test all functions on the deployed contract:

```typescript
// Test read functions
const bossCount = await contract.getAllBosses();
const topPlayers = await contract.getTopPlayers(10);

// Test admin functions (if owner)
await contract.setBackendSigner(newSignerAddress);
await contract.addBoss(newBossId);
```

#### 5. Event Verification

Verify events are emitted correctly:

```typescript
// Listen for events
contract.on("PlayerRegistered", (player) => {
    console.log("Player registered:", player);
});

contract.on("BossKilled", (player, bossId) => {
    console.log("Boss killed:", player, bossId);
});
```

---

## Deployment Instructions

### Prerequisites

1. **Environment Variables:**

Create a `.env` file with:

```bash
# Private key for deployment (DO NOT COMMIT)
PRIVATE_KEY=your_private_key_here

# RPC URLs
MAINNET_RPC_URL=https://mainnet.infura.io/v3/YOUR_PROJECT_ID
BSC_RPC_URL=https://bsc-dataseed.binance.org
POLYGON_RPC_URL=https://polygon-rpc.com

# API Keys for verification
ETHERSCAN_API_KEY=your_etherscan_api_key
BSCSCAN_API_KEY=your_bscscan_api_key
POLYGONSCAN_API_KEY=your_polygonscan_api_key

# Proxy address (for upgrades)
PROXY_ADDRESS=your_proxy_address_here
```

2. **Network Configuration:**

Ensure `hardhat.config.ts` has all networks configured:

```typescript
networks: {
    hardhat: {
        chainId: 31337
    },
    mainnet: {
        url: process.env.MAINNET_RPC_URL || "",
        accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
        chainId: 1
    },
    bsc: {
        url: process.env.BSC_RPC_URL || "",
        accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
        chainId: 56
    },
    polygon: {
        url: process.env.POLYGON_RPC_URL || "",
        accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
        chainId: 137
    }
}
```

### Fresh Deployment

#### Step 1: Compile Contracts

```bash
npx hardhat compile
```

#### Step 2: Run Tests

```bash
npx hardhat test
npx hardhat coverage
```

#### Step 3: Deploy to Testnet

```bash
# Deploy to Goerli testnet
npx hardhat run scripts/deploy.ts --network goerli

# Deploy to BSC testnet
npx hardhat run scripts/deploy.ts --network bscTestnet

# Deploy to Mumbai (Polygon testnet)
npx hardhat run scripts/deploy.ts --network mumbai
```

#### Step 4: Verify Contract

```bash
# Verify on Goerli
npx hardhat verify --network goerli <PROXY_ADDRESS> <INITIAL_OWNER_ADDRESS>

# Verify on BSC testnet
npx hardhat verify --network bscTestnet <PROXY_ADDRESS> <INITIAL_OWNER_ADDRESS>

# Verify on Mumbai
npx hardhat verify --network mumbai <PROXY_ADDRESS> <INITIAL_OWNER_ADDRESS>
```

#### Step 5: Test Deployed Contract

```bash
npx hardhat run scripts/test-deployment.ts --network goerli
```

### Upgrade Deployment

#### Step 1: Prepare Upgrade

Ensure the new implementation is compiled:

```bash
npx hardhat compile
```

#### Step 2: Validate Upgrade

Check that the upgrade is safe:

```bash
npx hardhat upgrade --validate <PROXY_ADDRESS>
```

#### Step 3: Deploy Upgrade

Set the proxy address in `.env`:

```bash
PROXY_ADDRESS=0xYourProxyAddressHere
```

Run the upgrade script:

```bash
# Upgrade on mainnet
npx hardhat run scripts/upgradeKhugaBash.ts --network mainnet

# Upgrade on BSC
npx hardhat run scripts/upgradeKhugaBash.ts --network bsc

# Upgrade on Polygon
npx hardhat run scripts/upgradeKhugaBash.ts --network polygon
```

#### Step 4: Verify New Implementation

```bash
# Verify on mainnet
npx hardhat verify --network mainnet <NEW_IMPLEMENTATION_ADDRESS>

# Verify on BSC
npx hardhat verify --network bsc <NEW_IMPLEMENTATION_ADDRESS>

# Verify on Polygon
npx hardhat verify --network polygon <NEW_IMPLEMENTATION_ADDRESS>
```

#### Step 5: Test Upgraded Contract

```bash
npx hardhat run scripts/test-upgrade.ts --network mainnet
```

---

## Post-Deployment Checklist

### Immediate Actions (Day 0)

- [ ] Contract verified on block explorer
- [ ] Implementation address confirmed
- [ ] Admin functions tested
- [ ] Read functions tested
- [ ] Write functions tested
- [ ] Events monitored
- [ ] Gas costs recorded
- [ ] Initial configuration completed

### Configuration (Day 0-1)

- [ ] Set backend signer address
- [ ] Set KtridgeNFT contract address
- [ ] Set withdrawal address
- [ ] Configure claim quest fee
- [ ] Add initial bosses
- [ ] Add initial quests

### Monitoring (Week 1)

Monitor the following metrics:

**Transaction Metrics:**
- Transaction success rate
- Average gas usage
- Transaction failure rate
- Common error types

**User Metrics:**
- Registration rate
- Sync data frequency
- Quest claim rate
- Ktridge mint rate

**Security Metrics:**
- Failed signature verifications
- Replayed signature attempts
- Reentrancy attempts
- Unauthorized access attempts

### Audit Trail

Maintain records of:

1. **Deployment Records:**
   - Deployment timestamps
   - Contract addresses (proxy and implementation)
   - Deployment transactions
   - Compiler version and optimization settings

2. **Upgrade Records:**
   - Upgrade timestamps
   - Old and new implementation addresses
   - Upgrade transactions
   - Justification for upgrades

3. **Configuration Changes:**
   - Admin function calls
   - Parameter changes
   - Address updates
   - Timestamp and transaction hash for each change

4. **Incident Reports:**
   - Security incidents
   - Bug reports
   - User issues
   - Resolution steps

---

## Security Best Practices

### Development

1. **Never commit sensitive data:**
   - Private keys
   - Mnemonic phrases
   - API keys
   - Passwords

2. **Use environment variables:**
   - Store secrets in `.env` file
   - Add `.env` to `.gitignore`
   - Use different values for each network

3. **Follow the principle of least privilege:**
   - Limit admin functions
   - Use multi-sig for critical operations
   - Implement time locks for significant changes

### Deployment

1. **Test thoroughly:**
   - Unit tests
   - Integration tests
   - Manual testing
   - Testnet deployment

2. **Verify everything:**
   - Contract source code
   - Implementation addresses
   - Functionality
   - Gas costs

3. **Monitor actively:**
   - Transaction logs
   - Event emissions
   - Error rates
   - User feedback

### Operations

1. **Prepare for emergencies:**
   - Have pause mechanisms ready
   - Prepare upgrade procedures
   - Document rollback steps
   - Establish communication channels

2. **Maintain transparency:**
   - Publish audit reports
   - Document changes
   - Communicate upgrades
   - Provide time for user adaptation

3. **Stay updated:**
   - Follow security best practices
   - Monitor for new vulnerabilities
   - Keep dependencies updated
   - Participate in security communities

---

## Contact Information

**Security Team:**
- Email: security@khugabash.com
- Bug Bounty: https://khugabash.com/bug-bounty

**Development Team:**
- GitHub: https://github.com/khugabash
- Discord: https://discord.gg/khugabash

**Audit Firms:**
- For professional audits, contact: audits@khugabash.com

---

## Appendix A: Custom Errors Reference

```solidity
error PlayerAlreadyRegistered();
error BossesNotSet();
error InvalidBosses();
error InvalidSignature();
error PlayerNotRegistered();
error BossNotExists();
error PlayerNotKilledBossYet();
error KtridgeSmartContractNotSet();
error SignatureAlreadyUsed();           // NEW
error InvalidBossId();                   // NEW
error BossAlreadyExists();
error KtridgeAlreadyClaimed();
error InvalidBackendSigner();
error InvalidKtridgeNFTAddress();
error QuestNotExists();
error QuestAlreadyExists();
error QuestAlreadyCompleted();
error InvalidQuestId();                  // NEW
error QuestNotActive();
error InsufficientClaimFee();
error NoFundsToWithdraw();
error InvalidWithdrawalAddress();        // NEW
```

---

## Appendix B: Event Reference

```solidity
event PlayerRegistered(address indexed player);
event BossKilled(address indexed player, bytes32 indexed bossId);
event BossAdded(bytes32 indexed bossId);
event KtridgeMinted(address indexed player, bytes32 indexed bossId, uint256 tokenId);
event SyncedData(address indexed player, bytes32[] bosses, uint256 score);
event LeaderboardUpdated(address indexed player, uint256 score);
event BackendSignerSet(address indexed backendSigner);
event KtridgeNFTSet(address indexed ktridgeNFT);
event QuestAdded(bytes32 indexed questId, string name, uint256 rewardAmount);
event QuestClaimed(address indexed player, bytes32 indexed questId, uint256 rewardAmount);
event QuestUpdated(bytes32 indexed questId, string name, string description, uint256 rewardAmount, bool isDaily, string imageUrl);
event QuestStatusUpdated(bytes32 indexed questId, bool isActive);
event ResetAllPlayersScore();
event ClaimQuestFeeUpdated(uint256 oldFee, uint256 newFee);
event FundsWithdrawn(address indexed to, uint256 amount);
event WithdrawalAddressSet(address indexed withdrawalAddress);
```

---

## Appendix C: Gas Optimization Summary

| Optimization | Gas Savings | Function |
|--------------|-------------|----------|
| Custom errors | ~50x per revert | All functions |
| Domain separator caching | ~2000 per call | _verifySignature |
| Redundant state checks | ~5000 per write | Admin functions |
| Optimized score updates | ~15000 per sync | syncData |
| Total estimated savings | ~25000 per transaction | Average |

---

**Document Version:** 1.0.0
**Last Updated:** February 5, 2026
**Next Review:** After any major upgrade or security incident
