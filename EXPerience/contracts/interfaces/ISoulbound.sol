// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/** 
 * @title ISoulbound interface that outlines important functions that are meant
 * to be implemented in EXPToken.sol to make EXP token soulbound
 * @author SolDev-HP (https://github.com/SolDev-HP)
 * @dev We define our contract's functionality here, certain functions like 
 * setting admins who can mint, expectations of increase and decrease 
 * in experience points (denoted by EXP Tokens) and more for future cases.
 */
interface ISoulbound {

    /**
     * ==================================================================
     *                              ERRORS
     * ==================================================================
     */

    /** 
     * @dev Error to indicate that token is soulbound and action performed 
     * is not supported (ex. transfer, approve, safeTransfer etc.)
     */
    error TokenIsSoulbound();
    
    /**
     * ==================================================================
     *                              EVENTS
     * ==================================================================
     */

    /** 
     * @dev Event to indicate that a token admin has been set/unset 
     */
    event TokenAdminSet(address indexed aWhichAddress, bool indexed bIsAdmin);

    /** 
     * @dev Event to indicate that a player has gained some experience
     * (EXP token mint happened)
     */
    event PlayerGainedExperience(address indexed aWhichPlaeyr, uint8 indexed iHowMuchGained);

    /**
     * ==================================================================
     *                              FUNCTIONS
     * ==================================================================
     */

    /** 
     * @notice Set admins
     * @dev ability to set or unset admins, generates TokenAdminSet event
     */
    function setTokenAdmin(
        address,            /* address of person being set as admin */
        bool                /* given address to set or unset as admin */
    ) external;


    /** 
     * @notice Allow player to gain mentioned experience 
     * @dev As we limit experience (counted by amount EXP tokens) to 100, 
     */
    function gainExperience(
        address,            /* address of the player who'll gain the experience */
        uint256             /* experience gain amount */
    ) external;


    /**
     * @notice at the moment we dont support burning EXPerience tokens 
     * It doesn't make sense to burn already gained experience, but just incase 
     * we find a requirement where losing experience is required, following
     * can be implemented 
     */
    // function loseExperience(
    //     address,         /* address of the player who'll lose the exprience */
    //     uint256          /* amount of experience to be reduced from the player's balance */
    // ) external;
}