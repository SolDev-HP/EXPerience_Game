// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import "./ERC721.sol";
import "./utils/Ownable.sol";
import "./utils/Counters.sol";

contract EXPerienceNFT is ERC721, Ownable {
    // Counters to keep track of no. of EXPerienceNFTs
    using Counters for Counters.Counter;
    // Total supply - Should be exposed via getter
    Counters.Counter private _totalSupply;
    // EXPToken contract address - To refer to EXP balance of the user 
    address private _EXPContract;
    // Generator admins 
    mapping(address => bool) private _tokenAdmins;

    // Events 
    event ExperienceNFTGenerated(address indexed _experienceGainer);
    event TokenAdminSet(address indexed _admin, bool indexed _isAdmin);

    // Constructor of EXPerience NFT Contract, expects nama and symbol of the NFT Contract 
    // and address where EXP Token is deployed
    constructor(string memory _name, string memory _symbol, address _expcontract) 
        ERC721(_name, _symbol) {
        // Set EXP Contract address 
        _EXPContract = _expcontract;
        // Set msg sender the first admin 
        _tokenAdmins[msg.sender] = true;
    }

    // Add token admins who are allowed to mint NFT for any given address 
    function setTokenAdmin(address _admin, bool _isAdmin) public OnlyOwner {
        _tokenAdmins[_admin] = _isAdmin;
        emit TokenAdminSet(_admin, _isAdmin);
    }

    // Generate EXPerience NFT for the address given 
    function genExperience(address _to) public {
        // Make sure the message sender is one of the admins 
        require(_tokenAdmins[msg.sender] == true, "EXPerience: You're not an admin");
        // Increase supply 
        _totalSupply.increment();
        // Get TokenID 
        uint256 _tokenID = _totalSupply.current();
        // Mint the EXPerience NFT for the address (If address already holds the NFT, _mint will revert)
        _safeMint(_to, _tokenID);
        // Emit the event 
        emit ExperienceNFTGenerated(_to);
    }

    // Total supply 
    function totalSupply() public view returns (uint256) {
        return _totalSupply.current();
    }

    // TokenURI(), this is where we will implement all our logic
    // - We need to generate ASCII NFT art
    // - Art could be a trophie showing achievement/level 
    // --- Null trophie for 0 EXP tokens in the account 
    // --- Distinct 5 trophies, each trophie for certain EXP token held in the account 
    // --- Ex: Tier-1 trophie for users who have 1 to 20 EXP tokens
    // --- Tier-2 trophies for users who have 21 to 40 EXP tokens and so on...
    function tokenURI(uint256 _tokenID) public view override returns (string memory) {
        // Some way of gathering the data that what kind of NFT should be shown 
        // Should change based on holder's EXP balance 
        // generateTokenURI(...args) -> Some Generator Library 
    }
}