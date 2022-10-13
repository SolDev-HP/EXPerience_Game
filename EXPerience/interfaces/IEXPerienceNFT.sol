// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
interface IEXPerienceNFT {
    // Events 
    event ExperienceNFTGenerated(address indexed, uint256 indexed);
    event TokenAdminSet(address indexed, bool indexed);
    // Additional events
    event EXPTokenContractAddressChange(address indexed);
    // Error to indicate that action can only be performed by token admins 
    error OnlyOnePerAddress();
    // Error to indicate that referenced address is a zero address 
    error InvalidAddress();
    error TokenIsSoulbound();

    function getEXPTokenAddress() external view returns (address);
    // We make sure that following functions are behind ownerOnly wall.
    // Only owner of the contract should be able to manipulate these state variables
    function changeEXPTokenAddress(address) external;
    // Accessible to anyone 
    // Generate EXPerience NFT for oneself 
    function generateExperienceNFT() external;
    // Total supply 
    function totalSupply() external view returns (uint256);
    function tokenURI(uint256) external view returns (string memory);

    function getTokenIdOfOwner(address) external view returns (uint256);
    /**
     * ==================================================================
     *          FUNCTIONS (Public) - Making ERC721 Soulbound
     * ==================================================================
     */

    /// @dev functions that are restricted 
    /// Overridden from ERC721 and modifier to reflect 
    /// Soulbound nature of the NFT
    function approve(address, uint256) external;
    function getApproved(uint256) external view  returns (address);
    function setApprovalForAll(address, bool) external;
    function isApprovedForAll(address, address) external view returns (bool);
    function transferFrom(address, address, uint256) external;
    function safeTransferFrom(address, address, uint256) external;
    function safeTransferFrom(address, address, uint256, bytes memory) external;

    // As they all use Ownable
    function transferOwnership(address) external;
}