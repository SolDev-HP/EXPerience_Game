// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import "./tokens/ERC20.sol";
import "./utils/Ownable.sol";
// This import is dumb. But node_module is already present in ExperienceDapp
// And this is a combined project anyway. So it's fine, eventually everything
// gets flattened into one thing. so remember to adjust this path wherever 
// airnode protocol is installed. Those base contracts are necessary to make your contract 
// understand request-response protocol and handle the random number received
import "../client/EXPerienceDapp/node_modules/@api3/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol";


/// @author 0micronat_. - https://github.com/SolDev-HP (Playground)
/// @dev EXPToken (EXP) contract that handles minting and assigning EXP to the users 
/// Only primary admin can add other admins 
/// All admin can _mint token to given address, and _burn token from given address 

contract EXPToken is ERC20, Ownable, RrpRequesterV0 {
    // ================= State Vars ==================
    // Now we need storage for parameters 
    // airnode - this is the location of Airnode that has implemented Airnode Rrp
    // endpointIdUnit256 - A path on airnode, that will provide us the random result.
    // It's like we are requesting randomness, but from a certain path that handles uint256
    // sponsor wallet - The address that will pay for the fees when callback happens 
    address public apiProviderAirnode;
    address public sponsorWallet;
    bytes32 public endpointIdUint256;
    // Per user experience point capping = 100 * 10 ** 18
    uint256 internal constant MAXEXP = 100000000000000000000;
    // To test received random number 
    uint256 public randomNumber;

    // Token admins that are allowed to mint/burn tokens
    mapping(address => bool) internal _TokenAdmins;
    // mapping of who requested for randomness based on requestId that we receive
    // when we send a request for randomness, but it has to stay internal so we can utilize it
    // within EXPToken contract 
    mapping(bytes32 => address) internal requestIdToWhoRequestedMapping;
    // the mapping that will store requestId and corresponding details if 
    // request has been fulfilled or not. 
    // So when let's say admin calls generateRandomExperienceForPlayer(address _player)
    // That function should make a request for random number 
    // This request creates a request ID and is added into the mapping with boolean indicating 
    // that request is yet to fulfilled. Once we receive a callback from the airnode 
    // this request ID will then be marked false, as it has been fulfilled now 
    mapping(bytes32 => bool) public expectingRequestWithIdToBeFulfilled;

    // ================= EVENTS ======================
    event TokenAdminUpdated(address indexed admin_, bool indexed isAdmin_);
    // Events to notify whether request was made, or response was received 
    event RandomNumberRequested(bytes32 indexed _requestId);
    event RandomNumberReceived(bytes32 indexed _requestId, uint256 _response);

    // ================= ERRORS ======================
    error ActionNotSupported();

    /// @dev Initialize contract by providing Token name ex: "EXPToken" and symbol ex: "EXP"
    /// This should be able to create ERC20 token, initiator will be the primary admin who 
    /// can add or remove other admins 
    constructor(string memory name_, string memory symbol_, address _airnodeAddress) 
        ERC20(name_, symbol_) 
        RrpRequesterV0(_airnodeAddress)
        {
        /// Make msg sender the first admin 
        _TokenAdmins[msg.sender] = true;
    }

    /// @dev Allow adding/removing admins for EXPToken
    function setTokenAdmins(address admin_, bool isSet_) public OnlyOwner {
        // Add/Remove token admins 
        _TokenAdmins[admin_] = isSet_;
        // Emit the admin update event 
        emit TokenAdminUpdated(admin_, isSet_);
    }

    /// @dev gainExperience function to add experience points to user's EXP balance 
    /// Need to make sure we cap experience to max exp limit
    function gainExperience(address gainer_, uint256 gainAmount_) public {
        // Make sure only admins can call this function 
        require(_TokenAdmins[msg.sender] == true, "EXPToken (AccessControl): Not authorized.");
        // Make use of state variable only once if it's being used multiple times within function
        // In this case, balanceOf will access user's balance state var 
        uint256 _bal = balanceOf(gainer_);
        // Make sure user doesn't already have max exprience points 
        require(_bal < MAXEXP, "EXPToken (Balance): Already at Max(100).");
        // Make sure it doesn't go above capped possible points after _minting 
        require(_bal + gainAmount_ <= MAXEXP, "EXPToken (Balance): Will go above Max(100).");
        // Mint tokens to the address
        _mint(gainer_, gainAmount_);
    }

    /// @dev reduceExperience function to remove exp from user's balance 
    /// Need to make sure, it doesn't go below 0 after deduction and user's balance isn't already zero
    function reduceExperience(address looser_, uint256 lostAmount_) public {
        // Make sure only admins can call this function 
        require(_TokenAdmins[msg.sender] == true, "EXPToken (AccessControl): Not authorized.");
        // Make use of state variable only once if it's being used multiple times within function
        // In this case, balanceOf will access user's balance state var 
        uint256 _bal = balanceOf(looser_);
        // Make sure user's balance isn't already zero 
        require(_bal > 0, "EXPToken (Balance): Insufficient balance");
        // Make sure our calculation doesn't bring it below zero 
        // This calculation here will always throw "Integer Overflow" if _balance < lostAmount_
        // To temporarily mitigate unexpected throws, check is necessary 
        // require(_balance >= lostAmount_, "EXPToken (Balance): Can't go below Min(0).");
        // Burn given amount from user's balance 
        _burn(looser_, lostAmount_);
    }

    /// @dev Overriding ERC20 functions, need to make sure they revert.
    /// To preserve property of a soulbound token. Once minted to an address, cannot be transferred
    /// However, in this implementation, we allow admins to reduce user's balance to zero
    /**
     * Emits a {ActionNotSupported} error.
     */
    function transfer(address, uint256) public view override returns (bool) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        revert ActionNotSupported();
    }

    /**
     * @dev See {IERC20-allowance}.
     * Emits a {ActionNotSupported} error.
     */
    function allowance(address, address) public view override returns (uint256) {
        this;
        revert ActionNotSupported();
    }

    /**
     * @dev See {IERC20-approve}.
     * Emits a {ActionNotSupported} error
     *
     */
    function approve(address, uint256) public view override returns (bool) {
        this;
        revert ActionNotSupported();
    }

    /**
     * @dev See {IERC20-transferFrom}.
     * Emits a {ActionNotSupported} error
     */
    function transferFrom(address, address, uint256) public view override returns (bool) {
        this;
        revert ActionNotSupported();
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * Emits a {ActionNotSupported} error
     */
    function increaseAllowance(address, uint256) public view override returns (bool) {
        this;
        revert ActionNotSupported();
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     * Emits a {ActionNotSupported} error
     */
    function decreaseAllowance(address, uint256) public view override returns (bool) {
        this;
        revert ActionNotSupported();
    }

    // Set request parameters,
    // Once deployed, next task should be setting request parameters, which are then 
    // utilized while making the request 
    function setRequestParameters(address _airnode, bytes32 _endpointIdUint256, address _sponsorWallet) public OnlyOwner {
            require(msg.sender == _owner, "QRNG Access Control");
            // We need to make sure this function stays within reach of admin only 
            // Hence we try to include the ownable contract  
            apiProviderAirnode = _airnode;
            endpointIdUint256 = _endpointIdUint256;
            sponsorWallet = _sponsorWallet;
        }
    // We need a function that can request for randomness 
    function requestRandomEXPerienceForPlayer(address _whichPlayer) public OnlyOwner {
        // Request for randomness for the player and save the interfaceID 
        // for later reference 
        // call makeFullRequest from AirnodeRrp contract with the details 
        // that we already have and hold on to request id for later 
        // fulfilment 
        // airnodeRrp is the address that we set within the constructor 
        bytes32 requestId = airnodeRrp.makeFullRequest(
                                apiProviderAirnode,         // Airnode's address where this request will be forwarded 
                                endpointIdUint256,          // A path to uint256 for a single random uint256 number
                                address(this),              // Sponsor, who is sponsoring this request 
                                sponsorWallet,              // Sponsor's wallet that will be paying for the fees of the callback
                                address(this),              // Where the callback function for fulfillment resides 
                                this.fulfillRandomNumberRequest.selector,   // which callback function to call upon fulfilment 
                                ""                          // Any other paramters (usually the case when requesting Array(random array filled with different type values))
                            );
        // we have the request id now, set it in the mapping
        expectingRequestWithIdToBeFulfilled[requestId] = true;
        // return our requestId so tht we can handle it within EXPToken contract
        // Once we receive the interface id, update mapping 
        requestIdToWhoRequestedMapping[requestId] = _whichPlayer;
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
    function fulfillRandomNumberRequest(bytes32 _requestId, bytes calldata data) external onlyAirnodeRrp {
        // A callback function only accessible by AirnodeRrp
        // Check if we are acutally expecting a request to be fulfilled 
        require (
            expectingRequestWithIdToBeFulfilled[_requestId],
            "Unknown request ID");
        
        // Set the expectations back low
        expectingRequestWithIdToBeFulfilled[_requestId] = true;
        // Now on to the number that we received 
        uint256 qrngUint256 = abi.decode(data, (uint256));
        // Can we limit it to be within 100? But instead, we will first see 
        // what range it sends back 
        randomNumber = qrngUint256;
        // Emit the event stating we received the random number 
        emit RandomNumberReceived(_requestId, qrngUint256); 
    } 
}