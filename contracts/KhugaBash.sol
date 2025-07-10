// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./KtridgeNFT.sol";

contract KhugaBash is Initializable, Ownable2StepUpgradeable, ReentrancyGuard, UUPSUpgradeable {
    using SignatureChecker for address;

    // ═══════════════════════════════════════════════════════════════════════════════════
    // STRUCTS
    // ═══════════════════════════════════════════════════════════════════════════════════

    struct Player {
        uint256 score;
        bool isRegistered;
    }

    struct LeaderboardEntry {
        address player;
        uint256 score;
    }

    struct Quest {
        bytes32 id;
        string name;
        string description;
        uint256 rewardAmount;
        bool isActive;
        bool isDaily;
    }

    // ═══════════════════════════════════════════════════════════════════════════════════
    // STATE VARIABLES
    // ═══════════════════════════════════════════════════════════════════════════════════

    address public backendSigner;
    uint256 private constant MAX_LEADERBOARD_SIZE = 100;
    KtridgeNFT public ktridgeNFT;

    // Player data
    address[] private playerAddresses;
    mapping(address => Player) private players;
    mapping(address => uint256) private playerLastScoreUpdated;

    // Signature management
    mapping(bytes32 => bool) private usedSignatures;

    // Boss system
    bytes32[] private allBosses;
    mapping(bytes32 => bool) private bossExists;
    mapping(bytes32 => address[]) private bossKillers;
    mapping(address => bytes32[]) private playerKilledBosses;
    mapping(address => mapping(bytes32 => bool)) private playerHasKilledBoss;
    mapping(address => mapping(bytes32 => bool)) private hasClaimedKtridge;

    // Quest system
    bytes32[] private allQuests;
    mapping(bytes32 => Quest) private quests;
    mapping(bytes32 => bool) private questExists;
    mapping(address => bytes32[]) private playerCompletedQuests;
    mapping(address => mapping(bytes32 => bool)) private playerHasCompletedQuest;
    mapping(address => mapping(bytes32 => uint256)) private playerLastDailyClaimDay;

    // ═══════════════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════════════

    event PlayerRegistered(address indexed player);
    event BossKilled(address indexed player, bytes32 indexed bossId);
    event BossAdded(bytes32 indexed bossId);
    event KtridgeMinted(address indexed player, bytes32 indexed bossId, uint256 tokenId);
    event SyncedData(address indexed player, bytes32[] bosses, uint256 score);
    event LeaderboardUpdated(address indexed player, uint256 score);
    event BackendSignerSet(address indexed backendSigner);
    event KtridgeNFTSet(address indexed ktridgeNFT);
    event QuestAdded(bytes32 indexed questId, string name, uint256 rewardAmount);
    event QuestCompleted(address indexed player, bytes32 indexed questId, uint256 rewardAmount);
    event QuestUpdated(bytes32 indexed questId, bool isActive);

    // ═══════════════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════════════════

    error PlayerAlreadyRegistered();
    error BossesNotSet();
    error InvalidBosses();
    error InvalidSignature();
    error PlayerNotRegistered();
    error BossNotExists();
    error PlayerNotKilledBossYet();
    error KtridgeSmartContractNotSet();
    error SignatureAlreadyUsed();
    error InvalidBossId();
    error BossAlreadyExists();
    error KtridgeAlreadyClaimed();
    error InvalidBackendSigner();
    error InvalidKtridgeNFTAddress();
    error QuestNotExists();
    error QuestAlreadyExists();
    error QuestAlreadyCompleted();
    error InvalidQuestId();
    error QuestNotActive();

    // ═══════════════════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR & INITIALIZATION
    // ═══════════════════════════════════════════════════════════════════════════════════

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
    }

    // ═══════════════════════════════════════════════════════════════════════════════════
    // MODIFIERS
    // ═══════════════════════════════════════════════════════════════════════════════════

    /**
     * @notice Modifier to check if the player is registered
     */
    modifier onlyRegisteredPlayer() {
        if (!players[msg.sender].isRegistered) revert PlayerNotRegistered();
        _;
    }

    // ═══════════════════════════════════════════════════════════════════════════════════
    // INTERNAL FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════════════

    /**
     * @notice Internal function to verify the signature
     * @param signature The signature to verify
     * @param messageHash The message hash to verify
     */
    function _verifySignature(bytes calldata signature, bytes32 messageHash) internal {
        if (backendSigner == address(0)) revert InvalidBackendSigner();
        bytes32 signatureHash = keccak256(signature);
        if (usedSignatures[signatureHash]) revert SignatureAlreadyUsed();
        if (!SignatureChecker.isValidSignatureNow(backendSigner, messageHash, signature)) revert InvalidSignature();
        usedSignatures[signatureHash] = true;
    }

    // ═══════════════════════════════════════════════════════════════════════════════════
    // ADMIN FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════════════

    /**
     * @notice Set the backend signer
     * @param _backendSigner The address of the backend signer
     */
    function setBackendSigner(address _backendSigner) external onlyOwner {
        if (_backendSigner == address(0)) revert InvalidBackendSigner();
        if (backendSigner != _backendSigner) {
            backendSigner = _backendSigner;
            emit BackendSignerSet(_backendSigner);
        }
    }

    /**
     * @notice Set the KtridgeNFT contract
     * @param _ktridgeNFT The address of the KtridgeNFT contract
     */
    function setKtridgeNFT(address _ktridgeNFT) external onlyOwner {
        if (_ktridgeNFT == address(0)) revert InvalidKtridgeNFTAddress();
        if (address(ktridgeNFT) != _ktridgeNFT) {
            ktridgeNFT = KtridgeNFT(_ktridgeNFT);
            emit KtridgeNFTSet(_ktridgeNFT);
        }
    }

    /**
     * @notice Add a boss
     * @param bossId The ID of the boss
     */
    function addBoss(bytes32 bossId) external onlyOwner {
        if (bossId == bytes32(0)) revert InvalidBossId();
        if (bossExists[bossId]) revert BossAlreadyExists();
        bossExists[bossId] = true;
        allBosses.push(bossId);
        emit BossAdded(bossId);
    }

    /**
     * @notice Add a quest
     * @param questId The ID of the quest
     * @param name The name of the quest
     * @param description The description of the quest
     * @param rewardAmount The reward amount of the quest
     * @param isDaily Whether the quest is daily
     */
    function addQuest(bytes32 questId, string calldata name, string calldata description, uint256 rewardAmount, bool isDaily) external onlyOwner {
        if (questId == bytes32(0)) revert InvalidQuestId();
        if (questExists[questId]) revert QuestAlreadyExists();
        quests[questId] = Quest(questId, name, description, rewardAmount, true, isDaily);
        questExists[questId] = true;
        allQuests.push(questId);
        emit QuestAdded(questId, name, rewardAmount);
    }

    /**
     * @notice Update the status of a quest
     * @param questId The ID of the quest
     * @param isActive Whether the quest is active
     */
    function updateQuestStatus(bytes32 questId, bool isActive) external onlyOwner {
        if (!questExists[questId]) revert QuestNotExists();
        quests[questId].isActive = isActive;
        emit QuestUpdated(questId, isActive);
    }

    /**
     * @notice Reset the score of all players
     */
    function resetAllPlayersScore() external onlyOwner {
        uint256 currentTimestamp = block.timestamp;
        for (uint256 i = 0; i < playerAddresses.length; i++) {
            address playerAddr = playerAddresses[i];
            if (players[playerAddr].score > 0) {
                players[playerAddr].score = 0;
                playerLastScoreUpdated[playerAddr] = currentTimestamp;
                emit LeaderboardUpdated(playerAddr, 0);
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS - PLAYER DATA
    // ═══════════════════════════════════════════════════════════════════════════════════

    /**
     * @notice Get the stats of a player
     * @param player The address of the player
     * @return The stats of the player
     */
    function getPlayerStats(address player) external view returns (Player memory) {
        if (!players[player].isRegistered) revert PlayerNotRegistered();
        return players[player];
    }

    /**
     * @notice Get the last score updated of a player
     * @param player The address of the player
     * @return The last score updated of the player
     */
    function getPlayerLastScoreUpdated(address player) external view returns (uint256) {
        if (!players[player].isRegistered) revert PlayerNotRegistered();
        return playerLastScoreUpdated[player];
    }

    /**
     * @notice Get the bosses killed by a player
     * @param player The address of the player
     * @return The bosses killed by the player
     */
    function getPlayerKilledBosses(address player) external view returns (bytes32[] memory) {
        if (!players[player].isRegistered) revert PlayerNotRegistered();
        return playerKilledBosses[player];
    }

    /**
     * @notice Get the quests completed by a player
     * @param player The address of the player
     * @return The quests completed by the player
     */
    function getPlayerCompletedQuests(address player) external view returns (bytes32[] memory) {
        if (!players[player].isRegistered) revert PlayerNotRegistered();
        return playerCompletedQuests[player];
    }

    /**
     * @notice Get the daily quests completed by a player
     * @param player The address of the player
     * @return The daily quests completed by the player
     */
    function getPlayerCompletedDailyQuests(address player) external view returns (bytes32[] memory) {
        if (!players[player].isRegistered) revert PlayerNotRegistered();

        bytes32[] memory completedQuests = new bytes32[](allQuests.length);
        uint256 completedCount = 0;

        for (uint256 i = 0; i < allQuests.length; i++) {
            bytes32 questId = allQuests[i];
            // if quest is daily and lastclaim day is today, put to temporary array
            if (quests[questId].isDaily && block.timestamp / 1 days == playerLastDailyClaimDay[player][questId]) {
                completedQuests[completedCount] = questId;
                completedCount++;
            }
        }

        bytes32[] memory result = new bytes32[](completedCount);
        for (uint256 i = 0; i < completedCount; i++) {
            result[i] = completedQuests[i];
        }
        return result;
    }

    // ═══════════════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS - LEADERBOARD
    // ═══════════════════════════════════════════════════════════════════════════════════

    /**
     * @notice Get the top players
     * @param limit The limit of the top players
     * @return The top players
     */
    function getTopPlayers(uint256 limit) external view returns (LeaderboardEntry[] memory) {
        uint256 size = playerAddresses.length;
        uint256 resultSize = size < limit ? size : limit;
        if (resultSize > MAX_LEADERBOARD_SIZE) resultSize = MAX_LEADERBOARD_SIZE;
        if (resultSize == 0) return new LeaderboardEntry[](0);

        LeaderboardEntry[] memory allPlayers = new LeaderboardEntry[](size);
        for (uint256 i = 0; i < size; i++) {
            address playerAddr = playerAddresses[i];
            allPlayers[i] = LeaderboardEntry(playerAddr, players[playerAddr].score);
        }

        for (uint256 i = 0; i < resultSize; i++) {
            uint256 highestIndex = i;
            uint256 highestScore = allPlayers[i].score;
            for (uint256 j = i + 1; j < size; j++) {
                if (allPlayers[j].score > highestScore) {
                    highestIndex = j;
                    highestScore = allPlayers[j].score;
                }
            }
            if (highestIndex != i) {
                LeaderboardEntry memory temp = allPlayers[i];
                allPlayers[i] = allPlayers[highestIndex];
                allPlayers[highestIndex] = temp;
            }
        }

        LeaderboardEntry[] memory topPlayers = new LeaderboardEntry[](resultSize);
        for (uint256 i = 0; i < resultSize; i++) {
            topPlayers[i] = allPlayers[i];
        }
        return topPlayers;
    }

    // ═══════════════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS - BOSS SYSTEM
    // ═══════════════════════════════════════════════════════════════════════════════════

    /**
     * @notice Get all bosses
     * @return All bosses
     */
    function getAllBosses() external view returns (bytes32[] memory) {
        return allBosses;
    }

    /**
     * @notice Get the killers of a boss
     * @param bossId The ID of the boss
     * @return The killers of the boss
     */
    function getBossKillers(bytes32 bossId) external view returns (address[] memory) {
        if (!bossExists[bossId]) revert BossNotExists();
        return bossKillers[bossId];
    }

    /**
     * @notice Check if a player has killed a boss
     * @param player The address of the player
     * @param bossId The ID of the boss
     * @return True if the player has killed the boss, false otherwise
     */
    function hasPlayerKilledBoss(address player, bytes32 bossId) public view returns (bool) {
        return players[player].isRegistered && bossExists[bossId] && playerHasKilledBoss[player][bossId];
    }

    /**
     * @notice Check if a boss exists
     * @param bossId The ID of the boss
     * @return True if the boss exists, false otherwise
     */
    function checkBossExists(bytes32 bossId) external view returns (bool) {
        return bossExists[bossId];
    }

    // ═══════════════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS - QUEST SYSTEM
    // ═══════════════════════════════════════════════════════════════════════════════════

    /**
     * @notice Get all quests
     * @return All quests
     */
    function getAllQuests() external view returns (bytes32[] memory) {
        return allQuests;
    }

    /**
     * @notice Get the details of a quest
     * @param questId The ID of the quest
     * @return The details of the quest
     */
    function getQuestDetails(bytes32 questId) external view returns (Quest memory) {
        if (!questExists[questId]) revert QuestNotExists();
        return quests[questId];
    }

    /**
     * @notice Check if a quest is active
     * @param questId The ID of the quest
     * @return True if the quest is active, false otherwise
     */
    function isQuestActive(bytes32 questId) external view returns (bool) {
        return questExists[questId] && quests[questId].isActive;
    }

    /**
     * @notice Check if a player can claim a quest
     * @param player The address of the player
     * @param questId The ID of the quest
     * @return True if the player can claim the quest, false otherwise
     */
    function canClaimQuest(address player, bytes32 questId) external view returns (bool) {
        if (!players[player].isRegistered || !questExists[questId] || !quests[questId].isActive) return false;
        return quests[questId].isDaily ? block.timestamp / 1 days > playerLastDailyClaimDay[player][questId] : !playerHasCompletedQuest[player][questId];
    }

    // ═══════════════════════════════════════════════════════════════════════════════════
    // WRITE FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════════════

    /**
     * @notice Register a player
     * @param signature The signature of the player
     */
    function registerPlayer(bytes calldata signature) external {
        if (players[msg.sender].isRegistered) revert PlayerAlreadyRegistered();
        bytes32 messageHash = keccak256(abi.encodePacked(bytes4(keccak256("registerPlayer(address)")), msg.sender));
        _verifySignature(signature, messageHash);

        players[msg.sender] = Player(0, true);
        playerAddresses.push(msg.sender);
        playerLastScoreUpdated[msg.sender] = block.timestamp;
        emit PlayerRegistered(msg.sender);
    }

    /**
     * @notice Sync the data of a player
     * @param _bossIds The IDs of the bosses killed by the player
     * @param score The score of the player
     * @param timestamp The timestamp of the last score update
     * @param signature The signature of the player
     */
    function syncData(
        bytes32[] calldata _bossIds,
        uint256 score,
        uint256 timestamp,
        bytes calldata signature
    ) external nonReentrant onlyRegisteredPlayer {
        if (allBosses.length == 0) revert BossesNotSet();
        bytes32 messageHash = keccak256(abi.encodePacked(
            bytes4(keccak256("syncData(address,bytes32[],uint256,uint256)")),
            msg.sender, _bossIds, score, timestamp
        ));
        _verifySignature(signature, messageHash);

        if (timestamp > playerLastScoreUpdated[msg.sender] && players[msg.sender].score != score) {
            players[msg.sender].score = score;
            playerLastScoreUpdated[msg.sender] = timestamp;
            emit LeaderboardUpdated(msg.sender, score);
        }

        // Process boss kills
        for (uint256 i = 0; i < _bossIds.length; i++) {
            bytes32 bossId = _bossIds[i];
            if (!bossExists[bossId]) revert InvalidBosses();
            if (!playerHasKilledBoss[msg.sender][bossId]) {
                playerKilledBosses[msg.sender].push(bossId);
                bossKillers[bossId].push(msg.sender);
                playerHasKilledBoss[msg.sender][bossId] = true;
                emit BossKilled(msg.sender, bossId);
            }
        }
        emit SyncedData(msg.sender, _bossIds, score);
    }

    /**
     * @notice Mint a Ktridge
     * @param bossId The ID of the boss
     * @param signature The signature of the player
     */
    function mintKtridge(bytes32 bossId, bytes calldata signature) external nonReentrant onlyRegisteredPlayer {
        if (hasClaimedKtridge[msg.sender][bossId]) revert KtridgeAlreadyClaimed();
        if (!hasPlayerKilledBoss(msg.sender, bossId)) revert PlayerNotKilledBossYet();
        if (address(ktridgeNFT) == address(0)) revert KtridgeSmartContractNotSet();
        
        bytes32 messageHash = keccak256(abi.encodePacked(
            bytes4(keccak256("mintKtridge(address,bytes32)")), 
            msg.sender, 
            bossId
        ));
        _verifySignature(signature, messageHash);

        hasClaimedKtridge[msg.sender][bossId] = true;
        uint256 tokenId = ktridgeNFT.mintKtridge(msg.sender, bossId);
        emit KtridgeMinted(msg.sender, bossId, tokenId);
    }

    /**
     * @notice Claim a quest
     * @param questId The ID of the quest
     * @param signature The signature of the player
     */
    function claimQuest(bytes32 questId, bytes calldata signature) external nonReentrant onlyRegisteredPlayer {
        if (!questExists[questId]) revert QuestNotExists();
        
        Quest memory quest = quests[questId];
        if (!quest.isActive) revert QuestNotActive();

        if (quest.isDaily) {
            if (block.timestamp / 1 days == playerLastDailyClaimDay[msg.sender][questId]) revert QuestAlreadyCompleted();
        } else {
            if (playerHasCompletedQuest[msg.sender][questId]) revert QuestAlreadyCompleted();
        }

        bytes32 messageHash = keccak256(abi.encodePacked(
            bytes4(keccak256("claimQuest(address,bytes32)")), msg.sender, questId
        ));
        _verifySignature(signature, messageHash);

        if (quest.isDaily) {
            playerLastDailyClaimDay[msg.sender][questId] = block.timestamp / 1 days;
        } else {
            playerHasCompletedQuest[msg.sender][questId] = true;
            playerCompletedQuests[msg.sender].push(questId);
        }

        players[msg.sender].score += quest.rewardAmount;
        playerLastScoreUpdated[msg.sender] = block.timestamp;

        emit QuestCompleted(msg.sender, questId, quest.rewardAmount);
        emit LeaderboardUpdated(msg.sender, players[msg.sender].score);
    }

    // ═══════════════════════════════════════════════════════════════════════════════════
    // UPGRADE FUNCTION
    // ═══════════════════════════════════════════════════════════════════════════════════

    /**
     * @notice Authorize the upgrade of the contract
     * @param newImplementation The address of the new implementation
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
} 