// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title GemPurchase
 * @dev Smart contract for purchasing gems with ETH
 * Fixed rate: 1 gem = 0.0005 ETH (2000 gems per ETH)
 */
contract GemPurchase is Ownable, ReentrancyGuard, Pausable {
    // Constants
    uint256 public constant GEM_PRICE_WEI = 0.0005 ether; // 0.0005 ETH per gem
    uint256 public constant MIN_PURCHASE = 1; // Minimum 1 gem
    uint256 public constant MAX_PURCHASE = 1000; // Maximum 1000 gems per transaction
    
    // State variables
    mapping(address => uint256) public totalGemsPurchased;
    mapping(address => uint256) public totalEthSpent;
    uint256 public totalGemsSold;
    uint256 public totalEthCollected;
    address public treasuryWallet;
    
    // Events
    event GemsPurchased(
        address indexed buyer,
        uint256 gemsAmount,
        uint256 ethAmount,
        uint256 timestamp
    );
    
    event TreasuryWalletUpdated(
        address indexed oldWallet,
        address indexed newWallet
    );
    
    event EmergencyWithdraw(
        address indexed to,
        uint256 amount
    );
    
    // Custom errors
    error InvalidGemAmount();
    error InsufficientEthSent();
    error ExcessEthSent();
    error InvalidTreasuryWallet();
    error TransferFailed();
    
    /**
     * @dev Constructor
     * @param _treasuryWallet Address to receive ETH payments
     */
    constructor(address _treasuryWallet) {
        if (_treasuryWallet == address(0)) revert InvalidTreasuryWallet();
        treasuryWallet = _treasuryWallet;
    }
    
    /**
     * @dev Purchase gems with ETH
     * @param gemAmount Number of gems to purchase
     */
    function purchaseGems(uint256 gemAmount) external payable nonReentrant whenNotPaused {
        // Validate gem amount
        if (gemAmount < MIN_PURCHASE || gemAmount > MAX_PURCHASE) {
            revert InvalidGemAmount();
        }
        
        // Calculate required ETH
        uint256 requiredEth = gemAmount * GEM_PRICE_WEI;
        
        // Check if enough ETH was sent
        if (msg.value < requiredEth) {
            revert InsufficientEthSent();
        }
        
        // Check if too much ETH was sent (prevent accidental overpayment)
        if (msg.value > requiredEth) {
            revert ExcessEthSent();
        }
        
        // Update state
        totalGemsPurchased[msg.sender] += gemAmount;
        totalEthSpent[msg.sender] += msg.value;
        totalGemsSold += gemAmount;
        totalEthCollected += msg.value;
        
        // Transfer ETH to treasury
        (bool success, ) = treasuryWallet.call{value: msg.value}("");
        if (!success) revert TransferFailed();
        
        // Emit event
        emit GemsPurchased(msg.sender, gemAmount, msg.value, block.timestamp);
    }
    
    /**
     * @dev Calculate ETH cost for a given number of gems
     * @param gemAmount Number of gems
     * @return ethCost Cost in wei
     */
    function calculateEthCost(uint256 gemAmount) external pure returns (uint256 ethCost) {
        return gemAmount * GEM_PRICE_WEI;
    }
    
    /**
     * @dev Calculate gem amount for a given ETH amount
     * @param ethAmount Amount of ETH in wei
     * @return gemAmount Number of gems
     */
    function calculateGemAmount(uint256 ethAmount) external pure returns (uint256 gemAmount) {
        return ethAmount / GEM_PRICE_WEI;
    }
    
    /**
     * @dev Get purchase history for a user
     * @param user User address
     * @return gemsPurchased Total gems purchased
     * @return ethSpent Total ETH spent
     */
    function getUserPurchaseHistory(address user) 
        external 
        view 
        returns (uint256 gemsPurchased, uint256 ethSpent) 
    {
        return (totalGemsPurchased[user], totalEthSpent[user]);
    }
    
    /**
     * @dev Get contract statistics
     * @return gemsSold Total gems sold
     * @return ethCollected Total ETH collected
     */
    function getContractStats() 
        external 
        view 
        returns (uint256 gemsSold, uint256 ethCollected) 
    {
        return (totalGemsSold, totalEthCollected);
    }
    
    // Admin functions
    
    /**
     * @dev Update treasury wallet (only owner)
     * @param _newTreasuryWallet New treasury wallet address
     */
    function updateTreasuryWallet(address _newTreasuryWallet) external onlyOwner {
        if (_newTreasuryWallet == address(0)) revert InvalidTreasuryWallet();
        
        address oldWallet = treasuryWallet;
        treasuryWallet = _newTreasuryWallet;
        
        emit TreasuryWalletUpdated(oldWallet, _newTreasuryWallet);
    }
    
    /**
     * @dev Pause the contract (only owner)
     */
    function pause() external onlyOwner {
        _pause();
    }
    
    /**
     * @dev Unpause the contract (only owner)
     */
    function unpause() external onlyOwner {
        _unpause();
    }
    
    /**
     * @dev Emergency withdraw function (only owner)
     * @param to Address to send ETH to
     */
    function emergencyWithdraw(address to) external onlyOwner {
        if (to == address(0)) revert InvalidTreasuryWallet();
        
        uint256 balance = address(this).balance;
        (bool success, ) = to.call{value: balance}("");
        if (!success) revert TransferFailed();
        
        emit EmergencyWithdraw(to, balance);
    }
    
    /**
     * @dev Fallback function to prevent accidental ETH sends
     */
    receive() external payable {
        revert("Use purchaseGems function");
    }
    
    /**
     * @dev Fallback function to prevent accidental calls
     */
    fallback() external payable {
        revert("Function not found");
    }
}