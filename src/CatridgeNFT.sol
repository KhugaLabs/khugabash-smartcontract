// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../lib/solady/src/tokens/ERC721.sol";
import "../lib/solady/src/auth/Ownable.sol";
import "../lib/solady/src/utils/Base64.sol";
import "../lib/solady/src/utils/LibString.sol";

contract CatridgeNFT is ERC721, Ownable {
    // *******************************************
    // *                                         *
    // *                STRUCTS                  *
    // *                                         *
    // *******************************************
    struct BossMetadata {
        string name;
        string imageURI;
        string description;
        CatridgeTier tier;
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
    enum CatridgeTier {
        COMMON,
        UNCOMMON,
        RARE,
        EPIC,
        LEGENDARY
    }
    mapping(bytes32 => BossMetadata) public bossMetadata;
    mapping(CatridgeTier => string) public tierNames;
    
    // *******************************************
    // *                                         *
    // *                EVENTS                   *
    // *                                         *
    // *******************************************
    event CatridgeMinted(address indexed player, bytes32 indexed bossId, uint256 tokenId);

    // *******************************************
    // *                                         *
    // *                ERRORS                   *
    // *                                         *
    // *******************************************
    error OnlyKhugaBashCanMint();

    // *******************************************
    // *                                         *
    // *             CONSTRUCTOR                 *
    // *                                         *
    // *******************************************
    constructor() {
        _initializeOwner(msg.sender);

         // Initialize tier names
        tierNames[CatridgeTier.COMMON] = "Common";
        tierNames[CatridgeTier.UNCOMMON] = "Uncommon";
        tierNames[CatridgeTier.RARE] = "Rare";
        tierNames[CatridgeTier.EPIC] = "Epic";
        tierNames[CatridgeTier.LEGENDARY] = "Legendary";
    }
    
    // *******************************************
    // *                                         *
    // *            ADMIN FUNCTIONS              *
    // *                                         *
    // *******************************************
    function setKhugaBashAddress(address _khugaBashAddress) external onlyOwner {
        khugaBashAddress = _khugaBashAddress;
    }

    function setTierName(CatridgeTier tier, string calldata _name) external onlyOwner {
        tierNames[tier] = _name;
    }
    
    function setBossMetadata(
        bytes32 bossId,
        string calldata bossName,
        string calldata imageURI,
        string calldata description,
        CatridgeTier tier
    ) external onlyOwner {
        bossMetadata[bossId] = BossMetadata({
            name: bossName,
            imageURI: imageURI,
            description: description,
            tier: tier
        });
    }

    // *******************************************
    // *                                         *
    // *            READ FUNCTIONS               *
    // *                                         *
    // *******************************************
    function getTierOfToken(uint256 tokenId) public view returns (CatridgeTier) {
        require(_ownerOf(tokenId) != address(0), TokenDoesNotExist());
        bytes32 bossId = tokenToBoss[tokenId];
        return bossMetadata[bossId].tier;
    }
    
    // Get display name of a token's tier
    function getTierNameOfToken(uint256 tokenId) public view returns (string memory) {
        CatridgeTier tier = getTierOfToken(tokenId);
        return tierNames[tier];
    }
    
    // *******************************************
    // *                                         *
    // *            WRITE FUNCTIONS              *
    // *                                         *
    // *******************************************
    function mintCatridge(address player, bytes32 bossId) external returns (uint256) {
        require(msg.sender == khugaBashAddress, OnlyKhugaBashCanMint());
        
        // Check if player already has a Catridge for this boss
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
        
        emit CatridgeMinted(player, bossId, tokenId);
        
        return tokenId;
    }

    // *******************************************
    // *                                         *
    // *            ON-CHAIN METADATA            *
    // *                                         *
    // *******************************************
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), TokenDoesNotExist());
        
        bytes32 bossId = tokenToBoss[tokenId];
        BossMetadata memory metadata = bossMetadata[bossId];

        string memory tierName = tierNames[metadata.tier];
        
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "', tierName, ' Catridge: ', metadata.name, '", ',
                        '"description": "', metadata.description, '", ',
                        '"image": "', metadata.imageURI, '", ',
                        '"attributes": [',
                            '{"trait_type": "Boss", "value": "', metadata.name, '"}, ',
                            '{"trait_type": "Tier", "value": "', tierName, '"}, ',
                            '{"display_type": "boost_number", "trait_type": "Rarity", "value": ', LibString.toString(uint8(metadata.tier)), '}',
                        '], '
                    )
                )
            )
        );
        
        return string(abi.encodePacked("data:application/json;base64,", json));
    }
    
    function name() public pure override returns (string memory) {
        return "Khuga Bash Catridge";
    }
    
    function symbol() public pure override returns (string memory) {
        return "CATRIDGE";
    }
}