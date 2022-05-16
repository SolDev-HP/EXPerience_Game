// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import "./Context.sol";
// Create ownable contract, don't support OwnershipTransfer just yet
abstract contract Ownable {
    // Owner of the contract 
    address internal _owner;

    /// @dev Setup the owner 
    constructor() {
        _owner = msg.sender;
    }

    /// @dev Public function to check owner 
    /// @return address of the owner of this contract
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /// @dev owner checking modifier 
    modifier OnlyOwner() {
        require(owner() == msg.sender, "EXPToken (AccessControl): Not authorized.");
        _;
    }
}
