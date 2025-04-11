// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../lib/solady/src/tokens/ERC721.sol";
import "../lib/solady/src/auth/Ownable.sol";
import "../lib/solady/src/utils/Base64.sol";
import "../lib/solady/src/utils/LibString.sol";

interface IBossRegistry {
    function checkBossExists(bytes32 bossId) external view returns (bool);
}

contract KtridgeNFT is ERC721, Ownable {
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
    }

    // *******************************************
    // *                                         *
    // *            STATE VARIABLES              *
    // *                                         *
    // *******************************************
    address public khugaBashAddress;
    uint256 private _tokenIdCounter;
    mapping(uint256 => bytes32) public tokenToBoss;
    mapping(address => mapping(bytes32 => uint256)) public playerBossToToken;
    mapping(bytes32 => BossMetadata) public bossMetadata;
    mapping(uint8 => string) public tierNames;
    string public _contractURI;

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

    // *******************************************
    // *                                         *
    // *                ERRORS                   *
    // *                                         *
    // *******************************************
    error InvalidKhugaBashAddress();
    error OnlyKhugaBashCanMint();
    error NotAuthorizedToBurn();

    // *******************************************
    // *                                         *
    // *             CONSTRUCTOR                 *
    // *                                         *
    // *******************************************
    constructor() {
        _initializeOwner(msg.sender);

        // Initialize tier names
        tierNames[0] = "Common";
        tierNames[1] = "Uncommon";
        tierNames[2] = "Rare";
        tierNames[3] = "Epic";
        tierNames[4] = "Legendary";
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
    }

    /**
     * @notice Set the name of a tier
     * @param tier The tier to set the name of
     * @param _name The name of the tier
     */
    function setTierName(uint8 tier, string calldata _name) external onlyOwner {
        tierNames[tier] = _name;
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
        require(
            IBossRegistry(khugaBashAddress).checkBossExists(bossId),
            "Boss does not exist"
        );
        
        bossMetadata[bossId] = BossMetadata({
            name: bossName,
            imageURI: imageURI,
            description: description,
            tier: tier
        });
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
        require(_ownerOf(tokenId) != address(0), TokenDoesNotExist());
        bytes32 bossId = tokenToBoss[tokenId];
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
     * @notice Get the total supply of tokens
     * @return The total supply of tokens
     */
    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter;
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
        // Check if player already has a Ktridge for this boss
        uint256 existingToken = playerBossToToken[player][bossId];
        if (existingToken != 0) {
            return existingToken;
        }

        // Mint new token
        _tokenIdCounter++;
        uint256 tokenId = _tokenIdCounter;

        _mint(player, tokenId);

        // Record token information
        tokenToBoss[tokenId] = bossId;
        playerBossToToken[player][bossId] = tokenId;

        emit KtridgeMinted(player, bossId, tokenId);

        return tokenId;
    }

    /**
     * @notice Burns a Ktridge NFT, removing it from circulation
     * @param tokenId The ID of the token to burn
     */
    function burnKtridge(uint256 tokenId) external {
        address tokenOwner = _ownerOf(tokenId);
        if (tokenOwner == address(0)) revert TokenDoesNotExist();

        // Only token owner or approved address can burn
        if (
            tokenOwner != msg.sender && !_isApprovedOrOwner(msg.sender, tokenId)
        ) {
            revert NotAuthorizedToBurn();
        }

        // Get boss ID before burning
        bytes32 bossId = tokenToBoss[tokenId];

        // Burn token
        _burn(tokenId);

        // Remove token from mappings
        delete tokenToBoss[tokenId];
        delete playerBossToToken[tokenOwner][bossId];

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
        require(_ownerOf(tokenId) != address(0), TokenDoesNotExist());

        bytes32 bossId = tokenToBoss[tokenId];
        BossMetadata memory metadata = bossMetadata[bossId];

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
                        LibString.toString(metadata.tier),
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
        (bool success, ) = owner().call{value: address(this).balance}("");
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
