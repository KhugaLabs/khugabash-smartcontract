// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";

/**
 * @title KhugaBashProxy
 * @dev Proxy contract for the KhugaBash game contract
 * @notice This proxy implements the ERC1967 standard and delegates calls to the implementation contract
 * @dev The implementation address is stored in the ERC1967 storage slot
 */
contract KhugaBashProxy is ERC1967Proxy {
    /**
     * @dev Constructor for the KhugaBashProxy
     * @param _logic Address of the initial implementation contract
     * @param _data Initialization data to be passed to the implementation contract
     */
    constructor(
        address _logic,
        bytes memory _data
    ) ERC1967Proxy(_logic, _data) {}
}
