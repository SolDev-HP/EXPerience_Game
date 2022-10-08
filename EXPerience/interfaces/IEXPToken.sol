// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
interface IEXPToken { 
    // Error to indicate that action can only be performed by token admins 
    error OnlyTokenAdminsAllowed();
    // Error to indicate that referenced address is a zero address 
    error InvalidAddress();
    // Error to indicate that performed action has no effects 
    // And hence better to revert instead of unnecessarily access 
    // other state variables  
    error ActionHasNoEffects();

    // We override following functions from OpenZeppelin's ERC20   
    // to make sure EXPToken follows properties of being a soulbound token 
    function transfer(address, uint256) external returns (bool);

    function allowance(address, address) external view returns (uint256);

    function approve(address, uint256) external returns (bool);

    function transferFrom(address, address, uint256) external returns (bool);
    function increaseAllowance(address, uint256) external returns (bool);
    function decreaseAllowance(address, uint256) external returns (bool);

    /** 
     * @notice Set admins
     * @dev ability to set or unset admins, generates TokenAdminSet event
     */
    function setTokenAdmin(address, bool) external;

    /// @dev gainExperience function to add experience points to user's EXP balance 
    /// Need to make sure we cap experience to max exp limit
    function gainExperience(address, uint256) external;

    // As they all use Ownable
    function transferOwnership(address) external;
}