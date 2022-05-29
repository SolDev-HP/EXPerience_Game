// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import "./tokens/ERC20.sol";
import "./utils/Ownable.sol";
import "./qrng/QRNGRequester.sol";

/// @author 0micronat_. - https://github.com/SolDev-HP (Playground)
/// @dev EXPToken (EXP) contract that handles minting and assigning EXP to the users 
/// Only primary admin can add other admins 
/// All admin can _mint token to given address, and _burn token from given address 

contract EXPToken is ERC20, Ownable, QRNGRequester {
    // ================= State Vars ==================
    // Token admins 
    mapping(address => bool) internal _TokenAdmins;
    // Per user experience point capping = 100 * 10 ** 18
    uint256 internal constant MAXEXP = 100000000000000000000;

    // To test received random number 
    uint256 public randomNumber;

    // mapping of who requested for randomness based on requestId that we receive
    // when we send a request for randomness, but it has to stay internal so we can utilize it
    // within EXPToken contract 
    mapping(bytes32 => address) internal requestIdToWhoRequestedMapping;

    // ================= EVENTS ======================
    event TokenAdminUpdated(address indexed admin_, bool indexed isAdmin_);

    // ================= ERRORS ======================
    error ActionNotSupported();

    /// @dev Initialize contract by providing Token name ex: "EXPToken" and symbol ex: "EXP"
    /// This should be able to create ERC20 token, initiator will be the primary admin who 
    /// can add or remove other admins 
    constructor(string memory name_, string memory symbol_, address _airnodeAddress) 
        ERC20(name_, symbol_) 
        QRNGRequester(_airnodeAddress)
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

    // We need a function that can request for randomness 
    function requestRandomEXPerienceForPlayer(address _whichPlayer) public OnlyOwner {
        // Make sure we have airnodeAddress before we proceed for request 
        require(airnodeAddress != address(0), "Set Airnode Address first");
        // Request for randomness for the player and save the interfaceID 
        // for later reference 
        // As it is an external function call even though it's in the same contract. 
        // We can make it makeReqeust_ a public one because it end up calling makeRequest 
        // which is external anyway.
        bytes32 _requestId = this.makeRequestForRandomNumber();
        // Once we receive the interface id, update mapping 
        requestIdToWhoRequestedMapping[_requestId] = _whichPlayer;
        // So that later we can find this player and update their experience when 
        // we receive the callback from AirnodeRrp 
    }
    // For QRNG 
    // We will be using QRNGRequester contract
    // To generate random uint, we will use the function already implemented within that contract 
    // However, the callback function is listed here because we want to use 
    // the received results 
    function fulfillRandomNumberRequest(bytes32 _requestId, bytes calldata data) external onlyAirnodeRrp override {
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