# SoulBound - ERC20 + ERC721 - EXPerienceNFT 
SoulBound ERC20 - Bounty on EthernautDAO
SoulBound ERC721 - Bounty on EthernautDAO

## Current deployments 
EXPToken (Rinkeby) = https://rinkeby.etherscan.io/address/0x67A89D96Dd50Ee95450B535Ec8F7812Ea5E70851
EXPerienceNFT (Rinkeby) = https://rinkeby.etherscan.io/address/0xbb6f3641b5a1884e1315c4f838c6a6c43e3cebac
OpenSea = https://testnets.opensea.io/collection/experience-nft-544ojjimlv
Rarible = https://rinkeby.rarible.com/collection/0xbb6f3641b5a1884e1315c4f838c6a6c43e3cebac/items

## Bounty Details 
### Soulbound ERC20 
- Implement a setApprovedMinter(address, bool) onlyOwner function 
- No limit on total supply
- Transfer capabilities must be disabled after minting (soulbound)

- Files have been updated to change EXPtoken to my own take that I was working under EXPerienceGame repo
- Current Soulbound implementation also supports API3's QRNG implementation of random numbers 

## Bounty Details 
### Soulbound ERC721 

- Mintable NFT, nontransferable capable of reading and displaying how many EXP tokens you have in your wallet
- Create a fully on-chain generative ASCII art showing numbers from 1 to 100
- All mints start with the number 0
- The number shown by the NFT must reflect the EXP balance of the owner on the NFT
- Transfer capabilities must be disabled after minting (soulbound) 

### Test it
- clone this repo 
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

- Install dependencies, this will install eth-brownie and other required packages
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

- Deploy on testnet, and perform THE MOST BASIC function (As other functionality tests are still WIP)
- This will deploy EXPerienceNFT contract, it also expects EXPToken contract address from the env file 
```
brownie run .\scripts\_deploy_dev_nft.py --network development 
```

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
Transaction sent: 0x06d1d5371fe3f83a06df52eb4476e251bd35847b8997dd743fd283813d4b93bc
  Gas price: 1.499999992 gwei   Gas limit: 1145400   Nonce: 244
  EXPToken.constructor confirmed   Block: 10801178   Gas used: 1041273 (90.91%)
  EXPToken deployed at: 0x67A89D96Dd50Ee95450B535Ec8F7812Ea5E70851

// Once EXPToken contract is deployed, we can now generate sponsor wallet 
// We do this by requesting derive-sponsor-wallet-address from airnode-admin utils from api3 

Execute this in other teaminal, and save result for the next input box.
npx @api3/airnode-admin derive-sponsor-wallet-address --airnode-xpub xpub6DXSDTZBd4aPVXnv6Q3SmnGUweFv6j24SK77rSFuhGgi666awUiXakjXruUSCDQhhctVG7AQt67gMdaRAsDnDXv23bBRKsMWvRzo6kbf --airnode-address 0x9d3C147cA16DB954873Ae0af5852AB39139f2 --sponsor-address 0x67A89D96Dd50Ee95450B535Ec8F7812Ea5E70851

Waiting till you get the sponsor address... Press any key once received...
Enter sponsor Wallet - 0x4FB24A33a8795a1A3Df72c575c840E6Bf4973e43

Sponsor wallet received - 0x4FB24A33a8795a1A3Df72c575c840E6Bf4973e43

Trimmed address is now 0x4FB24A33a8795a1A3Df72c575c840E6Bf4973e43
Verify sponsor address. We're now setting request params. Press any key to continue...

// After the address is received, it will perform setRequestParams to sett
// airnode and requesters addresses

Transaction sent: 0xab9702f9421588c1c856d7706e5ed2fe27a96dc27847dad1f64015167721c1d9
  Gas price: 1.499999992 gwei   Gas limit: 100545   Nonce: 245
  EXPToken.setRequestParameters confirmed   Block: 10801180   Gas used: 91405 (90.91%)

// Set token admin for EXPToken
// And perform basic EXP Token distribution 

Transaction sent: 0xe2763a8f12692730cbc6dbce2e5b51df8b384e018c5ac4f4287c47d7f397c8fe
  Gas price: 1.499999992 gwei   Gas limit: 53054   Nonce: 246
  EXPToken.setTokenAdmin confirmed   Block: 10801181   Gas used: 48231 (90.91%)

Transaction sent: 0x5c43ec2ccf2553cbe237bfbf3975508e26eb1696254c2456fddd67a48bc9e789
  Gas price: 1.499999992 gwei   Gas limit: 78056   Nonce: 247
  EXPToken.gainExperience confirmed   Block: 10801182   Gas used: 70960 (90.91%)

Transaction sent: 0x8674947e73f2cacd686de45fee2b164ef95111ac3f68583ea306cfb08719eeac
  Gas price: 1.499999992 gwei   Gas limit: 59259   Nonce: 93
  EXPToken.gainExperience confirmed   Block: 10801183   Gas used: 53872 (90.91%)

Transaction sent: 0xb1896f919c0c7672c478992291984cb6664d6e6e13f6ba4b0b6c30661654ace7
  Gas price: 1.499999992 gwei   Gas limit: 59259   Nonce: 248
  EXPToken.gainExperience confirmed   Block: 10801185   Gas used: 53872 (90.91%)

Transaction sent: 0xa551793c984af67cc8e15c4d2f8b57ce2460356f0b5a42df18e65febff388840
  Gas price: 1.499999991 gwei   Gas limit: 59259   Nonce: 94
  EXPToken.gainExperience confirmed   Block: 10801186   Gas used: 53872 (90.91%)

Transaction sent: 0x1e513aa4331dcb1dd5aafed3958a8a05db16b6594c994e37372f211040b6a5e7
  Gas price: 1.499999991 gwei   Gas limit: 59259   Nonce: 249
  EXPToken.gainExperience confirmed   Block: 10801187   Gas used: 53872 (90.91%)

// EXPerienceNFT Contract deployed 
// Perform basic NFT distributions

Transaction sent: 0xee80172c2d15e62378ecf495b1367d55f60079b5ec3d7ccc0b6cba1524b847ad
  Gas price: 1.499999991 gwei   Gas limit: 126890   Nonce: 250
  EXPerienceNFT.generateExperienceNFT confirmed   Block: 10801193   Gas used: 80257 (90.91%)

Transaction sent: 0x682e328b992dde6c46a32718e8d0dff0f54fec6c67894446d1da30521f763575
  Gas price: 1.499999991 gwei   Gas limit: 88282   Nonce: 254

Transaction sent: 0x65866808162528e8354a98f514aa7c73e2dd59bebc2dabff10e3eb570da00e22
  Gas price: 1.499999991 gwei   Gas limit: 88282   Nonce: 96
  EXPerienceNFT.generateExperienceNFT confirmed   Block: 10801195   Gas used: 80257 (90.91%)

  Gas price: 1.499999992 gwei   Gas limit: 88282   Nonce: 255
  EXPerienceNFT.generateExperienceNFT confirmed   Block: 10801196   Gas used: 80257 (90.91%)

Transaction sent: 0x49cf3dd4a1f6e5878b818fc60559bff7295493667ae0a2d11bec034b9929897a
  Gas price: 1.499999992 gwei   Gas limit: 88282   Nonce: 256
  EXPerienceNFT.generateExperienceNFT confirmed   Block: 10801197   Gas used: 80257 (90.91%)

Transaction sent: 0x3bbad1de91f4cd441de7bc87351219809a9e5805e098bc7c2fb4b248cb49483f
  Gas price: 1.499999992 gwei   Gas limit: 88282   Nonce: 97
  EXPerienceNFT.generateExperienceNFT confirmed   Block: 10801198   Gas used: 80257 (90.91%)

Transaction sent: 0xb1fb8321a33c085b4c362775542b3e28c131e23c2fbf0c7242192b9100af9e54
  Gas price: 1.499999992 gwei   Gas limit: 88282   Nonce: 257
  EXPerienceNFT.generateExperienceNFT confirmed   Block: 10801199   Gas used: 80257 (90.91%)


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
