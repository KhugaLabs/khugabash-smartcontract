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
    bool private _paused;

    // Events
    event PlayerRegistered(address indexed player);
    event scoreEarned(address indexed player, uint256 score);
    event scoreUpdated(uint256 score, uint256 nonce);
    event LeaderboardUpdated(address indexed player, uint256 score);
    event Paused(address account);
    event Unpaused(address account);

    // Errors
    error EnforcedPause();
    error ExpectedPause();

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        _initializeOwner(msg.sender);
        _paused = false;
    }

    // Modifiers
    modifier whenNotPaused() {
        if (_paused) revert EnforcedPause();
        _;
    }

    modifier whenPaused() {
        if (!_paused) revert ExpectedPause();
        _;
    }

    // Player Registration
    function registerPlayer(uint256 nonce, bytes calldata signature) external whenNotPaused {
        require(!players[msg.sender].isRegistered, "Player already registered");
        
        // Recreate the message hash
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("registerPlayer(address player,uint256 nonce)"),
                msg.sender,
                nonce
            )
        );
        
        bytes32 digest = _hashTypedData(structHash);

        // Verify signature from backend
        address signer = ECDSA.recover(digest, signature);
        require(signer == backendSigner, "Invalid signature");
        
        players[msg.sender] = Player({
            score: 0,
            isRegistered: true
        });

        playerNonce[msg.sender] = nonce;
        playerAddresses.push(msg.sender);
        emit PlayerRegistered(msg.sender);
    }

    // Game score System
    function awardScore(address player, uint256 multiplier) external onlyOwner whenNotPaused {
        require(players[player].isRegistered, "Player not registered");
        
        uint256 scoreToAward = SCORE_PER_GAME * multiplier;
        players[player].score += scoreToAward;
        
        emit scoreEarned(player, scoreToAward);
        emit LeaderboardUpdated(player, players[player].score);
    }

    function updateScore(uint256 score, uint256 nonce, bytes calldata signature) external whenNotPaused {
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

    // Pause Functions
    function pause() external onlyOwner whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() external onlyOwner whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    // Required override for UUPS proxy pattern
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function _domainNameAndVersion() internal pure virtual override returns (string memory name, string memory version) {
        name = "KhugaBash";
        version = "1";
    }
}