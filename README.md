#### EXPerience Game project. This will allow users to play a game (Yet to be decided upon, Dino game could be interesting too) and submit their score. In return they get EXP tokens that signify their experience. Later we will include EXPerience NFT. These are soulbound tokens and NFTs. Once minted to an address, can not be transferred to anyone else. This is for EthernautDAO bounty submission.
#### Author: 0micronat_. (SolDev-HP)

A slightly old version of contract is deployed and verified on ropsten: 0x8a573359959aD898b145BF19b6cc461a2c7EaCE2

Things I am currently working on:
- Make basic angular frontend for users to interact with the whole idea of EXPerience (ERC20 + NFT + Leaderboard)
- Import NFT contracts after testing and verification 

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
```
# If deploying to development (ganache-cli), make sure you have .env file prepared according to the .env.example 
brownie run .\scripts\_deploy_dev.py --network development 
# If deploying to any other chain (Ex: ropsten)
brownie run .\scripts\_deploy_ropsten.py --network ropsten
```
#### This will just do following as of now (Status: WIP)

- development script interaction (_deploy_dev.py)
-- Create contract 
-- Add additional admin
-- Gain experience for hodler1 by admin1 
-- Gain experience for hodler2 by admin2 
-- hodler1 tries to gain experience (Fails, AccessControl)
-- hodler1 tries to loose experience (Fails, AccessControl)
-- hodler1 tries to transfer (Fails, Blocked/Unsupported action)
-- hodler2 tries to approve (Fails, Blocked/Unsupported action)

- development script interaction (_deploy_ropsten.py)
-- Create contract 
-- Add additional admin
-- Gain experience for hodler1 by admin1 
-- Gain experience for hodler2 by admin2 


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
- Still need to work on frontend
-- Web3 wallet interaction 
-- Load contract 
-- Read values and represent data in meaningful, tabular format 
-- EX:
--- | Tab1: Wallet Connection | Tab2: Actual game | Tab3: NFT View | Tab4: Leaderboard |
--- |                         | Dino, or more     | Ascii art show | Leaders in        |
--- |                         | games             | EXP amount     | EXPerience        |