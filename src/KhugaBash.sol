// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "solady/utils/Initializable.sol";
import "solady/auth/Ownable.sol";
import "solady/utils/ReentrancyGuard.sol";
import "solady/utils/UUPSUpgradeable.sol";
import "solady/utils/EIP712.sol";
import "solady/utils/ECDSA.sol";

/**
 * @title KhugaBash
 * @dev Main contract for the Khuga Bash game, implementing score system, stat upgrades, and leaderboard
 * @notice This is the zkSync version of the contract, optimized for L2 execution and upgradeable
 */
contract KhugaBash is 
    Initializable,
    Ownable,
    ReentrancyGuard,
    UUPSUpgradeable,
    EIP712
{
    // Structs
    struct Player {
        uint256 score;
        bool isRegistered;
    }

    struct LeaderboardEntry {
        address player;
        uint256 score;
    }

    // State variables
    mapping(address => Player) private players;
    mapping(address => uint256) private playerNonce;
    address public backendSigner;
    address[] private playerAddresses;
    uint256 private constant MAX_LEADERBOARD_SIZE = 100;
    uint256 private constant SCORE_PER_GAME = 10;

    // Events
    event PlayerRegistered(address indexed player);
    event scoreEarned(address indexed player, uint256 score);
    event scoreUpdated(uint256 score, uint256 nonce);
    event LeaderboardUpdated(address indexed player, uint256 score);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        _initializeOwner(msg.sender);
    }

    // Player Registration
    function registerPlayer(uint256 nonce) external {
        require(!players[msg.sender].isRegistered, "Player already registered");
        
        players[msg.sender] = Player({
            score: 0,
            isRegistered: true
        });

        playerNonce[msg.sender] = nonce;
        playerAddresses.push(msg.sender);
        emit PlayerRegistered(msg.sender);
    }

    // Game score System
    function awardScore(address player, uint256 multiplier) external onlyOwner {
        require(players[player].isRegistered, "Player not registered");
        
        uint256 scoreToAward = SCORE_PER_GAME * multiplier;
        players[player].score += scoreToAward;
        
        emit scoreEarned(player, scoreToAward);
        emit LeaderboardUpdated(player, players[player].score);
    }

    function updateScore(uint256 score, uint256 nonce, bytes calldata signature) external {
        require(nonce == playerNonce[msg.sender] + 1  , "Invalid nonce");

        //  Recreate the message hash
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("scoreUpdated(uint256 score,uint256 nonce)"),
                score,
                nonce
            )
        );
        
        bytes32 digest = _hashTypedData(structHash);

        // Verify signature
        address signer = ECDSA.recover(digest, signature);
        require(signer == backendSigner, "Invalid signature");

        // Update points
        players[msg.sender].score += score;
        playerNonce[msg.sender]++;
        emit scoreUpdated(score, nonce);
    }

    // Leaderboard Functions
    function getTopPlayers(uint256 limit) external view returns (LeaderboardEntry[] memory) {
        uint256 size = playerAddresses.length;
        uint256 resultSize = size < limit ? size : limit;
        resultSize = resultSize < MAX_LEADERBOARD_SIZE ? resultSize : MAX_LEADERBOARD_SIZE;
        
        LeaderboardEntry[] memory topPlayers = new LeaderboardEntry[](resultSize);
        
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

    // Player Stats
    function getPlayerStats(address player) external view returns (Player memory) {
        require(players[player].isRegistered, "Player not registered");
        return players[player];
    }

    // Admin Functions
    function setBackendSigner(address _backendSigner) external onlyOwner {
        backendSigner = _backendSigner;
    }

    function setPlayerNonce(address player, uint256 nonce) external onlyOwner {
        playerNonce[player] = nonce;
    }

    // Required override for UUPS proxy pattern
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function _domainNameAndVersion() internal pure virtual override returns (string memory name, string memory version) {
        name = "KhugaBash";
        version = "1";
    }
}