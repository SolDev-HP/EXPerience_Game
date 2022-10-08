// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@api3/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol";

/** 
 * @title Creating a way for EXPToken to be a requester and request for random 
 * number from API3 QRNG implementing Airnodes
 * @author SolDev-HP (https://github.com/SolDev-HP)
 * @dev Allow a way to easily disintegrate QRNG functionality from EXPToken 
 */
contract QRNGRequester is RrpRequesterV0, Ownable {

    /**
     * ==================================================================
     *                          STATE VARIABLES
     * ==================================================================
     */
    // Now we need storage for parameters 
    // airnode - this is the location of Airnode that has implemented Airnode Rrp
    // endpointIdUnit256 - A path on airnode, that will provide us the random result.
    // It's like we are requesting randomness, but from a specific path that handles uint256
    // sponsor wallet - The address that happens to fulfill the request through airnode
    address public aApiProviderAirnode;
    address public aSponsorWallet;
    bytes32 public btEndpointIdUint256;

    // mapping of who requested for randomness based on requestId that we receive
    // when we send a request for randomness, but it has to stay internal so we can utilize it
    // within EXPToken contract 
    mapping(bytes32 => address) internal mRequestIdToWhoRequested;
    // the mapping that will store requestId and corresponding details if 
    // request has been fulfilled or not. 
    // So when let's say admin calls generateRandomExperienceForPlayer(address _player)
    // That function should make a request for random number 
    // This request creates a request ID and is added into the mapping with boolean indicating 
    // that request is yet to fulfilled. Once we receive a callback from the airnode 
    // this request ID will then be marked false, as it has been fulfilled now 
    mapping(bytes32 => bool) internal mExpectingRequestWithIdToBeFulfilled;

    
    /**
     * ==================================================================
     *                              EVENTS
     * ==================================================================
     */
    // Events to notify whether request was made, or response was received 
    event RandomNumberRequested(bytes32 indexed btRequestId);
    event RandomNumberReceived(bytes32 indexed btRequestId, uint256 iResponse);

    // If incase EXPToken inherits this contract, it has to simply adapt to 
    // passing airnode address that has rrp implementation from api3
    constructor(address aRrpAirnode) RrpRequesterV0(aRrpAirnode) { }

    // Set request parameters,
    // Once deployed, next task should be setting request parameters, which are then 
    // utilized while making the request for the random number
    // These request parameters are then passed to makeFullRequest 
    // on AirnodeRrpV0 to perform random number request 
    function setRequestParameters(
        address _airnode, 
        bytes32 _endpointIdUint256, 
        address _sponsorWallet) public onlyOwner 
    {
        // We need to make sure this function stays within reach of admin only 
        // Hence we try to include the ownable contract  
        aApiProviderAirnode = _airnode;
        btEndpointIdUint256 = _endpointIdUint256;
        aSponsorWallet = _sponsorWallet;
    }


    // We need a function that can request for randomness 
    function requestRandomEXPerienceForPlayer(address _whichPlayer) public onlyOwner {
        // Request for randomness for the player and save the interfaceID 
        // for later reference 
        // call makeFullRequest from AirnodeRrp contract with the details 
        // that we already have and hold on to request id for later 
        // fulfilment 
        // airnodeRrp is the address that we set within the constructor 
        bytes32 requestId = airnodeRrp.makeFullRequest(
            aApiProviderAirnode,         // Airnode's address where this request will be forwarded 
            btEndpointIdUint256,          // A path to uint256 for a single random uint256 number
            address(this),              // Sponsor, who is sponsoring this request 
            aSponsorWallet,              // Sponsor's wallet that will be calling the fulfill on AirnodeRrp
            address(this),              // Where the callback function for fulfillment resides 
            this.fulfillRandomNumberRequest.selector,   // which callback function to call upon fulfilment 
            ""                          // Any other paramters (usually the case when requesting Array(random array filled with different type values))
        );
        // we have the request id now, set it in the mapping
        mExpectingRequestWithIdToBeFulfilled[requestId] = true;
        // return our requestId so tht we can handle it within EXPToken contract
        // Once we receive the interface id, update mapping 
        mRequestIdToWhoRequested[requestId] = _whichPlayer;
        // So that later we can find this player and update their experience when 
        // we receive the callback from AirnodeRrp 
        // emit the event 
        emit RandomNumberRequested(requestId);
    }


    // For QRNG 
    // We will be using QRNGRequester contract
    // To generate random uint, we will use the function already implemented within that contract 
    // However, the callback function is listed here because we want to use 
    // the received results 
    function fulfillRandomNumberRequest(bytes32 _requestId, bytes calldata data) external virtual onlyAirnodeRrp {
        // So we can add this into derived contract 
        // Keeeeep empty for a reason. when requesting, we also send function signature of this function
        // Though it is overridden in exp token contract, it makes sense to have the function signature here so 
        // that selector can select, and eventually exp token's version of this function gets executed when fulfillment 
        // occurs.
    } 

}