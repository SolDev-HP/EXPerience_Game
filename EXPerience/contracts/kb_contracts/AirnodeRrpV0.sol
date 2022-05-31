// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../../client/EXPerienceDapp/node_modules/@api3/airnode-protocol/contracts/rrp/AuthorizationUtilsV0.sol";
import "../../client/EXPerienceDapp/node_modules/@api3/airnode-protocol/contracts/rrp/TemplateUtilsV0.sol";
import "../../client/EXPerienceDapp/node_modules/@api3/airnode-protocol/contracts/rrp/WithdrawalUtilsV0.sol";
import "../../client/EXPerienceDapp/node_modules/@api3/airnode-protocol/contracts/rrp/interfaces/IAirnodeRrpV0.sol";

contract AirnodeRrpV0 is
    AuthorizationUtilsV0,
    TemplateUtilsV0,
    WithdrawalUtilsV0,
    IAirnodeRrpV0
{
    // This is interesting. These public mappings are actually implementing 
    // public functions such as requesterToRequestCountPlusOne() and such
    // Now implementation declares them as public variables (mappings) 
    // And as solc generates a getter, that getter would eventually return variable
    // So a mapping would have a default getter like [mappingname].get(at [mappingname][key]) => value
    // It's a nice way to indicate that we require some mappings as well through interface. As interfaces can't 
    // have state variables, I've done this before while using Metadata extension for tokens ERC20 and 721 
    // But this was illustrative that it can be extended to mappings as well
    mapping(address => mapping(address => bool)) public override sponsorToRequesterToSponsorshipStatus;
    mapping(address => uint256) public override requesterToRequestCountPlusOne;
    mapping(bytes32 => bytes32) private requestIdToFulfillmentParameters;

    // just this function, it has to return gracefully so that we can deploy our 
    // EXPToken who's constructor depends on AirnodeRrp contract's setSponsorshipStatus function
    function setSponsorshipStatus(address requester, bool sponsorshipStatus)
        external
        override
    {
        emit SetSponsorshipStatus(msg.sender, requester, sponsorshipStatus);
    }

    // Override remaining functions to just do nothing
    function makeTemplateRequest(
        bytes32 templateId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata parameters
    ) external override returns (bytes32 requestId) {
        uint256 temp;
        emit MadeTemplateRequest(
            sponsor,    // Replaced airnode
            bytes32(""),
            temp,       // replaced request counter
            block.chainid,
            msg.sender,
            templateId,
            sponsor,
            sponsorWallet,
            fulfillAddress,
            fulfillFunctionId,
            parameters
        );
    }
    function makeFullRequest(
        address airnode,
        bytes32 endpointId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata parameters
    ) external override returns (bytes32 requestId) {
        uint256 temp;
        emit MadeFullRequest(
            airnode,
            requestId,
            temp,       // replaced request counter
            block.chainid,
            msg.sender,
            endpointId,
            sponsor,
            sponsorWallet,
            fulfillAddress,
            fulfillFunctionId,
            parameters
        );
    }

    function fulfill(
        bytes32 requestId,
        address airnode,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata data,
        bytes calldata signature
    ) external override returns (bool callSuccess, bytes memory callData) {
        emit FulfilledRequest(airnode, requestId, data);
    }

    function fail(
        bytes32 requestId,
        address airnode,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        string calldata errorMessage
    ) external override {
        emit FailedRequest(airnode, requestId, errorMessage);
    }

    function requestIsAwaitingFulfillment(bytes32 requestId)
        external
        view
        override
        returns (bool isAwaitingFulfillment)
    {
        // Notin'
    }   
}