// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../lib/solady/src/utils/Initializable.sol";
import "../lib/solady/src/auth/Ownable.sol";
import "../lib/solady/src/utils/ReentrancyGuard.sol";
import "../lib/solady/src/utils/UUPSUpgradeable.sol";
import "../lib/solady/src/utils/SignatureCheckerLib.sol";
import "../lib/solady/src/tokens/ERC721.sol";
import "./CatridgeNFT.sol";

/**
 * @title KhugaBash
 * @dev Main contract for the Khuga Bash game, implementing score system, stat upgrades, and leaderboard
 * @notice This is the zkSync version of the contract, optimized for L2 execution and upgradeable
 */
contract KhugaBash is
    Initializable,
    Ownable,
    ReentrancyGuard,
    UUPSUpgradeable
{
    // *******************************************
    // *                                         *
    // *               STRUCTS                   *
    // *                                         *
    // *******************************************
    struct Player {
        uint256 score;
        uint256 nonce;
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
    uint256 private constant SCORE_PER_GAME = 10;

    address[] private playerAddresses;
    mapping(address => Player) private players;
    
    bytes32[] private allBosses;
    mapping(bytes32 => bool) private bossExists;
    mapping(bytes32 => string) private bossNames;

    mapping(bytes32 => address[]) private bossKillers;
    mapping(address => bytes32[]) private playerKilledBosses;

    CatridgeNFT public catridgeNFT;

    // *******************************************
    // *                                         *
    // *                EVENTS                   *
    // *                                         *
    // *******************************************// Events
    event PlayerRegistered(address indexed player, uint256 nonce);
    event ScoreEarned(address indexed player, uint256 score);
    event ScoreUpdated(uint256 score, uint256 nonce);
    event LeaderboardUpdated(address indexed player, uint256 score);
    event BossKilled(address indexed player, bytes32 indexed bossId);
    event BossAdded(bytes32 indexed bossId);
    event CatridgeMinted(address indexed player, bytes32 indexed bossId, uint256 tokenId);
    event SyncedData(address indexed player, uint256[] bosses, uint256 score, uint256 nonce);

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
    error CatridgeSmartContractNotSet();

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
    function setBackendSigner(address _backendSigner) external onlyOwner {
        backendSigner = _backendSigner;
    }

    function setCatridgeNFT(address _catridgeNFT) external onlyOwner {
        catridgeNFT = CatridgeNFT(_catridgeNFT);
    }

    function setPlayerNonce(address player, uint256 nonce) external onlyOwner {
        players[player].nonce = nonce;
    }

    function addBoss(bytes32 bossId) external onlyOwner {
        if (bossExists[bossId]) return;
        
        bossExists[bossId] = true;
        allBosses.push(bossId);
        
        emit BossAdded(bossId);
    }

    function awardScore(address player, uint256 multiplier) external onlyOwner {
        require(players[player].isRegistered, PlayerNotRegistered());

        uint256 scoreToAward = SCORE_PER_GAME * multiplier;
        players[player].score += scoreToAward;

        emit ScoreEarned(player, scoreToAward);
        emit LeaderboardUpdated(player, players[player].score);
    }

    // *******************************************
    // *                                         *
    // *            READ FUNCTIONS               *
    // *                                         *
    // *******************************************
    function getPlayerStats(
        address player
    ) external view returns (Player memory) {
        require(players[player].isRegistered, PlayerNotRegistered());
        return players[player];
    }

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

     // Get all bosses that a player has killed
    function getPlayerKilledBosses(address player) external view returns (bytes32[] memory) {
        require(players[player].isRegistered, PlayerNotRegistered());
        return playerKilledBosses[player];
    }

    // Get all players that killed a specific boss
    function getBossKillers(bytes32 bossId) external view returns (address[] memory) {
        if (!bossExists[bossId]) revert BossNotExists();
        return bossKillers[bossId];
    }

    // Get all registered bosses
    function getAllBosses() external view returns (bytes32[] memory) {
        return allBosses;
    }

    // Check if a player has killed a specific boss
    function hasPlayerKilledBoss(address player, bytes32 bossId) public view returns (bool) {
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
    function registerPlayer(uint256 nonce, bytes calldata signature) external {
        require(!players[msg.sender].isRegistered, PlayerAlreadyRegistered());

        // check signature
        bytes32 messageHash = keccak256(abi.encodePacked(msg.sender, nonce));
        require(SignatureCheckerLib.isValidSignatureNowCalldata(backendSigner, messageHash, signature), InvalidSignature());

        players[msg.sender] = Player({score: 0, nonce: nonce, isRegistered: true});
        playerAddresses.push(msg.sender);

        emit PlayerRegistered(msg.sender, nonce);
    }

    function syncData(uint256[] calldata _bossIds, uint256 score, uint256 nonce, bytes calldata signature) external {
        require(players[msg.sender].isRegistered, PlayerNotRegistered());
        require(allBosses.length > 0, BossesNotSet());

        if (_bossIds.length > 0) {
            // check is bosses are valid
            for (uint256 i = 0; i < _bossIds.length; i++) {
                bytes32 bossId = bytes32(_bossIds[i]);
                if (!bossExists[bossId]) {
                    revert InvalidBosses();
                }
            }
        }

        // check signature
        bytes32 messageHash = keccak256(abi.encodePacked(msg.sender, nonce));
        if (
            !SignatureCheckerLib.isValidSignatureNowCalldata(backendSigner, messageHash, signature)) {
            revert InvalidSignature();
        }

        // update player score
        players[msg.sender].score = score;
        players[msg.sender].nonce = nonce + 1;
        
        // for each boss that player have not killed, add to player killed bosses
        for (uint256 i = 0; i < _bossIds.length; i++) {
            bytes32 bossId = bytes32(_bossIds[i]);
            if (!hasPlayerKilledBoss(msg.sender, bossId)) {
                playerKilledBosses[msg.sender].push(bossId);
                bossKillers[bossId].push(msg.sender);
            }
        }

        emit SyncedData(msg.sender, _bossIds, score, nonce);
    }

    function mintCatridge(bytes32 bossId, bytes calldata signature) external {
        // Check if player has killed the boss
        bool hasKilledBoss = false;
        for (uint256 i = 0; i < playerKilledBosses[msg.sender].length; i++) {
            if (playerKilledBosses[msg.sender][i] == bossId) {
                hasKilledBoss = true;
                break;
            }
        }
        
        require(!hasKilledBoss, PlayerNotKilledBossYet());
        require(address(catridgeNFT) != address(0), CatridgeSmartContractNotSet());

        // check signature
        bytes32 messageHash = keccak256(abi.encodePacked(msg.sender, bossId));
        if (
            !SignatureCheckerLib.isValidSignatureNowCalldata(backendSigner, messageHash, signature)) {
            revert InvalidSignature();
        }

        // Mint the NFT
        uint256 tokenId = catridgeNFT.mintCatridge(msg.sender, bossId);
        
        emit CatridgeMinted(msg.sender, bossId, tokenId);
    }

    // Required override for UUPS proxy pattern
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}
}
