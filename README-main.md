#### Updates from dev/svg_updates_aleta branch
- Currently deployed to rinkeby with updated svg designs received from Aleta 
- Rinkeby Testnet: https://rinkeby.etherscan.io/address/0xE23ADC5e1E3C47243d0b14Eb8EC0cA7D53901Fab
- Opensea Link: https://testnets.opensea.io/collection/experience-nft-jm2r5z4ecm
- Rarible Link: https://rinkeby.rarible.com/collection/0xe23adc5e1e3c47243d0b14eb8ec0ca7d53901fab/items
- More details within README_dev-svg-updates.md file

#### Deployments 

- View on Opensea: https://testnets.opensea.io/collection/experience-nft-xblcas07kq
- Rinkeby EXP ERC20: https://rinkeby.etherscan.io/address/0x176F9A81168eb265747b98Ce820d97519e67C082
- Rinkeby EXPerience NFT: https://rinkeby.etherscan.io/address/0x3fc8e715b4d83a60a27c87b7037cf4a802f43412

#### Branch: dev/more_dynamic_nft

- Introducing background colors as one of the attributes
- a. It's a sort of mapping we can use to determine following thing at mint time 
- a.1. fairly random background color allocation
- a.2. Evolution are still compared on the fly based on EXP balance 

- Evolution stage is to categorize certain levels threshold, like if you're between level (== EXP balance) 1 and 20, you'll be assigned to wanderer's role/position/evolution stage (as it evolves as you gain more experience/level)

- Evolution stages (That I could come up with after what felt like a heavy brainstorming session with too much coffee)
1. Wanderer       (Level 1 to 20 == EXP balance anywhere between 0 to 20 excluding 0)(Center image in NFT - [A.jpg])
2. Fighter        (Level 21 to 40)(Center image in NFT - [B.jpg])
3. Revolutionary  (Level 41 to 60)
4. Legendary      (Level 61 to 80)
5. God            (Level 81 to 100)

- Current color collection that need to be fairly randomize while NFT is being minted
- (Should be able to give some fancy names to them to make them into funky attributes)

```
Dark Orange -#FF8C00
Black - #000000 
Magenta - #FF00FF
Maroon - #800000
Gray - #808080
Pale Violet Red - #DB7093
Medium Slate Blue - #7B68EE
Crimson - #DC143C
Blue Violet - #8A2BE2
Dark Turquoise - #00CED1
Olive - #808000
Midnight Blue - #191970
Teal - #008080
Navy - #000080
Lime Green - #32CD32
Lavender - #E6E6FA
Medium Sea Green - #3CB371
Light Sea Green - #20B2AA
Chocolate - #D2691E
Aquamarine - #7FFFD4
```
====================================================================================================================================

#### Current Status 
- [x] Create SoulBound ERC20 for EthernautDAO bounty submission (Bounty 1)
- [x] Create SoulBound ERC721 and Integrate (Bounty 2)
- [x] Prepare unit tests for EXPToken Contract
- [ ] Ability for users to see their NFT, a generative ASCII art that displays user's EXP Token balance  -- **[Patially-Done]** 
- [ ] Create Angular frontend to interact with EXPerience Idea -- **[WIP]**
- [ ] Prepare unit test -- **[WIP]** 
- [ ] Ability to view leaderboard (Bounty 3)
- [ ] Additional page to generate hackable levels and playground (Bounty 4)

#### EXPerience Game project. This will allow users to play a game (Yet to be decided upon, Dino game could be interesting too) and submit their score. In return they get EXP tokens that signify their experience. Later we will include EXPerience NFT. These are soulbound tokens and NFTs. Once minted to an address, can not be transferred to anyone else. This is for EthernautDAO bounty submission.
#### Author: 0micronat_. (SolDev-HP)

#### Keeping a journal on Discord to better categorize different ideas under one term/umbrella/direction/vision - SoulVerse (Cheeky I know but due to the lack of better words I could come up with, I would go with this as it represents exactly what I am trying to do here. Develop things into something meaningful.) Discord - https://discord.gg/2fA3jQjs

A slightly old version of contract is deployed and verified on ropsten: 0x8a573359959aD898b145BF19b6cc461a2c7EaCE2
Visit: https://ropsten.etherscan.io/address/0x8a573359959aD898b145BF19b6cc461a2c7EaCE2#code

Latest version (unverified) deployed contracts:

EXP Token
- Ropsten: https://ropsten.etherscan.io/address/0x709ffc7a5ea37f91e727227780d9a6ba7bf3fc27
- Rinkeby: https://rinkeby.etherscan.io/address/0xdf6ae52281c488be9F63156b74429a3272AAeF75

EXPerience NFT
- Ropsten: https://ropsten.etherscan.io/address/0x98c8a11faaf4466eccaf1b00149bdcf696d8793d
- Rinkeby: https://rinkeby.etherscan.io/address/0xe50f0307b3a902885B842D2f89f51D3fCfD5ACA4

Listed on Opensea Testnet (Rinkeby)
- Opensea: https://testnets.opensea.io/collection/experience-nft-l7oqvlyfpg

Things I am currently working on:
- Make basic angular frontend for users to interact with the whole idea of EXPerience (ERC20 + NFT + Leaderboard)
- Unit tests to test all contracts 
- Revert ERC721 to follow original standard and allow potential inheritence to still be able to access original actions. Changes should be overridden in EXPerienceNFT

### How to get going (Frontend doesn't do anything yet, it's just the barebones of ng init EXPerienceDapp) 

### What you'll need (Or better yet, what I have in my local dev environment)
- Python 3.x, requirements will install cython, eth-brownie, python-dotenv
- npm 8.x, node 16.14
- ganache-cli (Running in a separate instance at localhost:8545)
- .env file under ./EXPerience/ that includes environment variables listed in ./EXPerience/scripts/_deploy_dev.py OR ./EXPerience/scripts/_deploy_ropsten.py (If you're planning to deploy this on ropsten. Simplarly you can create deploy scripts for any testnet/mainnet)

### Get it running locally
- Make a directory 
```
mkdir EXPerience  
cd EXPerience
```
- Clone this repo 
```
git clone https://github.com/SolDev-HP/EXPerience_Game.git
```
- Create python virtual environment
```
python -m venv _name_for_vevn
```
- Activate recently created python venv
```
.\._name_for_venv\Scripts\activate
```
- Install all pip packages mentioned in requirements.txt 
```
pip install -r requirements.txt
```
- After the installation, go to EXPerience directory 
```
cd EXPerience 
```
- Run brownie compile to compile all smart contracts present under ./contracts and ./interfaces dir/sub-dir
```
brownie compile
```
- Run the script to interact with the contract with the most basic things I can think of (Status: WIP)
- Currently dev, ropsten, rinkeby scripts are updated
```
# If deploying to development (ganache-cli), make sure you have .env file prepared according to the .env.example 
brownie run .\scripts\_deploy_dev.py --network development 
# If deploying to any other chain (Ex: ropsten)
brownie run .\scripts\_deploy_ropsten.py --network ropsten
# If you're planning on deploying NFT contract next, you'll need EXP token's contract address from ropsten 
# Keep that in .env file 
brownie run .\scripts\_deploy_ropsten_nft.py --network ropsten
```
#### This will just do following as of now (Status: WIP)

##### development script interaction (_deploy_dev.py)
- Create contract 
- Add additional admin
- Gain experience for hodler1 by admin1 
- Gain experience for hodler2 by admin2 
- hodler1 tries to gain experience (Fails, AccessControl)
- hodler1 tries to loose experience (Fails, AccessControl)
- hodler1 tries to transfer (Fails, Blocked/Unsupported action)
- hodler2 tries to approve (Fails, Blocked/Unsupported action)

##### development script interaction (_deploy_ropsten.py)
- Create contract 
- Add additional admin
- Gain experience for hodler1 by admin1 
- Gain experience for hodler2 by admin2 

##### development script interaction (_deploy_ropsten_nft.py)
- Create NFT contract 
- Add additional admin
- Gain experience NFT for hodler1 by admin1 
- Gain experience NFT for hodler2 by admin2 

#### Run the frontend (if you so wish to, because it does nothing at all (no interaction with contracts yet))
#### (Status: WIP)

- Change to EXPerience/client directory 
```
cd ./client 
```
- run npm install to install all packages 
```
npm install 
```
- run ng server on localhost:4200 (should build and run, if it doens't then run "ng build")
```
ng serve --open
```
- Open browser (If it doesn't already) and goto localhost:4200, it will serve you starting page of Angular 

Todos:
- [ ] Still need to work on frontend
- [ ] Web3 wallet interaction 
- [ ] Load contract 
- [ ] Read values and represent data in meaningful, tabular format 
Ex:
```
| Tab1: Wallet Connection | Tab2: Actual game | Tab3: NFT View | Tab4: Leaderboard |
|                         | Dino, or more     | Ascii art show | Leaders in        |
|                         | games             | EXP amount     | EXPerience        |
```

## UML for current implementation (ERC20 - [EXP]erience Token)
![EXPerience_UML](https://github.com/SolDev-HP/EXPerience_Game/blob/master/EXPerience/EXPerience_UML.svg)


### Tests & coverage report (WIP)
```
tests\test_EXPToken_contract.py ...........                              [100%]
================================== Coverage ===================================== 


  contract: EXPToken - 88.7%
    ERC20._mint - 100.0%
    EXPToken.gainExperience - 100.0%
    EXPToken.reduceExperience - 100.0%
    ERC20._burn - 87.5%
    Ownable.owner - 0.0%

Coverage report saved at .\reports\coverage.json
View the report using the Brownie GUI
============================== 25 passed in 27.71s ==============================
```
