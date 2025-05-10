// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

interface IBossRegistry {
    function checkBossExists(bytes32 bossId) external view returns (bool);
}

contract KtridgeNFT is ERC721, Ownable2Step {
    // *******************************************
    // *                                         *
    // *                STRUCTS                  *
    // *                                         *
    // *******************************************
    struct BossMetadata {
        string name;
        string imageURI;
        string description;
        uint8 tier;
        bool exists;
    }

    // *******************************************
    // *                                         *
    // *            STATE VARIABLES              *
    // *                                         *
    // *******************************************
    address public khugaBashAddress;
    uint256 private _tokenIdCounter;
    uint256 private _burnedTokenCounter;
    mapping(uint256 => bytes32) public tokenToBoss;
    mapping(address => mapping(bytes32 => uint256))
        public playerMintedBossToken;
    mapping(address => mapping(bytes32 => uint256))
        public playerBurnedBossToken;
    mapping(bytes32 => BossMetadata) public bossMetadata;
    mapping(uint8 => string) public tierNames;
    string private _contractURI;

    // *******************************************
    // *                                         *
    // *                EVENTS                   *
    // *                                         *
    // *******************************************
    event KtridgeMinted(
        address indexed player,
        bytes32 indexed bossId,
        uint256 tokenId
    );
    event KtridgeBurned(
        address indexed player,
        bytes32 indexed bossId,
        uint256 tokenId
    );
    event BossMetadataSet(bytes32 indexed bossId);
    event KhugaBashAddressSet(address indexed khugaBashAddress);
    event TierNameSet(uint8 indexed tier, string name);

    // *******************************************
    // *                                         *
    // *                ERRORS                   *
    // *                                         *
    // *******************************************
    error InvalidKhugaBashAddress();
    error OnlyKhugaBashCanMint();
    error NotAuthorizedToBurn();
    error BossDoesNotExist();
    error KhugaBashAddressNotSet();
    error BossMetadataNotSet();
    error InvalidTier();

    // *******************************************
    // *                                         *
    // *             CONSTRUCTOR                 *
    // *                                         *
    // *******************************************
    constructor(
        address initialOwner
    ) ERC721("Khuga Bash Ktridge", "KTRIDGE") Ownable(initialOwner) {
        // Initialize tier names
        tierNames[0] = "Common";
        tierNames[1] = "Uncommon";
        tierNames[2] = "Rare";
        tierNames[3] = "Epic";
        tierNames[4] = "Legendary";

        emit TierNameSet(0, "Common");
        emit TierNameSet(1, "Uncommon");
        emit TierNameSet(2, "Rare");
        emit TierNameSet(3, "Epic");
        emit TierNameSet(4, "Legendary");
    }

    // *******************************************
    // *                                         *
    // *            ADMIN FUNCTIONS              *
    // *                                         *
    // *******************************************
    /**
     * @notice Set the KhugaBash address
     * @param _khugaBashAddress The address of the KhugaBash contract
     */
    function setKhugaBashAddress(address _khugaBashAddress) external onlyOwner {
        if (_khugaBashAddress == address(0)) revert InvalidKhugaBashAddress();
        khugaBashAddress = _khugaBashAddress;
        emit KhugaBashAddressSet(_khugaBashAddress);
    }

    /**
     * @notice Set the name of a tier
     * @param tier The tier to set the name of
     * @param _name The name of the tier
     */
    function setTierName(uint8 tier, string calldata _name) external onlyOwner {
        if (tier > 4) revert InvalidTier();
        tierNames[tier] = _name;
        emit TierNameSet(tier, _name);
    }

    /**
     * @notice Set the metadata of a boss
     * @param bossId The ID of the boss
     * @param bossName The name of the boss
     * @param imageURI The URI of the boss's image
     * @param description The description of the boss
     * @param tier The tier of the boss
     */
    function setBossMetadata(
        bytes32 bossId,
        string calldata bossName,
        string calldata imageURI,
        string calldata description,
        uint8 tier
    ) external onlyOwner {
        if (khugaBashAddress == address(0)) revert KhugaBashAddressNotSet();
        if (!IBossRegistry(khugaBashAddress).checkBossExists(bossId))
            revert BossDoesNotExist();
        if (tier > 4) revert InvalidTier();

        bossMetadata[bossId] = BossMetadata({
            name: bossName,
            imageURI: imageURI,
            description: description,
            tier: tier,
            exists: true
        });

        emit BossMetadataSet(bossId);
    }

    /**
     * @notice Set the contract URI
     * @param newURI The new URI of the contract
     */
    function setContractURI(string calldata newURI) external onlyOwner {
        _contractURI = newURI;
    }

    // *******************************************
    // *                                         *
    // *            READ FUNCTIONS               *
    // *                                         *
    // *******************************************
    /**
     * @notice Get the tier of a token
     * @param tokenId The ID of the token
     * @return The tier of the token
     */
    function getTierOfToken(uint256 tokenId) public view returns (uint8) {
        bytes32 bossId = tokenToBoss[tokenId];
        if (!bossMetadata[bossId].exists) revert BossMetadataNotSet();
        return bossMetadata[bossId].tier;
    }

    /**
     * @notice Get the display name of a token's tier
     * @param tokenId The ID of the token
     * @return The display name of the token's tier
     */
    function getTierNameOfToken(
        uint256 tokenId
    ) public view returns (string memory) {
        uint8 tier = getTierOfToken(tokenId);
        return tierNames[tier];
    }

    /**
     * @notice Get the token ID of a player's minted boss token
     * @param player The address of the player
     * @param bossId The ID of the boss
     * @return The token ID of the player's minted boss token
     */
    function getPlayerMintedBossToken(
        address player,
        bytes32 bossId
    ) public view returns (uint256) {
        return playerMintedBossToken[player][bossId];
    }

    /**
     * @notice Get the token ID of a player's burned boss token
     * @param player The address of the player
     * @param bossId The ID of the boss
     * @return The token ID of the player's burned boss token
     */
    function getPlayerBurnedBossToken(
        address player,
        bytes32 bossId
    ) public view returns (uint256) {
        return playerBurnedBossToken[player][bossId];
    }

    /**
     * @notice Get the total supply of tokens
     * @return The total supply of tokens
     */
    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter - _burnedTokenCounter;
    }

    // *******************************************
    // *                                         *
    // *            WRITE FUNCTIONS              *
    // *                                         *
    // *******************************************
    modifier onlyKhugaBash() {
        if (msg.sender != khugaBashAddress) revert OnlyKhugaBashCanMint();
        _;
    }

    /**
     * @notice Mint a Ktridge
     * @param player The address of the player
     * @param bossId The ID of the boss
     * @return The ID of the minted token
     */
    function mintKtridge(
        address player,
        bytes32 bossId
    ) external onlyKhugaBash returns (uint256) {
        if (!IBossRegistry(khugaBashAddress).checkBossExists(bossId))
            revert BossDoesNotExist();
        if (!bossMetadata[bossId].exists) revert BossMetadataNotSet();

        // Check if player already has a Ktridge for this boss
        uint256 existingToken = playerMintedBossToken[player][bossId];
        if (existingToken != 0) {
            return existingToken;
        }

        // Mint new token
        _tokenIdCounter++;
        uint256 tokenId = _tokenIdCounter;

        _mint(player, tokenId);

        // Record token information
        tokenToBoss[tokenId] = bossId;
        playerMintedBossToken[player][bossId] = tokenId;

        emit KtridgeMinted(player, bossId, tokenId);

        return tokenId;
    }

    /**
     * @notice Burns a Ktridge NFT, removing it from circulation
     * @param tokenId The ID of the token to burn
     */
    function burnKtridge(uint256 tokenId) external {
        address tokenOwner = _ownerOf(tokenId);

        // Only token owner or approved address can burn
        if (
            tokenOwner != msg.sender &&
            getApproved(tokenId) != msg.sender &&
            !isApprovedForAll(tokenOwner, msg.sender)
        ) {
            revert NotAuthorizedToBurn();
        }

        // Get boss ID before burning
        bytes32 bossId = tokenToBoss[tokenId];

        // Burn token
        _burn(tokenId);
        _burnedTokenCounter++;

        // record the token as burned
        playerBurnedBossToken[tokenOwner][bossId] = tokenId;

        // Remove token from mappings
        delete tokenToBoss[tokenId];

        emit KtridgeBurned(tokenOwner, bossId, tokenId);
    }

    // *******************************************
    // *                                         *
    // *            ON-CHAIN METADATA            *
    // *                                         *
    // *******************************************
    /**
     * @notice Get the token URI of a token
     * @param tokenId The ID of the token
     * @return The URI of the token
     */
    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        bytes32 bossId = tokenToBoss[tokenId];
        BossMetadata memory metadata = bossMetadata[bossId];

        if (!metadata.exists) revert BossMetadataNotSet();

        string memory tierName = tierNames[metadata.tier];

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        tierName,
                        " Ktridge: ",
                        metadata.name,
                        '", ',
                        '"description": "',
                        metadata.description,
                        '", ',
                        '"image": "',
                        metadata.imageURI,
                        '", ',
                        '"attributes": [',
                        '{"trait_type": "Boss", "value": "',
                        metadata.name,
                        '"}, ',
                        '{"trait_type": "Tier", "value": "',
                        tierName,
                        '"}, ',
                        '{"display_type": "boost_number", "trait_type": "Rarity", "value": ',
                        Strings.toString(metadata.tier),
                        "}",
                        "]",
                        "}"
                    )
                )
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    /**
     * @notice Get the name of the contract
     * @return The name of the contract
     */
    function name() public pure override returns (string memory) {
        return "Khuga Bash Ktridge";
    }

    /**
     * @notice Get the symbol of the contract
     * @return The symbol of the contract
     */
    function symbol() public pure override returns (string memory) {
        return "KTRIDGE";
    }

    /**
     * @notice Withdraw ETH from the contract
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        if (balance == 0) return;

        (bool success, ) = owner().call{value: balance}("");
        require(success, "Transfer failed");
    }

    /**
     * @notice Get the contract URI
     * @return The URI of the contract
     */
    function contractURI() public view returns (string memory) {
        return _contractURI;
    }
}
