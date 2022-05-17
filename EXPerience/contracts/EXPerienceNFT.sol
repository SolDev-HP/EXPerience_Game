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

    // Events 
    event ExperienceNFTGenerated(address indexed _experienceGainer);

    // Constructor of EXPerience NFT Contract, expects nama and symbol of the NFT Contract 
    // and address where EXP Token is deployed
    constructor(string memory _name, string memory _symbol, address _expcontract) 
        ERC721(_name, _symbol) {
        // Set EXP Contract address 
        _EXPContract = _expcontract;
    }
}