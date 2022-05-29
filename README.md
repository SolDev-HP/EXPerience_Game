#### Branch - dev/qrng_implementation
#### QRNG implementation for ERC20 token called EXPToken

How this will work
- EXP Deployer (0xBcE03a4B33337E4776d845909C041CAAD4799790) is responsible for handling responsibilities that comes with when we use Airnode 

- so that airnode is a serverless instance deployed on cloud (GCP, AWS) that registers reqeuests and sends responses back by callbacks 

- API3 QRNG is a service - implemented using Airnode request-response protocol 
- We will be using API QRNG for generating random amount of experience for any wallet (adminOnly function) between 0.01 to 100 (If need to kept uint use 1 to 10000 and // 10 ** 2 the result)

- Step1 - Create a requester,
In our case, the requester will be EXPToken. so we can simply inherit @api3/airnode-protocol and set airnodeRrpAddress to be used when calling for makeRequest
( As it handles quite a bit of other useful things - that I'll think of some use for, we'll implement a base for our requester just like in API3 documentation )

- The protocol's internal working is deployed via npm package @api3/airnode-protocol

- We make sure that we have following things prepared in our .env file 

- AirnodeRrpV0 address -> Supplied when we deploy ERC20 token, because we need to make sure we initialize our requestor contract
- Airnode Address - This is the airnode that will handle tha randomness request, the one who has implemented Airnode Rrp and provides randomness service -> Listed paths (for randomness) https://docs.api3.org/qrng/providers.html
- Path at airnode where our request should be handled, for example: above airnode provider implements uint256 path that doesnt take any params and returns a random uint256 upon processing, and another path that takes one parameter of 'size' and generates that many random numbers and returns and array (Meaning, other paths are also possible)

- Sponsor Wallet - The wallet that will actually make the fulfillment transactions 
Sponsor wallets are derived from api3 airnode admin cli. 
This is derived using following parameters 
Airnode Address, Airnode XPub, And the contract's address itself 

- From docs 
(https://docs.api3.org/airnode/v0.6/grp-developers/requesters-sponsors.html#how-to-derive-a-sponsor-wallet)
```
airnode-xpub: The extended public address of the Airnode for path m/44'/60'/0'.
airnode-address: The public address of the desired Airnode.
sponsor-address: The sponsorAddress (an address of an Ethereum account) owned by a sponsor. Usually the sponsorAddress is the one returned when sponsoring a requester.

npx @api3/airnode-admin derive-sponsor-wallet-address ^
  --airnode-xpub xpub6CUGRUo... ^
  --airnode-address 0xe1...dF05s ^
  --sponsor-address 0xF4...dDyu9

Sponsor wallet address: {0x14D5a34E5a370b9951Fef4f8fbab2b1016D557d9}
```

- current .env structure:
```
# Infura node api details 
WEB3_INFURA_PROJECT_ID = ""
WEB3_INFURA_PROJECT_SECRET = ""
INFURA_ENDPOINT_NETWORK = ""
INFURA_PROJECT_ENDPOINT = ""

# Rinkeby accounts to handle deployments and interactions 
PUBLIC_KEY_SADMIN = ""
PRIVATE_KEY_SADMIN = ""
PUBLIC_KEY_ADMIN2 = ""
PRIVATE_KEY_ADMIN2 = ""
PUBLIC_KEY_HODLER1 = ""
PRIVATE_KEY_HODLER1 = ""
PUBLIC_KEY_HODLER2 = ""
PRIVATE_KEY_HODLER2 = ""
PUBLIC_KEY_HODLER3 = ""
PUBLIC_KEY_HODLER4 = ""
PUBLIC_KEY_HODLER5 = ""

# Etherscan API token
ETHERSCAN_TOKEN = ""

# Dev environment accounts 
DEV_SADMIM_PUB = ""
DEV_SADMIM_PRIV = ""
DEV_ADMIM2_PUB = ""
DEV_ADMIM2_PRIV = ""
DEV_HODLER1_PUB = ""
DEV_HODLER1_PRIV = ""
DEV_HODLER2_PUB = ""
DEV_HODLER2_PRIV = ""

# EXPToken contract deployed location on devnet 
EXP_CONTRACT_DEV = ""

# Deployment and interaction accounts on ropsten 
EXP_CONTRACT_ROPSTEN = ""
EXP_CONTRACT_2_ROPSTEN = ""
EXP_CONTRACT_RINKEBY = ""

# DeadAdd
DEAD_ADD = ""

# Additional public hodlers on Rinkeby.
HOLDER6_RINKBY_PUB = ""
HOLDER7_RINKBY_PUB = ""
HOLDER8_RINKBY_PUB = ""
HOLDER9_RINKBY_PUB = ""
HOLDER10_RINKBY_PUB = ""

# API3 QRNG for true random number generation 
FOR_QRNG_AIRNODE_RRP_RINKEBY = ""
FOR_QRNG_AIRNODE_ADDRESS = 
FOR_QRNG_AIRNODE_ENDPOINT_ID = 
FOR_QRNG_ARINODE_SPONSOR_WALLET = 
```

### Current status 
- EXPToken contract modified accordingly to accommodate QRNG changes 
- deployment script that guides through deployment - generating sponsor wallet 
- Current output conditions 
```
(.venv)> brownie run .\scripts\_deploy_exp_with_qrng_rinkeby.py --network rinkeby
INFO: Could not find files for the given pattern(s).
Brownie v1.16.4 - Python development framework for Ethereum

ExperienceProject is the active project.

Running 'scripts\_deploy_exp_with_qrng_rinkeby.py::main'...
Transaction sent: 0x05932957f4b98f66857b1cc91c3eda9d8ab841023f822cf3021251e67f44439b
  Gas price: 1.500000002 gwei   Gas limit: 1335162   Nonce: 185
  EXPToken.constructor confirmed   Block: 10760110   Gas used: 1213784 (90.91%)  EXPToken deployed at: 0xf27B6083C7a610Fbb0f9888EFE33d17A4f90324a

Execute this in other teaminal, and save result for the next input box. 

npx @api3/airnode-admin derive-sponsor-wallet-address --airnode-xpub xpub6DXSDTZBd4aPVXnv6Q3SmnGUweFv6j24SK77W4qrSFuhGgi666awUiXakjXruUSCDQhhctVG7AQt67gMdaRAsDnDXv23bBRKsMWvRzo6kbf --airnode-address 0x9d3C147cA16DB954873A498e0af5852AB39139f2 --sponsor-address 0xf27B6083C7a610Fbb0f9888EFE33d17A4f90324a

Waiting till you get the sponsor address... Press any key once received...     

Enter sponsor Wallet - 0xB92E82496f05027e232ae4f3Ae7630964d20bbA5
Sponsor wallet received - 0xB92E82496f05027e232ae4f3Ae7630964d20bbA5
Trimmed address is now 0xB92E82496f05027e232ae4f3Ae7630964d20bbA5

Verify sponsor address. We're now setting request params. Press any key to continue...

Transaction sent: 0x1cab38a37332f24e178e18b3610670c3d128688c43383ecfca849fd27727032a
  Gas price: 1.500000002 gwei   Gas limit: 100521   Nonce: 186
  EXPToken.setRequestParameters confirmed   Block: 10760113   Gas used: 91383 (90.91%)

Transaction sent: 0xdd431dc5040cf5f5b014ba9541fd68e5fe8635814c5a8af904affa44d582493a
  Gas price: 1.500000002 gwei   Gas limit: 52746   Nonce: 187
  EXPToken.setTokenAdmins confirmed   Block: 10760114   Gas used: 47951 (90.91%)

Transaction sent: 0x6ce038b796b6f338afc2a38d7c4de9d5f289df05d43b47ebb5f42fd00da6ae03
  Gas price: 1.500000002 gwei   Gas limit: 78062   Nonce: 188
  EXPToken.gainExperience confirmed   Block: 10760115   Gas used: 70966 (90.91%)

Transaction sent: 0xc6c7ac34eb3d61348d9f5d6fc9d5b76f83267f440f3418895a72323c0c7451c1
  Gas price: 1.500000003 gwei   Gas limit: 59265   Nonce: 78
  EXPToken.gainExperience confirmed   Block: 10760116   Gas used: 53878 (90.91%)

Transaction sent: 0x54e1f049caa4c5238dc8adf2f65a820f9fa2c6a4bbfbd2f729495d9bb8e332d0
  Gas price: 1.500000003 gwei   Gas limit: 59265   Nonce: 189
  EXPToken.gainExperience confirmed   Block: 10760117   Gas used: 53878 (90.91%)

Transaction sent: 0xb8a12e20fd1509ce5ff50a938d0abfd3ec5f4e6ffc96779a196f600599b8b3eb
  Gas price: 1.500000003 gwei   Gas limit: 59265   Nonce: 79
  EXPToken.gainExperience confirmed   Block: 10760118   Gas used: 53878 (90.91%)

Transaction sent: 0x0c5631c73c57b90cede8a569b37580fe98c685948fe44bb9090600024974c51b
  Gas price: 1.500000003 gwei   Gas limit: 59265   Nonce: 190
  EXPToken.gainExperience confirmed   Block: 10760119   Gas used: 53878 (90.91%)

Random number before request
0

ValueError: Gas estimation failed: 'execution reverted: QRNG Access Control'. This transaction will likely revert. If you wish to broadcast, you must set the gas limit manually. 
```

--------------- Work under progress ------------------