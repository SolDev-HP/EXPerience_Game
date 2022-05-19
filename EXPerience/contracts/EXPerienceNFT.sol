// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import "../interfaces/IERC20.sol";
import "./tokens/ERC721.sol";
import "./utils/Ownable.sol";
import "./libs/BadgeFactory.sol";

contract EXPerienceNFT is ERC721, Ownable {
    // Total supply - Should be exposed via getter
    // Should start with zero anyway.
    uint256 private _totalSupply;
    // EXPToken contract address - To refer to EXP balance of the user 
    address private _EXPContractAddress;
    // EXPToken Interface to get balanceOf
    // Though we imported original IERC20 for this, we can potentially limit it to just balanceOf function
    IERC20 private _expContract;
    // Generator admins 
    mapping(address => bool) private _tokenAdmins;

    // Events 
    event ExperienceNFTGenerated(address indexed _experienceGainer);
    event TokenAdminSet(address indexed _admin, bool indexed _isAdmin);

    // ================= ERRORS ======================
    error ActionRestricted();

    // Constructor of EXPerience NFT Contract, expects nama and symbol of the NFT Contract 
    // and address where EXP Token is deployed
    constructor(string memory _name, string memory _symbol, address _expcontract) 
        ERC721(_name, _symbol) {
        // Set EXP Contract address 
        _EXPContractAddress = _expcontract;
        // Set msg sender the first admin 
        _tokenAdmins[msg.sender] = true;
    }

    // Add token admins who are allowed to mint NFT for any given address 
    function setTokenAdmin(address _admin, bool _isAdmin) public OnlyOwner {
        _tokenAdmins[_admin] = _isAdmin;
        emit TokenAdminSet(_admin, _isAdmin);
    }

    // A way to update EXPToken address (Keeping it for now)
    function setExpContractAddress(address _contract) public OnlyOwner {
        require(_contract != address(0), "Invalid EXP Token Contract address");
        _EXPContractAddress = _contract;
    }
    // Generate EXPerience NFT for the address given 
    function genExperience(address _to) public {
        // Make sure the message sender is one of the admins 
        require(_tokenAdmins[msg.sender] == true, "EXPerience: You're not an admin");
        // We need to make sure _to actually holds some EXP 
        // Get the exp token contract  
        _expContract = IERC20(_EXPContractAddress);
        // Get _to's EXP token holdings 
        uint256 _expBalanceofTo = _expContract.balanceOf(_to);
        // For Testing Only: Let's limit minting to address only if they any amount of exp token
        require(_expBalanceofTo > 0, "EXPerience: Insufficient EXP balance");
        
        // Get TokenID 
        uint256 _tokenID = _totalSupply;
        // Increment for next tokenID
        ++_totalSupply;
        // Mint the EXPerience NFT for the address (If address already holds the NFT, _mint will revert)
        _safeMint(_to, _tokenID);
        // Emit the event 
        emit ExperienceNFTGenerated(_to);
    }

    // Total supply 
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    // TokenURI(), this is where we will implement all our logic
    // - We need to generate ASCII NFT art
    // - Art could be a trophie showing achievement/level 
    // --- Null trophie for 0 EXP tokens in the account 
    // --- Distinct 5 trophies, each trophie for certain EXP token held in the account 
    // --- Ex: Tier-1 trophie for users who have 1 to 20 EXP tokens
    // --- Tier-2 trophies for users who have 21 to 40 EXP tokens and so on...
    function tokenURI(uint256 _tokenID) public view override returns (string memory) {
        // Make sure _tokenID is valid 
        require(_exists(_tokenID), "EXPerience NFT: Invalid TokenID");
        // Get the owner of the _tokenID
        address owner = ownerOf(_tokenID); 
        // We need owner's EXP token balance
        // Based on balance, we can prepare a variable that denotes which 
        // Symbol should be written in the center of the circle. 
        // Get owner's EXP token holdings
        uint256 ownerBal = IERC20(_EXPContractAddress).balanceOf(owner);

        // Now we have following details required to generate a tokenURI 
        // owner of the nft, nft token ID, owner's EXP balance 
        return BadgeFactory._generateTokenURI(_tokenID, ownerBal, owner);
    }

    /// @dev functions that are restricted 
    /// Overridden from ERC721 and modifier to reflect 
    /// Soulbound nature of the NFT
    function approve(address, uint256) public pure override {
        revert ActionRestricted();
    }

    function getApproved(uint256) public pure override returns (address) {
        revert ActionRestricted();
    }

    function setApprovalForAll(address, bool) public pure override {
        revert ActionRestricted();
    }

    function isApprovedForAll(address, address) public pure override returns (bool) {
        revert ActionRestricted();
    }

    function transferFrom(address, address, uint256) public pure override {
        revert ActionRestricted();
    }

    function safeTransferFrom(address, address, uint256) public pure override {
        revert ActionRestricted();
    }

    function safeTransferFrom(address, address, uint256, bytes memory) public pure override {
         revert ActionRestricted();
    }
}