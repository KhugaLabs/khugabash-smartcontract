// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../lib/solady/src/utils/Initializable.sol";
import "../lib/solady/src/auth/Ownable.sol";
import "../lib/solady/src/utils/ReentrancyGuard.sol";
import "../lib/solady/src/utils/UUPSUpgradeable.sol";
import "../lib/solady/src/utils/SignatureCheckerLib.sol";
import "../lib/solady/src/tokens/ERC721.sol";
import "./KtridgeNFT.sol";

/**
 * @title KhugaBash
 * @dev Main contract for the Khuga Bash game, implementing score system, stat upgrades, and leaderboard
 * @notice This is the zkSync version of the contract, optimized for L2 execution and upgradeable
 */
contract KhugaBash is Initializable, Ownable, ReentrancyGuard, UUPSUpgradeable {
    using SignatureCheckerLib for address;

    // *******************************************
    // *                                         *
    // *               STRUCTS                   *
    // *                                         *
    // *******************************************
    struct Player {
        uint256 score;
        bool isRegistered;
    }

    struct LeaderboardEntry {
        address player;
        uint256 score;
    }

    // *******************************************
    // *                                         *
    // *           STATE VARIABLES               *
    // *                                         *
    // *******************************************
    address public backendSigner;
    uint256 private constant MAX_LEADERBOARD_SIZE = 100;

    address[] private playerAddresses;
    mapping(address => Player) private players;
    mapping(bytes32 => bool) private usedSignatures;

    bytes32[] private allBosses;
    mapping(bytes32 => bool) private bossExists;
    mapping(bytes32 => string) private bossNames;

    mapping(bytes32 => address[]) private bossKillers;
    mapping(address => bytes32[]) private playerKilledBosses;

    KtridgeNFT public ktridgeNFT;

    mapping(address => mapping(bytes32 => bool)) private hasClaimedKtridge;

    // *******************************************
    // *                                         *
    // *                EVENTS                   *
    // *                                         *
    // *******************************************// Events
    event PlayerRegistered(address indexed player);
    event BossKilled(address indexed player, bytes32 indexed bossId);
    event BossAdded(bytes32 indexed bossId);
    event KtridgeMinted(
        address indexed player,
        bytes32 indexed bossId,
        uint256 tokenId
    );
    event SyncedData(address indexed player, uint256[] bosses, uint256 score);
    event LeaderboardUpdated(address indexed player, uint256 score);
    event DebugBossId(uint256 originalId, bytes32 convertedId, bool exists);

    // *******************************************
    // *                                         *
    // *                ERRORS                   *
    // *                                         *
    // *******************************************
    error PlayerAlreadyRegistered();
    error BossesNotSet();
    error InvalidBosses();
    error InvalidSignature();
    error PlayerNotRegistered();
    error BossNotExists();
    error PlayerNotKilledBossYet();
    error KtridgeSmartContractNotSet();
    error SignatureAlreadyUsed();
    error BossAlreadyExists();
    error KtridgeAlreadyClaimed();

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        _initializeOwner(msg.sender);
    }

    // *******************************************
    // *                                         *
    // *            ADMIN FUNCTIONS              *
    // *                                         *
    // *******************************************
    /**
     * @notice Admin functions section
     * @param _backendSigner The address of the backend signer
     */
    function setBackendSigner(address _backendSigner) external onlyOwner {
        backendSigner = _backendSigner;
    }

    /**
     * @notice Sets the Ktridge NFT contract address
     * @param _ktridgeNFT The address of the Ktridge NFT contract
     */
    function setKtridgeNFT(address _ktridgeNFT) external onlyOwner {
        ktridgeNFT = KtridgeNFT(_ktridgeNFT);
    }

    /**
     * @notice Adds a new boss to the game
     * @param bossId The ID of the boss to add
     */
    function addBoss(bytes32 bossId) external onlyOwner {
        if (bossExists[bossId]) revert BossAlreadyExists();

        bossExists[bossId] = true;
        allBosses.push(bossId);

        emit BossAdded(bossId);
    }

    // *******************************************
    // *                                         *
    // *            READ FUNCTIONS               *
    // *                                         *
    // *******************************************
    /**
     * @notice Get the stats of a player
     * @param player The address of the player
     * @return The stats of the player
     */
    function getPlayerStats(
        address player
    ) external view returns (Player memory) {
        if (!players[player].isRegistered) revert PlayerNotRegistered();
        return players[player];
    }

    /**
     * @notice Get the top players
     * @param limit The limit of players to get
     * @return The top players
     */
    function getTopPlayers(
        uint256 limit
    ) external view returns (LeaderboardEntry[] memory) {
        uint256 size = playerAddresses.length;
        uint256 resultSize = size < limit ? size : limit;
        resultSize = resultSize < MAX_LEADERBOARD_SIZE
            ? resultSize
            : MAX_LEADERBOARD_SIZE;

        LeaderboardEntry[] memory topPlayers = new LeaderboardEntry[](
            resultSize
        );

        // Create initial array
        for (uint256 i = 0; i < resultSize; i++) {
            topPlayers[i] = LeaderboardEntry({
                player: playerAddresses[i],
                score: players[playerAddresses[i]].score
            });
        }

        // Simple bubble sort (can be optimized for production)
        for (uint256 i = 0; i < resultSize - 1; i++) {
            for (uint256 j = 0; j < resultSize - i - 1; j++) {
                if (topPlayers[j].score < topPlayers[j + 1].score) {
                    LeaderboardEntry memory temp = topPlayers[j];
                    topPlayers[j] = topPlayers[j + 1];
                    topPlayers[j + 1] = temp;
                }
            }
        }

        return topPlayers;
    }

    /**
     * @notice Get all bosses that a player has killed
     * @param player The address of the player
     * @return The bosses that the player has killed
     */
    function getPlayerKilledBosses(
        address player
    ) external view returns (bytes32[] memory) {
        if (!players[player].isRegistered) revert PlayerNotRegistered();
        return playerKilledBosses[player];
    }

    /**
     * @notice Get all players that killed a specific boss
     * @param bossId The ID of the boss
     * @return The players that killed the boss
     */
    function getBossKillers(
        bytes32 bossId
    ) external view returns (address[] memory) {
        if (!bossExists[bossId]) revert BossNotExists();
        return bossKillers[bossId];
    }

    /**
     * @notice Get all registered bosses
     * @return The registered bosses
     */
    function getAllBosses() external view returns (bytes32[] memory) {
        return allBosses;
    }

    /**
     * @notice Check if a player has killed a specific boss
     * @param player The address of the player
     * @param bossId The ID of the boss
     * @return The result of the check
     */
    function hasPlayerKilledBoss(
        address player,
        bytes32 bossId
    ) public view returns (bool) {
        if (!players[player].isRegistered || !bossExists[bossId]) return false;

        for (uint256 i = 0; i < playerKilledBosses[player].length; i++) {
            if (playerKilledBosses[player][i] == bossId) {
                return true;
            }
        }

        return false;
    }

    // *******************************************
    // *                                         *
    // *            WRITE FUNCTIONS              *
    // *                                         *
    // *******************************************
    /**
     * @notice Register a player
     * @param signature The signature of the player
     */
    function registerPlayer(bytes calldata signature) external {
        if (players[msg.sender].isRegistered) revert PlayerAlreadyRegistered();

        // check signature
        bytes32 messageHash = keccak256(abi.encodePacked(msg.sender));
        if (!backendSigner.isValidSignatureNowCalldata(messageHash, signature))
            revert InvalidSignature();

        players[msg.sender] = Player({score: 0, isRegistered: true});
        playerAddresses.push(msg.sender);

        emit PlayerRegistered(msg.sender);
    }

    /**
     * @notice Sync data from the backend
     * @param _bossIds The IDs of the bosses
     * @param score The score of the player
     * @param signature The signature of the player
     */
    function syncData(
        uint256[] calldata _bossIds,
        uint256 score,
        bytes calldata signature
    ) external {
        if (!players[msg.sender].isRegistered) revert PlayerNotRegistered();
        if (allBosses.length == 0) revert BossesNotSet();

        // Verify signature first
        bytes32 signatureHash = keccak256(signature);
        if (usedSignatures[signatureHash]) revert SignatureAlreadyUsed();

        // Check signature
        bytes32 messageHash = keccak256(
            abi.encodePacked(msg.sender, _bossIds, score)
        );
        if (!backendSigner.isValidSignatureNowCalldata(messageHash, signature))
            revert InvalidSignature();

        // Mark signature as used
        usedSignatures[signatureHash] = true;

        // Update player score
        players[msg.sender].score = score;

        // For each boss that player has not killed, add to player killed bosses
        for (uint256 i = 0; i < _bossIds.length; i++) {
            // Convert uint256 to bytes32 properly
            bytes32 bossId = bytes32(_bossIds[i]);

            // Add a debug event to help troubleshoot
            emit DebugBossId(_bossIds[i], bossId, bossExists[bossId]);

            if (!bossExists[bossId]) {
                revert InvalidBosses();
            }

            if (!hasPlayerKilledBoss(msg.sender, bossId)) {
                playerKilledBosses[msg.sender].push(bossId);
                bossKillers[bossId].push(msg.sender);
            }
        }

        emit SyncedData(msg.sender, _bossIds, score);
        emit LeaderboardUpdated(msg.sender, score);
    }

    /**
     * @notice Mint a Ktridge NFT
     * @param bossId The ID of the boss
     * @param signature The signature of the player
     */
    function mintKtridge(
        bytes32 bossId,
        bytes calldata signature
    ) external nonReentrant {
        // Check if player is registered
        if (!players[msg.sender].isRegistered) revert PlayerNotRegistered();

        // Check if player has already claimed an NFT for this boss
        if (hasClaimedKtridge[msg.sender][bossId])
            revert KtridgeAlreadyClaimed();

        // Check if player has killed the boss - use the existing hasPlayerKilledBoss function
        if (!hasPlayerKilledBoss(msg.sender, bossId))
            revert PlayerNotKilledBossYet();

        if (address(ktridgeNFT) == address(0))
            revert KtridgeSmartContractNotSet();

        // Prevent signature reuse
        bytes32 signatureHash = keccak256(signature);
        if (usedSignatures[signatureHash]) revert SignatureAlreadyUsed();

        // check signature
        bytes32 messageHash = keccak256(abi.encodePacked(msg.sender, bossId));
        if (
            !backendSigner.isValidSignatureNowCalldata(messageHash, signature)
        ) {
            revert InvalidSignature();
        }

        // Mark signature as used
        usedSignatures[signatureHash] = true;

        // Mark this boss kill as claimed
        hasClaimedKtridge[msg.sender][bossId] = true;

        // Mint the NFT
        uint256 tokenId = ktridgeNFT.mintKtridge(msg.sender, bossId);

        emit KtridgeMinted(msg.sender, bossId, tokenId);
    }

    /**
     * @notice Required override for UUPS proxy pattern
     * @param newImplementation The address of the new implementation
     */
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}
}
