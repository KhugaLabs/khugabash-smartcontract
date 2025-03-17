// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../src/KhugaBash.sol";
import "../src/CatridgeNFT.sol";

contract KhugaBashTest is Test {
    KhugaBash khugaBash;
    address public owner = address(0xBce4253a81B232cC41027dCbE33fDdA010dC33Aa);
    address public backendSigner = address(0xBce4253a81B232cC41027dCbE33fDdA010dC33Aa);
    address public player = address(0xBce4253a81B232cC41027dCbE33fDdA010dC33Aa);
    uint256 public backendSignerPrivateKey = 0x1124360643ae21e1a5c1e6ce58512df686abf1139944bccc97b34627ef3445c0;
    
    event PlayerRegistered(address indexed player, uint256 nonce);
    
    function setUp() public {
        // Deploy the contract
        vm.prank(owner);
        khugaBash = new KhugaBash();
        
        // Initialize the contract
        vm.prank(owner);
        khugaBash.initialize();
        
        // Set the backend signer
        vm.prank(owner);
        khugaBash.setBackendSigner(backendSigner);
    }
    
    function testRegisterPlayer() public {
        uint256 nonce = 1;
        bytes memory signature = _signMessage(player, nonce);
        
        // Expect the PlayerRegistered event to be emitted
        vm.expectEmit(true, true, false, true);
        emit PlayerRegistered(player, nonce);
        
        // Register the player
        vm.prank(player);
        khugaBash.registerPlayer(nonce, signature);
        
        // Verify the player is registered
        (uint256 score, uint256 storedNonce, bool isRegistered) = _getPlayerData(player);
        assertEq(score, 0, "Score should be 0");
        assertEq(storedNonce, nonce, "Nonce should match");
        assertTrue(isRegistered, "Player should be registered");
    }
    
    function testCannotRegisterTwice() public {
        uint256 nonce = 1;
        bytes memory signature = _signMessage(player, nonce);
        
        // Register the player first time
        vm.prank(player);
        khugaBash.registerPlayer(nonce, signature);
        
        // Try to register again with a new nonce
        uint256 newNonce = 2;
        bytes memory newSignature = _signMessage(player, newNonce);
        
        // Expect the PlayerAlreadyRegistered error
        vm.expectRevert(abi.encodeWithSignature("PlayerAlreadyRegistered()"));
        
        vm.prank(player);
        khugaBash.registerPlayer(newNonce, newSignature);
    }
    
    function testCannotRegisterWithInvalidSignature() public {
        uint256 nonce = 1;
        
        // Create an invalid signature (signed by wrong key)
        uint256 wrongPrivateKey = 0x2;
        bytes32 messageHash = keccak256(abi.encodePacked(player, nonce));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(wrongPrivateKey, messageHash);
        bytes memory invalidSignature = abi.encodePacked(r, s, v);
        
        // Expect the InvalidSignature error
        vm.expectRevert(abi.encodeWithSignature("InvalidSignature()"));
        
        vm.prank(player);
        khugaBash.registerPlayer(nonce, invalidSignature);
    }
    
    function testCannotRegisterWithWrongNonce() public {
        uint256 correctNonce = 1;
        uint256 wrongNonce = 2;
        
        // Sign message with correct nonce
        bytes memory signature = _signMessage(player, correctNonce);
        
        // Try to register with wrong nonce but correct signature
        vm.expectRevert(abi.encodeWithSignature("InvalidSignature()"));
        
        vm.prank(player);
        khugaBash.registerPlayer(wrongNonce, signature);
    }
    
    // Helper function to sign a message
    function _signMessage(address _player, uint256 _nonce) internal view returns (bytes memory) {
        bytes32 messageHash = keccak256(abi.encodePacked(_player, _nonce));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(backendSignerPrivateKey, messageHash);
        return abi.encodePacked(r, s, v);
    }
    
    // Helper function to get player data
    function _getPlayerData(address _player) internal view returns (uint256 score, uint256 nonce, bool isRegistered) {
        KhugaBash.Player memory thePlayer = khugaBash.getPlayerStats(_player);
        return (thePlayer.score, thePlayer.nonce, thePlayer.isRegistered);
    }
} 