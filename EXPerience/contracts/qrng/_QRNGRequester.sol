// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
// This import is dumb. But node_module is already present in ExperienceDapp
// And this is a combined project anyway. So it's fine, eventually everything
// gets flattened into one thing. so remember to adjust this path wherever 
// airnode protocol is installed. Those base contracts are necessary to make your contract 
// understand request-response protocol and handle the random number received
import "../../client/EXPerienceDapp/node_modules/@api3/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol";

abstract contract QRNGRequester is RrpRequesterV0 {
    // Events to notify whether request was made, or response was received 
    event RandomNumberRequested(bytes32 indexed _requestId);
    event RandomNumberReceived(bytes32 indexed _requestId, uint256 _response);

    // Now we need storage for parameters 
    // airnode - this is the location of Airnode that has implemented Airnode Rrp
    // endpointIdUnit256 - A path on airnode, that will provide us the random result.
    // It's like we are requesting randomness, but from a certain path that handles uint256
    // sponsor wallet - The address that will pay for the fees when callback happens 
    address public airnodeAddress;
    bytes32 public endpointIdUint256;
    address public sponsorWallet;
    // Currently we use inhouse dumb implementation of owner for this contract to be maintained internally 
    address private _owner;

    // the mapping that will store requestId and corresponding details if 
    // request has been fulfilled or not. 
    // So when let's say admin calls generateRandomExperienceForPlayer(address _player)
    // That function should make a request for random number 
    // This request creates a request ID and is added into the mapping with boolean indicating 
    // that request is yet to fulfilled. Once we receive a callback from the airnode 
    // this request ID will then be marked false, as it has been fulfilled now 
    mapping(bytes32 => bool) public expectingRequestWithIdToBeFulfilled;

    // As soon as we deploy this contract, we need to provide airnode's address
    // This address (contract) will handle our request and is responsible for making the 
    // callback to our mentioned function 
    constructor(address _airnodeAddress) RrpRequesterV0(_airnodeAddress) { _owner = msg.sender; }

    // Set request parameters,
    // Once deployed, next task should be setting request parameters, which are then 
    // utilized while making the request 
    function setRequestParameters(
        address _airnode, 
        bytes32 _endpointIdUint256,
        address _sponsorWallet
        ) external {
            require(msg.sender == _owner, "QRNG Access Control");
            // We need to make sure this function stays within reach of admin only 
            // Hence we try to include the ownable contract  
            airnodeAddress = _airnode;
            endpointIdUint256 = _endpointIdUint256;
            sponsorWallet = _sponsorWallet;
        }

    // MakeFullRequest will send the request to AirnodeRrp 
    // And corresponding requestID mapping will be set to true as we expect it to be fulfilled 
    function makeRequestForRandomNumber() external returns (bytes32) {
        // Validate sender before proceeding 
        require(msg.sender == _owner, "QRNG Access Control");
        // call makeFullRequest from AirnodeRrp contract with the details 
        // that we already have and hold on to request id for later 
        // fulfilment 
        // airnodeRrp is the address that we set within the constructor 
        bytes32 requestId = airnodeRrp.makeFullRequest(
                                airnodeAddress,             // Airnode's address where this request will be forwarded 
                                endpointIdUint256,          // A path to uint256 for a single random uint256 number
                                address(this),              // Sponsor, who is sponsoring this request 
                                sponsorWallet,              // Sponsor's wallet that will be paying for the fees of the callback
                                address(this),              // Where the callback function for fulfillment resides 
                                this.fulfillRandomNumberRequest.selector,   // which callback function to call upon fulfilment 
                                ""                          // Any other paramters (usually the case when requesting Array(random array filled with different type values))
                            );
        // we have the request id now, set it in the mapping
        expectingRequestWithIdToBeFulfilled[requestId] = true;
        // emit the event 
        emit RandomNumberRequested(requestId);
        // return our requestId so tht we can handle it within EXPToken contract
        return requestId;
    }

    // Now the function, that will handle the fulfilment 
    // This function will be called back by AirnodeRrp, so it has to be 
    // limited to airdropRrp in terms of access 
    // We'll implement this within EXPToken. Based on fulfillment, we need to set the experience 
    // so let's add that into EXPToken contract 
    function fulfillRandomNumberRequest(bytes32 _requestId, bytes calldata data) external virtual;
}