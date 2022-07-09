# ReadMe tailored towards deploying EXPerienceNFT to Optimism 

- Clone this repo 
- Make sure you get dev/finalize_v01 branch 
```
https://github.com/SolDev-HP/EXPerience_Game.git
```

- Setup your python virtual environement (Don't want those deps spilling over to others)
```
python -m venv .venv
```

- Activate your virtual environment
```
python ./.venv/scripts/activate 
```

- Install dependencies, this will install eth-brownie, dotenv-python, cython, and other required packages
```
pip install -r requirements.txt
```

- Change into project directory 
```
cd EXPerience
```

- Prepare environment variables, create .env file from .env.example file and add required details
```
cp .env.example .env
```

- [For local Development]
- If you're using local ganache-cli for deployment, make sure you update following variables inorder for deployement script to run and deploy required contracts 

```
DEV_SADMIM_PUB = ""
DEV_SADMIM_PRIV = ""
DEV_ADMIM2_PUB = ""
DEV_ADMIM2_PRIV = ""
DEV_HODLER1_PUB = ""
DEV_HODLER1_PRIV = ""
DEV_HODLER2_PUB = ""
DEV_HODLER2_PRIV = ""
```

- [For Optimism Mainnet Deployment]

```
OPT_SADMIN_PUB = ""
OPT_SADMIN_PRIV = ""
OPT_ADMIN2_PUB = ""     // Optional, contract deployer can add admins later on using setTokenAdmins method in relevant contracts
OPT_ADMIN2_PRIV = ""    // Optional
```

- We are using OpenZeppelin and API3 packages within brownie, hence once inside the token directory, install brownie packages using following commands 
```
brownie pm install OpenZeppelin/openzeppelin-contracts@4.6.0
brownie pm install api3dao/airnode@0.6.3
```
- (note) all brownie does is, looks onto github by following pattern to find requested package version from repo
```
[ORGANIZATION]/[REPOSITORY]@[VERSION]
```

- Compile the project
```
brownie compile 
OR
brownie compile --size (to view contract sizes after compiling)
```

------------------------------------------------------------------------------------------------------------------------------------------------

Optimism mainnet and kovan testnet deployment instructions. 

- Make sure you have optimism-kovan and optimism-mainnet added to the brownie's network list 

```
> brownie networks list
Brownie v1.16.4 - Python development framework for Ethereum

The following networks are declared:

Ethereum
  ├─Mainnet (Infura): mainnet
  ├─Ropsten (Infura): ropsten
  ├─Rinkeby...
...
Optimism
  ├─optimism-kovan (Infura): optimism-kovan
  ├─optimism-mainnet (Infura): optimism-mainnet
```

- Add it like this if missing
```
> $ brownie networks add [environment] [id] host=[host] [KEY=VALUE, ...]

- Optimism Kovan testnet
> brownie networks add Optimism optimism-kovan host=host_url chainid=69
```


------------------------------------------------------------------------------------------------------------------------------------------------

# Contracts folder structure and files details 
```
EXPerience/contracts/.
|
├───[ EXPerienceNFT.sol ]             // EXPerience NFT (ERC721) contract
    ├───|  Sighash   |   Function Signature
        |  ========================
        |  c64b8b4d  =>  getNFTLibraryAddress()
        |  ff736cd6  =>  getEXPTokenAddress()
        |  de0e9957  =>  changeEXPTokenAddress(address)
        |  c55de52e  =>  changeNFTFactoryAddress(address)
        |  3789f8d1  =>  setTokenAdmin(address,bool)
        |  d794e59a  =>  generateExperienceNFT(address)
        |  18160ddd  =>  totalSupply()
        |  c87b56dd  =>  tokenURI(uint256)
        |  095ea7b3  =>  approve(address,uint256)
        |  081812fc  =>  getApproved(uint256)
        |  a22cb465  =>  setApprovalForAll(address,bool)
        |  e985e9c5  =>  isApprovedForAll(address,address)
        |  23b872dd  =>  transferFrom(address,address,uint256)
        |  42842e0e  =>  safeTransferFrom(address,address,uint256)
________|  b88d4fde  =>  safeTransferFrom(address,address,uint256,bytes)
|
├───[ EXPToken.sol ]                  
|   // EXP Token (ERC20) contract. 
|   // Deployment address of this should be passed as arg while deploying EXPerience NFT contract
│
├───interfaces
│   │   ISoulbound.sol            // Ignorable (not used in EXPerienceNFT.sol) SBT interface. Soulbound can be added to any ERC721/ERC20 contract.
│   │
│   └───extensions                // ignore for now
├───kb_contracts                  // ignore for now
├───libs  
│       BadgeFactory.sol          // Badge SVG generator factory. TokenURI generation logic (onchain)
│       EthernautFactory.sol      // Ethernaut SVG generator factory. TokenURI generation logic (svg code from aleta in EthernauDAO)
│
├───qrng
│       QRNGRequester.sol         // If planning on using randomness, API3 QRNG requester contract
│
├───tokens
└───utils
        Base64.sol                // Base64 modified to use bytes (shouldn't be used in production)
```

------------------------------------------------------------------------------------------------------------------------

# SoulBound - ERC20 + ERC721 - EXPerienceNFT 
SoulBound ERC20 - Bounty on EthernautDAO
SoulBound ERC721 - Bounty on EthernautDAO

## Current deployments 
EXPToken (Rinkeby) = https://rinkeby.etherscan.io/address/0xaF88F460053af481d49B4Db70Bf26a613b9c2372

EXPerienceNFT (Rinkeby) = https://rinkeby.etherscan.io/address/0xEF54196aC12356C17F77B6d19dF44a059F4fAbB9

OpenSea = https://testnets.opensea.io/collection/experience-nft-hb2vqfzqks

Rarible = https://rinkeby.rarible.com/collection/0xef54196ac12356c17f77b6d19df44a059f4fabb9/items

## Bounty Details (Bounty 1 - Soulbound ERC20)
### Soulbound ERC20 
- Implement a setApprovedMinter(address, bool) onlyOwner function 
- No limit on total supply
- Transfer capabilities must be disabled after minting (soulbound)

- Files have been updated to change EXPtoken to my own take that I was working under EXPerienceGame repo
- Current Soulbound implementation also supports API3's QRNG implementation of random numbers 

## Bounty Details (Bounty 2 - Soulbound ERC721)
### Soulbound ERC721 

- Mintable NFT, nontransferable capable of reading and displaying how many EXP tokens you have in your wallet
- Create a fully on-chain generative ASCII art showing numbers from 1 to 100
- All mints start with the number 0
- The number shown by the NFT must reflect the EXP balance of the owner on the NFT
- Transfer capabilities must be disabled after minting (soulbound) 

### Test it

This script performs following steps:
1. Deploys EXPerience NFT contract 
2. Demonstrates how set admin works 
3. Demonstrate how NFT minting works 

- Another script is deployall, this script performs following operations
```
brownie run .\scripts\deployall_rinkeby.py --network rinkeby
```

1. Gets admin account, second admin, holders, qrng airnode address from the env file 
2. Deploy EXPToken contract 
3. Ask user to generate sponsor wallet using derive-sponsor-wallet-address
4. Set request parameters for airnode rrp 
5. set token admin 
6. Gain experience for holders (x5)
7. Request a random number experience for a holder 
8. Deploy EXPerienceNFT contract using EXPToken contract address 
9. Set token admin
10. Generate NFT for the players 

### Current Status + Deployment on rinkeby 

- Verify you have .env prepared and above steps followed.

```
(.venv)> brownie run .\scripts\deployall_rinkeby --network rinkeby
Brownie v1.16.4 - Python development framework for Ethereum

ExperienceProject is the active project.

// EXPToken contract is getting deployed here 

Running 'scripts\deployall_rinkeby.py::main'...
Transaction sent: 0xc1301bac132fae1c684c5c36d1810a225dd432f79b55723ffd246d360cd65529
  Gas price: 1.499999991 gwei   Gas limit: 1145400   Nonce: 259
  EXPToken.constructor confirmed   Block: 10801610   Gas used: 1041273 (90.91%)
  EXPToken deployed at: 0xaF88F460053af481d49B4Db70Bf26a613b9c2372

// Once EXPToken contract is deployed, we can now generate sponsor wallet 
// We do this by requesting derive-sponsor-wallet-address from airnode-admin utils from api3 

Execute this in other teaminal, and save result for the next input box.
npx @api3/airnode-admin derive-sponsor-wallet-address --airnode-xpub xpub6DXSDTZBd4aPVXnv6Q3SmnGUweFv6j24SK77W4qrSFuhGgi666awUiXakjXruUSCDQhhctVG7AQt67gMdaRAsDnDXv23bBRKsMWvRzo6kbf --airnode-address 0x9d3C147cA16DB954873A498e0af5852AB39139f2 --sponsor-address 0xaF88F460053af481d49B4Db70Bf26a613b9c2372

Waiting till you get the sponsor address... Press any key once received...
Enter sponsor Wallet - 0xE76ed3BEC63A9A175895Eb9a68b18692590FC7d4

Sponsor wallet received - 0xE76ed3BEC63A9A175895Eb9a68b18692590FC7d4

Trimmed address is now 0xE76ed3BEC63A9A175895Eb9a68b18692590FC7d4
Verify sponsor address. We're now setting request params. Press any key to continue...

// After the address is received, it will perform setRequestParams to sett
// airnode and requesters addresses

Transaction sent: 0xe6942d6d2f26e45d3b1443862151b68f0733d033d949352d909dba0287a9050f
  Gas price: 1.499999992 gwei   Gas limit: 100545   Nonce: 260
  EXPToken.setRequestParameters confirmed   Block: 10801612   Gas used: 91405 (90.91%)

// Set token admin for EXPToken
// And perform basic EXP Token distribution 

Transaction sent: 0xa9fae3f6bf6fc074e6f8305f41af6a2b11d4a7979293657f42d8dfa1b1c36d9a
  Gas price: 1.499999991 gwei   Gas limit: 53054   Nonce: 261
  EXPToken.setTokenAdmin confirmed   Block: 10801613   Gas used: 48231 (90.91%)

Transaction sent: 0x3f6f473e2f977bcf3d1a6e6519da963d2b3948361446a35b699df7a940183017
  Gas price: 1.499999991 gwei   Gas limit: 78056   Nonce: 262
  EXPToken.gainExperience confirmed   Block: 10801614   Gas used: 70960 (90.91%)

Transaction sent: 0xc5584c86a4c0d62ce14acec5f7e3685d72fa3390c15eb20a7b5d96eca18999ff
  Gas price: 1.499999991 gwei   Gas limit: 59259   Nonce: 99
  EXPToken.gainExperience confirmed   Block: 10801615   Gas used: 53872 (90.91%)

Transaction sent: 0xffede9c49ecf7c5f62a6320869cd0ecae63e75347b660be52ed69904f0bee564
  Gas price: 1.499999991 gwei   Gas limit: 59259   Nonce: 263
  EXPToken.gainExperience confirmed   Block: 10801616   Gas used: 53872 (90.91%)

Transaction sent: 0x47eca2a841eda30b85ca9136c44bc0295827afd7f82aa952d6c4fd8b3915cc3f
  Gas price: 1.499999991 gwei   Gas limit: 59259   Nonce: 100
  EXPToken.gainExperience confirmed   Block: 10801617   Gas used: 53872 (90.91%)

Transaction sent: 0xebeb16346395860b89a4ff4d44c3ae8de8c3fa127bbd6ae94517320c2f31ebdd
  Gas price: 1.499999991 gwei   Gas limit: 59259   Nonce: 264
  EXPToken.gainExperience confirmed   Block: 10801618   Gas used: 53872 (90.91%)

Transaction sent: 0x4ebd5a197e459ba88901ece04fe895afe59db5820e9fe01b34b22ae67a2cfc37
  Gas price: 1.49999999 gwei   Gas limit: 59259   Nonce: 101
  EXPToken.gainExperience confirmed   Block: 10801619   Gas used: 53872 (90.91%)

Transaction sent: 0x74c239354d1d9e48b390e385f053eddefb75000e57758226614a448a81eb8d60
  Gas price: 1.499999991 gwei   Gas limit: 59259   Nonce: 102
  EXPToken.gainExperience confirmed   Block: 10801620   Gas used: 53872 (90.91%)

// Request a random uint256 number from API3 QRNG airnode 

Transaction sent: 0xd590d3efa640721aa4d2f72227c59dfb2bff25026f7c541c42403b7ad434bbd4
  Gas price: 1.499999991 gwei   Gas limit: 126890   Nonce: 265
  EXPToken.requestRandomEXPerienceForPlayer confirmed   Block: 10801621   Gas used: 115355 (90.91%)


// EXPerienceNFT Contract deployed 
// Perform basic NFT distributions

Verify that the transaction went through. Wait for randomness fulfillment to occur. And then Press any key to continue...
Transaction sent: 0x28260cd8633e34af5ff914c8429f61b7b60e5b3309028dc8bee4a5c52692f51c
  Gas price: 1.499999991 gwei   Gas limit: 6025507   Nonce: 266
  EXPerienceNFT.constructor confirmed   Block: 10801623   Gas used: 5477734 (90.91%)
  EXPerienceNFT deployed at: 0xEF54196aC12356C17F77B6d19dF44a059F4fAbB9

// Basic NFT distribution 
// Users already hold EXP tokens now so NFT will be able to display their 
// levels denoted by EXPToken balance 

Transaction sent: 0x15309b3c8e6b4784867b2d60ca5117150eaad6fba0cad11c6168f1e6593815dd
  Gas price: 1.499999991 gwei   Gas limit: 52684   Nonce: 267
  EXPerienceNFT.setTokenAdmin confirmed   Block: 10801624   Gas used: 47895 (90.91%)

Transaction sent: 0xdba9f8e2308c699126ceda50e41ac82e15a828dfa4d56b0060e100eb04abf351
  Gas price: 1.499999991 gwei   Gas limit: 107092   Nonce: 268
  EXPerienceNFT.generateExperienceNFT confirmed   Block: 10801626   Gas used: 97357 (90.91%)

Transaction sent: 0x4dcd27cc9feac95850daa251a7fbef7c42b2dc42c71a513db373b428b4b30bd4
  Gas price: 1.49999999 gwei   Gas limit: 88282   Nonce: 103
  EXPerienceNFT.generateExperienceNFT confirmed   Block: 10801627   Gas used: 80257 (90.91%)

Transaction sent: 0x4a696c23344bf1b17c708a8e5fb9a462fc5b73f86ffd69e2c97a61e6472724d4
  Gas price: 1.49999999 gwei   Gas limit: 88282   Nonce: 269
  EXPerienceNFT.generateExperienceNFT confirmed   Block: 10801628   Gas used: 80257 (90.91%)

Transaction sent: 0xdb3165f4712e580493eb15b6c9c8009afb0e03d81e528bd2d3336747ec05c1a5
  Gas price: 1.49999999 gwei   Gas limit: 88282   Nonce: 104
  EXPerienceNFT.generateExperienceNFT confirmed   Block: 10801629   Gas used: 80257 (90.91%)

Transaction sent: 0x2a35078d4c297a47c8ae572871b12742eb4f65fc1968ff19071f7beb6e1e05df
  Gas price: 1.49999999 gwei   Gas limit: 88282   Nonce: 270
  EXPerienceNFT.generateExperienceNFT confirmed   Block: 10801630   Gas used: 80257 (90.91%)

Transaction sent: 0xb7cfc6cfb2fee379f2d75a8da7641d1b9d8674fdbad7b469bee65bd3b732307b
  Gas price: 1.49999999 gwei   Gas limit: 88282   Nonce: 271
  EXPerienceNFT.generateExperienceNFT confirmed   Block: 10801631   Gas used: 80257 (90.91%)

Transaction sent: 0xf8a0c47f3386bafd254c6f86a30126bdec9ee1c00777c9fb52fa34d71dfefa1c
  Gas price: 1.49999999 gwei   Gas limit: 88282   Nonce: 105
  EXPerienceNFT.generateExperienceNFT confirmed   Block: 10801632   Gas used: 80257 (90.91%)

Transaction sent: 0xbd336e6056db1a76413101a2134a3fdb20c86f79545898cd20add80c5e03b8a1
  Gas price: 1.49999999 gwei   Gas limit: 88282   Nonce: 272
  EXPerienceNFT.generateExperienceNFT confirmed   Block: 10801633   Gas used: 80257 (90.91%)


---------------------------------------------------------------------------------------------
Deployment bytecode sizes 

New compatible solc version available: 0.8.13
Compiling contracts...
  Solc version: 0.8.13
  Optimizer: Enabled  Runs: 200
  EVM Version: Istanbul        
Generating build data...
 - OpenZeppelin/openzeppelin-contracts@4.6.0/Ownable
 - OpenZeppelin/openzeppelin-contracts@4.6.0/IERC20
 - OpenZeppelin/openzeppelin-contracts@4.6.0/ERC721
 - OpenZeppelin/openzeppelin-contracts@4.6.0/IERC721
 - OpenZeppelin/openzeppelin-contracts@4.6.0/IERC721Receiver
 - OpenZeppelin/openzeppelin-contracts@4.6.0/IERC721Metadata
 - OpenZeppelin/openzeppelin-contracts@4.6.0/Address        
 - OpenZeppelin/openzeppelin-contracts@4.6.0/Context
 - OpenZeppelin/openzeppelin-contracts@4.6.0/Strings
 - OpenZeppelin/openzeppelin-contracts@4.6.0/ERC165 
 - OpenZeppelin/openzeppelin-contracts@4.6.0/IERC165
 - EXPerienceNFT
 - EthernautFactory
 - Base64

============ Deployment Bytecode Sizes ============
  EXPerienceNFT     -  24,502B  (99.69%)
  ERC721            -   4,685B  (19.06%)
  EXPToken          -   3,746B  (15.24%)
  ERC20             -   2,182B  (8.88%)
  QRNGRequester     -   1,643B  (6.69%)
  RrpRequesterV0    -     165B  (0.67%)
  BadgeFactory      -      86B  (0.35%)
  Base64            -      86B  (0.35%)
  EthernautFactory  -      86B  (0.35%)
  Strings           -      86B  (0.35%)

---------------------------------------------------------------------------------------------
Unit tests status

tests\test_EXPToken_contract.py ................                                         [ 84%]
tests\test_EXPerienceNFT_contract.py ...                                                 [100%]

========================================== Coverage =========================================== 

  contract: EXPerienceNFT - 28.2%
    EXPerienceNFT.generateExperienceNFT - 100.0%
    ERC721._mint - 75.0%
    ERC721._safeMint - 75.0%
    ERC721.balanceOf - 75.0%
    ERC721._checkOnERC721Received - 16.7%
    Strings.toHexString - 4.5%
    Ownable.transferOwnership - 0.0%
    Strings.toString - 0.0%

Coverage report saved at .\EXPerience\reports\coverage.json
View the report using the Brownie GUI
======================================= 19 passed 24.68s ====================================== 

// Weeeeellll... Noooiiicceeeeeee.. 
// Further interactions can be done using 
brownie console --network [rinkeby/ropsten/development]

```
