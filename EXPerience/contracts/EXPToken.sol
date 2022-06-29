// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// import "./qrng/QRNGRequester.sol";
// For branch: dev/for_optimism_deployment - remove all QRNG ref.
import "./interfaces/ISoulBound.sol";

/** 
 * @title Soulbound ERC20 token implementation - named EXPToken
 * Requirement: 
 *  - Implement a setApprovedMinter(address, bool) onlyOwner function
 *  - No limit on total supply
 *  - Transfer capabilities must be disabled after minting (soulbound)
 * Updates:
 *  - In addition to requirements, we can now generate random numbers 
 *    using API3 QRNG implementation and Airnode on chains 
 *    See: https://api3.org/QRNG
 *  - Separate out functionalities. like, ISoulbound handles soulbound
 *    properties, QRNGRequester handles random numbers from API3 QRNG
 *  - Declutter main EXPToken contract
 * @author SolDev-HP (https://github.com/SolDev-HP)
 * @dev Implement ERC20 in a way that limits tokens capabilities such as 
 * transfer, approval and make it soulbound - once minted, it can not 
 * be transferred
 */

contract EXPToken is ERC20, Ownable, ISoulbound, QRNGRequester {

    /**
     * ==================================================================
     *                          STATE VARIABLES
     * ==================================================================
     */
    // Per user experience point capping @ 100 EXP Tokens
    uint256 internal constant MAXEXP = 100 * 10 ** 18;
    
    /**
     * @dev mapping to map token admins who are allowed to perform 
     * mint operation
     */
    mapping(address => bool) public mTokenAdmins;

    /**
     * ==================================================================
     *                              ERRORS
     * ==================================================================
     */
    
    // Error to indicate that action can only be performed by token admins 
    error OnlyTokenAdminsAllowed();
    // Error to indicate that referenced address is a zero address 
    error InvalidAddress();
    // Error to indicate that performed action has no effects 
    // And hence better to revert instead of unnecessarily access 
    // other state variables  
    error ActionHasNoEffects();

    /**
     *  @dev contructor expects token name (string), token symbol (string)
     *  and our contract is also an instance of requester for 
     *  request-response protocol implemented by on chain AirnodeRrpV0
     *  API3's airnode-protocol->RrpRequesterV0 construction simply sets 
     *  the interface with AirnodeRrpV0 address given by aRrpAirnode 
     *  so that it can SetSponsorshipStatus for this requester 
     */
     // For branch: dev/for_optimism_deployment
     // Remove airnode QRNG logic from EXP token for easy testing of optimism
     // deployment
    constructor(string memory sTokenName, string memory sTokenSymbol) //, address aRrpAirnode)
        ERC20(sTokenName, sTokenSymbol)
        //QRNGRequester(aRrpAirnode)
    {
        // Set deployed the first token admin 
        mTokenAdmins[_msgSender()] = true;
        // We don't need anything else except for setting up following things here
        // IERC165, supportsInterface - IERC20, ISoulbound 
        // For minting when we receive QRNG, we can set airnoderrp as token admin 
        // so that it can mint too, but how feasible is this? better way?
        // mTokenAdmins[aRrpAirnode] = true;
    }


    /**
     * ==================================================================
     *                  FUNCTIONS (Public) - ERC20 
     * ==================================================================
     */

    // We override following functions from OpenZeppelin's ERC20   
    // to make sure EXPToken follows properties of being a soulbound token 
    function transfer(address, uint256) public override returns (bool) {
        // Intended revert, action not allowed 
        revert TokenIsSoulbound();
    }

    function allowance(address, address) public view override returns (uint256) {
        // Always revert 0. There's no allowance for anyone
        return 0;
    }

    function approve(address, uint256) public override returns (bool) {
        // Intended revert, approval is not possible
        revert TokenIsSoulbound();
    }

    function transferFrom(address, address, uint256) public override returns (bool) {
        // Intended revert, cannot be transferred 
        revert TokenIsSoulbound();
    }

    function increaseAllowance(address, uint256) public override returns (bool) {
        // Intended revert, there is no allowance
        revert TokenIsSoulbound();
    }

    function decreaseAllowance(address, uint256) public override returns (bool) {
        // Intended revert, there is no allowance
        revert TokenIsSoulbound();
    }

    /**
     * ==================================================================
     *                  FUNCTIONS (Public) - ISoulbound 
     * ==================================================================
     */

    /** 
     * @notice Set admins
     * @dev ability to set or unset admins, generates TokenAdminSet event
     */
    function setTokenAdmin(address aWhichAddress, bool bIsAdmin) 
        external 
        onlyOwner 
    {
        // Check address validity 
        if (aWhichAddress == address(0)) { revert InvalidAddress(); }
        // Check if operation actually has any effects or should 
        // be disregarded 
        if (mTokenAdmins[aWhichAddress] == bIsAdmin) { revert ActionHasNoEffects(); }
        // Set token admin
        mTokenAdmins[aWhichAddress] = bIsAdmin;
        // Emit the token admin set event 
        emit TokenAdminSet(aWhichAddress, bIsAdmin);
    }


    /// @dev gainExperience function to add experience points to user's EXP balance 
    /// Need to make sure we cap experience to max exp limit
    function gainExperience(address aWhichPlayer, uint256 iHowMuchGained) public {
        // Make sure only token admins can call this function 
        if (!mTokenAdmins[_msgSender()]) { revert OnlyTokenAdminsAllowed(); }
        // Make use of state variable only once if it's being used multiple times within function
        // In this case, balanceOf will access user's balance state var 
        uint256 _bal = balanceOf(aWhichPlayer);
        // Make sure user doesn't already have max exprience points 
        require(_bal < MAXEXP, "EXPToken (GainEXP): Already at Max(100).");
        // Make sure it doesn't go above capped possible points after _minting 
        require(_bal + iHowMuchGained <= MAXEXP, "EXPToken (Balance): Will go above Max(100).");
        // Mint tokens to the address
        _mint(aWhichPlayer, iHowMuchGained);
    }


    /// @dev reduceExperience function to remove exp from user's balance 
    /// Need to make sure, it doesn't go below 0 after deduction and user's balance isn't already zero
    /// This will stay disabled. If required in the future, enabled from ISoulbound
    // function reduceExperience(address looser_, uint256 lostAmount_) public {
    //     // Make sure only admins can call this function 
    //     require(_TokenAdmins[msg.sender] == true, "EXPToken (AccessControl): Not authorized.");
    //     // Make use of state variable only once if it's being used multiple times within function
    //     // In this case, balanceOf will access user's balance state var 
    //     uint256 _bal = balanceOf(looser_);
    //     // Make sure user's balance isn't already zero 
    //     require(_bal > 0, "EXPToken (Balance): Insufficient balance");
    //     // Make sure our calculation doesn't bring it below zero 
    //     // This calculation here will always throw "Integer Overflow" if _balance < lostAmount_
    //     // To temporarily mitigate unexpected throws, check is necessary 
    //     // require(_balance >= lostAmount_, "EXPToken (Balance): Can't go below Min(0).");
    //     // Burn given amount from user's balance 
    //     _burn(looser_, lostAmount_);
    // }


    /**
     * ==================================================================
     *                  FUNCTIONS (Public) - QRNGRequester 
     * ==================================================================
     */

    // Do we even need to set _sposorWallet as token admin so that we can mint
    // when we receive our random number request fulfillment 
    // Testing to see if we can actually pull this off by overriding base class 
    // method, assigning new modifier, and then calling the base class method 
    // once that returns success, we can then mint expected amount of tokens 

    // function fulfillRandomNumberRequest(bytes32 _requestId, bytes calldata data) external override onlyAirnodeRrp {
    //     // A callback function only accessible by AirnodeRrp
    //     // Check if we are acutally expecting a request to be fulfilled 
    //     require (
    //         mExpectingRequestWithIdToBeFulfilled[_requestId],
    //         "Unknown request ID");
        
    //     // Set the expectations back low
    //     mExpectingRequestWithIdToBeFulfilled[_requestId] = false;
    //     // once that is done, we can call mint? 
    //     uint256 qrngUint256 = abi.decode(data, (uint256));
    //     // Emit the event stating we received the random number 
    //     emit RandomNumberReceived(_requestId, qrngUint256); 
    //     // Need qrng between 0.01 and 0.99
    //     // Received -> %100 -> (0 - 99) -> /100 -> is the result EXP tokens 
    //     // doubtful idea :'D
    //     gainExperience(mRequestIdToWhoRequested[_requestId], ((qrngUint256 % 100) * 10 ** 16));

    //     // If we reach here, noooiiiccee!!!

    // }

}