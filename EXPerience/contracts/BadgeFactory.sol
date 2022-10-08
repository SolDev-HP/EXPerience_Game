// Following a factory pattern as BadgeFactory stands to become a factory
// of royalty points, rewards & loyalty programs, ticketing & vanue passes system,
// and increased customers engagement.
// SPDX-Lincense-Identifier: MIT
pragma solidity >=0.8.0;

// We need to import EXPToken contract and EXPerienceNFT contract
// This will later be changed to reflect RewardsPoints and Loyalty badges
// BadgeFactory will maintain a list of already deployed Badges on chain
import "./EXPerienceNFT.sol";
import "./EXPToken.sol";
// Need ownable to maintain owner-limited certain functions
import "@openzeppelin/contracts/access/Ownable.sol";

contract BadgeFactory is Ownable {
    // Maintaining total list of all deployers and their deployments 
    // First, how many points contracts did msg.sender create
    mapping(address => uint256) private _total_points_deployed;
    // Now, where's each one of those deployments
    mapping(uint256 => EXPToken) private _deployed_points_erc20;
    // Similarly we'd wanna track how many erc721 badges were deployed 
    mapping(address => uint256) private _total_badges_deployed;
    // And where's each one 
    mapping(uint256 => EXPerienceNFT) private _deployed_badges_erc721;
    // Who are all these deployers? Do we want to show all active deployments?
    // Incase we want to seperate points deployers from badge deployers
    // These will be used by frontend incase we show all active deployments of points and badges
    address[] private _points_deployers;
    uint256 private _total_pointsDeployers;
    address[] private _badges_deployers;
    uint256 private _total_badgesDeployers;

    constructor() {
        // Thinking about doing anything here?
    }

    /// @notice Deploys ERC20 points contract 
    /// @dev Non-transferable erc20 points, mostly used by erc721 as base to reflect points and such.
    /// @dev Registers msg.sender as the deployer of those points
    function deploy_points_erc20(string memory sName, string memory sSymbol) public {
        // Anyone can deploy Points
        // Their current deployment number, this is where the new one will be deployed
        // And the number will be incremented to reflect total no of deployed erc20 contracts
        uint256 current_total = _total_points_deployed[msg.sender];
        // Deploy at current number
        _deployed_points_erc20[current_total] = new EXPToken(sName, sSymbol);
        // Increase the original reference in mapping for total deployments 
        _total_points_deployed[msg.sender]++;
        // If current total is 0, this is first deployment, else - total deployments are registered anyway
        // Add the deployer to reference list 
        if(current_total == 0) {
            // Add the new deployer into the list
            _points_deployers.push(msg.sender);
            // increase deployers count 
            _total_pointsDeployers++;
        }
    }

    /// @notice Deploys ERC721 badges contract that reflects erc20 points balance
    /// @dev Non-transferable erc721 badges, use given erc20 as base to show holding balance
    /// @dev Registers msg.sender as the deployer of those badges
    /// @dev :todo Transfer ownership of deployed contract to msg.sender
    function deploy_badges_erc721_with_erc20_attached
    (
        address aEXPTokenAddress,
        string memory sName,
        string memory sSymbol
    ) public {
        // Anyone can deploy badges
        // Check how many badges collection are already deployed by this deployer
        uint256 currentTotal = _total_badges_deployed[msg.sender];
        // Deploy badges at current index 
        _deployed_badges_erc721[currentTotal] = new EXPerienceNFT(sName, sSymbol, aEXPTokenAddress);
        // Increase the total 
        _total_badges_deployed[msg.sender]++;

        // Now as we did with points, badges will have similar check
        // to register and maintain a list of badges deployers
        if(currentTotal == 0) {
            // first deployment 
            _badges_deployers.push(msg.sender);
            // increase the total
            _total_badgesDeployers++;
        }
    }

    /// @notice Deploys ERC721 badges that do not utilize erc20 as their base 
    /// @dev Non-transferable ERC721 badges, mostly onchain svg + some way to add verification if this is used as ticketing/entry-pass
    /// @dev Registers msg.sender as the deployer of those badges
    // function deploy_badges_erc721_without_points
    // (
    //     string memory sName,
    //     string memory sSymbol
    // ) public {
    //     // A simple badge, msg.sender regitered as deployed
    //     _deployedBadges_erc721[msg.sender] = new Badges(sName, sSymbol);
    // }

    /// @notice Get total points deployment by owner
    /// @dev get total number of points deployment by owner 
    /// @return uint256 number of total deployments (erc20 points)
    function get_total_points_deployments_by_owner(address aDeployerAddress) public view returns (uint256) {
        // Simply return the number 
        return _total_points_deployed[msg.sender];
    }

    /// @notice Get total badges deployment by owner
    /// @dev get total number of badges deployment by owner 
    /// @return uint256 number of total deployments (erc721 badges)
    function get_total_badges_deployments_by_owner(address aDeployerAddress) public view returns (uint256) {
        // Simply return the total number of badges by deployer 
        return _total_badges_deployed[msg.sender];
    }

    /// @notice Get nth points deployment
    /// @dev get nth points deployment by owner 
    /// @return address of points contract
    function get_nth_points_contract_address(address aDeployedBy, uint256 uContractIndex) public view returns (EXPToken) {
        // Do we have any deployments by aDeployedBy?
        // contract number has to be less than total deployment, otherwise return latest one 
        if(uContractIndex >= _total_points_deployed[aDeployedBy]) {
            return _deployed_points_erc20[_total_points_deployed[aDeployedBy]-1];
        }

        // Return the requested contract 
        return _deployed_points_erc20[uContractIndex];
    }

    /// @notice Get nth badges deployment
    /// @dev get nth badges deployment by owner 
    /// @return address of badges contract
    function get_nth_badges_contract_address(address aDeployedBy, uint256 uContractIndex) public view returns (EXPerienceNFT) {
        // Do we have any badges deployment at given index?
        if(uContractIndex >= _total_badges_deployed[aDeployedBy]) {
            return _deployed_badges_erc721[_total_badges_deployed[aDeployedBy]-1];  // Return the latest badge contract address
        }

        // Return the badge address present at given index 
        return _deployed_badges_erc721[uContractIndex];
    }
}