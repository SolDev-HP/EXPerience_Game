// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
pragma experimental ABIEncoderV2;   // literally for string[], and struct params in functions for the lack of better understanding/ideas 
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./libs/EthernautFactory.sol";


/** 
 * @title Soulbound ERC721 implementation - named EXPerienceNFT
 * Requirement: 
 *  - Mintable NFT, nontransferable capable of reading and displaying how many EXP tokens you have in your wallet
 *  - Create a fully on-chain generative ASCII art showing numbers from 1 to 100
 *  - All mints start with the number 0
 *  - The number shown by the NFT must reflect the EXP balance of the owner on the NFT
 *  - Transfer capabilities must be disabled after minting (soulbound) 
 * Updates:
 *  - In addition to requirements, we can now generate random numbers 
 *    using API3 QRNG implementation and Airnode on chains 
 *    See: https://api3.org/QRNG for EXPToken
 *  - Separate out functionalities. like, ISoulbound handles soulbound
 *    properties, QRNGRequester handles random numbers from API3 QRNG
 * @author SolDev-HP (https://github.com/SolDev-HP)
 * @dev Implement ERC721 in a way that limits tokens capabilities such as 
 * transfer, approval and make it soulbound - once minted, it can not 
 * be transferred
 */
contract EXPerienceNFT is ERC721, Ownable {
    /**
     * ==================================================================
     *                          STATE VARIABLES
     * ==================================================================
     */

    // Total supply - Should be exposed via getter
    // Should start with zero anyway.
    uint256 private _totalSupply;
    // EXPToken contract address - To refer to EXP balance of the user 
    // Just incase we ever need to change which token should be used to 
    // grab balance when generating NFT - Add a setter 
    address private _EXPContractAddress;
    // Token Owners - This will help restrict NFT minting to only one per address 
    mapping(address => bool) private _tokenOwners;

    // Events 
    event ExperienceNFTGenerated(address indexed _experienceGainer, uint256 indexed _tokenID);
    event TokenAdminSet(address indexed aWhichAddress, bool indexed bIsAdmin);
    // Additional events
    event EXPTokenContractAddressChange(address indexed _changedToAddress);

    /**
     * ==================================================================
     *                              ERRORS
     * ==================================================================
     */

    // Error to indicate that action can only be performed by token admins 
    error OnlyOnePerAddress();
    // Error to indicate that referenced address is a zero address 
    error InvalidAddress();
    /** 
     * @dev Error to indicate that token is soulbound and action performed 
     * is not supported (ex. transfer, approve, safeTransfer etc.)
     */
    error TokenIsSoulbound();

    // Constructor of EXPerience NFT Contract, expects nama and symbol of the NFT Contract 
    // and address where EXP Token is deployed
    // Construction slightly changes as we incorporate library address within the deployment scripts 
    constructor(
        string memory _name, 
        string memory _symbol, 
        address _expcontract
    ) ERC721(_name, _symbol) {
        // Set EXP Contract address 
        _EXPContractAddress = _expcontract;
        // This contract address will be used to verify EXP token holding of an address
    }

    /**
     * ==================================================================
     *    FUNCTIONS (Public) - Token addresses updates
     * ==================================================================
     */

    function getEXPTokenAddress() public view returns (address expTokenAddress) {
        // Get current EXP Token (ERC20) contract address
        // should've been set while deployoment
        expTokenAddress = _EXPContractAddress;
    }

    // We make sure that following functions are behind ownerOnly wall.
    // Only owner of the contract should be able to manipulate these state variables
    function changeEXPTokenAddress(address changeTo) public onlyOwner {
        // Validate incoming address 
        if(changeTo == address(0)) { revert InvalidAddress(); }
        // Change the address
        _EXPContractAddress = changeTo;
        // Emit the event that contract address has been changed 
        emit EXPTokenContractAddressChange(_EXPContractAddress);
    }

    /**
     * ==================================================================
     *              FUNCTIONS (Public) - ERC721 + Soulbound 
     * ==================================================================
     */

    // Accessible to anyone 
    // Generate EXPerience NFT for oneself 
    function generateExperienceNFT() public {
        // Make sure we allow only one NFT mint per address
        if(_tokenOwners[msg.sender] == true) { revert OnlyOnePerAddress(); }
        
        // EXPToken holding verification. Currently removed as we want to allow 
        // users to mint NFT even without having EXPTokens, it'll simply display 0
        // We need to make sure _to actually holds some EXP 
        // Get _to's EXP token holdings 
        // uint256 _expBalanceofTo = IERC20(_EXPContractAddress).balanceOf(_to);
        // For Testing Only: Let's limit minting to address only if they any amount of exp token
        // require(_expBalanceofTo > 0, "EXPerience: Insufficient EXP balance");

        // Get TokenID 
        uint256 _tokenID = _totalSupply;
        // Increment for next tokenID
        _totalSupply++;
        // Set the token owner 
        _tokenOwners[msg.sender] = true;
        // Mint the EXPerience NFT for the address (If address already holds the NFT, _mint will revert)
        _safeMint(msg.sender, _tokenID);
        // Emit the event 
        emit ExperienceNFTGenerated(msg.sender, _tokenID);
    }


    // Total supply 
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    // TokenURI(), this is where we will implement all our logic
    // - We need to generate ~ASCII~ NFT art
    // - Art could be a trophie showing achievement/level 
    // --- Null trophie for 0 EXP tokens in the account 
    // --- Distinct 5 trophies, each trophie for certain EXP token held in the account 
    // --- Ex: Tier-1 trophie for users who have 1 to 20 EXP tokens
    // --- Tier-2 trophies for users who have 21 to 40 EXP tokens and so on...
    function tokenURI(uint256 _tokenID) public view override returns (string memory) {
        // Make sure _tokenID is valid 
        require(_exists(_tokenID), "Invalid TokenID");
        // Get the owner of the _tokenID
        address owner_ = ownerOf(_tokenID); 
        // We need owner's EXP token balance
        // Based on balance, we can prepare a variable that denotes which 
        // Symbol should be written in the center of the circle. 
        // Get owner's EXP token holdings
        uint256 ownerBal = IERC20(_EXPContractAddress).balanceOf(owner_);
        // Why don't we get decimals as well. Tokens can be radically different and we 
        // dont want any hardcoded dependencies in our code 
        // @Todo: find a simpler way to get decimals and don't worry about hardcoded logic within
        // level calculation in the library

        // Now we have following details required to generate a tokenURI 
        // owner of the nft, nft token ID, owner's EXP balance 
        // We dont need to pass any hex color name or code 
        // As everything is handled by the library, specifically _prepareSVGContainer, and _prepareColors
        return EthernautFactory._generateTokenURI(
            _tokenID, 
            ownerBal, 
            owner_
        );
    }


    /**
     * ==================================================================
     *          FUNCTIONS (Public) - Making ERC721 Soulbound
     * ==================================================================
     */

    /// @dev functions that are restricted 
    /// Overridden from ERC721 and modifier to reflect 
    /// Soulbound nature of the NFT
    function approve(address, uint256) public override {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        revert TokenIsSoulbound();
    }

    function getApproved(uint256) public view override returns (address) {
        this;
        revert TokenIsSoulbound();
    }

    function setApprovalForAll(address, bool) public override {
        this;
        revert TokenIsSoulbound();
    }

    function isApprovedForAll(address, address) public view override returns (bool) {
        this;
        revert TokenIsSoulbound();
    }

    function transferFrom(address, address, uint256) public override {
        this;
        revert TokenIsSoulbound();
    }

    function safeTransferFrom(address, address, uint256) public override {
        this;
        revert TokenIsSoulbound();
    }

    function safeTransferFrom(address, address, uint256, bytes memory) public override {
        this;
        revert TokenIsSoulbound();
    }
}