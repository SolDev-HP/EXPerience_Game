// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./ERC165.sol";

/// @dev Updates to the contract. Switching to mapping approach for local introspection 
/// @dev from eip165 - With three or more supported interfaces (including ERC165 itself as a required supported interface), 
/// @dev the mapping approach (in every case) costs less gas than the pure approach (at worst case).
/// @dev This would mean adding ERC165Storage base class instead of ERC165, some modification on how I'm using 
/// @dev introspection. Ref: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/introspection/ERC165Storage.sol
abstract contract ERC165Storage is ERC165 {
    /// @dev mapping of all supported interfaces 
    /// @notice you MUST NOT/NEVER set element 0xffffffff (Invalid InterfaceID) to true
    mapping(bytes4 => bool) private _supportedInterfaces;
    /** 
     * @dev See {IERC165:supportsInterface()}
     * @dev An update would be checking base class first for the given interfacId, and then verify in storage  
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return super.supportsInterface(interfaceId) || _supportedInterfaces[interfaceId];
    }

    /**
     * @dev internal method to register interfaceId, 
     * @dev should check for 0xffffffff (Invalid InterfaceID) as input 
     */
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: Invalid InterfaceID");
        _supportedInterfaces[interfaceId] = true;
    }

    /**
     * @dev internal method to un-register an interface, I don't yet know all the possible usecase where 
     * there might be a requirement to un-register to continuously maintain interfaces supporting/unsupporting 
     * at any given time. May turn out to be stupid, but keeping it for learning purposes. 
     * @dev should check for 0xffffffff (Invalid InterfaceID) as input, function shouldn't assume correct input. 
     */
    function _unregisterInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: Invalid InterfaceID");
        _supportedInterfaces[interfaceId] = false;
    }
}