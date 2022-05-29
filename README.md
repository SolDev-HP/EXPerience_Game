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

### Current status - WORKS!!!  
- EXPToken contract modified accordingly to accommodate QRNG changes 
- deployment script that guides through deployment - generating sponsor wallet 
- So here are the details of my last deployment, that seem to have fulfilled the request for randomness 

- Script is _deploy_exp_with_qrng_rinkeby.py
```
(.venv)> brownie run .\scripts\_deploy_exp_with_qrng_rinkeby.py --network rinkeby
INFO: Could not find files for the given pattern(s).
Brownie v1.16.4 - Python development framework for Ethereum

ExperienceProject is the active project.

// Contract EXPToken gets deployed here

Running 'scripts\_deploy_exp_with_qrng_rinkeby.py::main'...
Transaction sent: 0xeb9e482c4a5a8b4ed28587a8171da88198de8bb07dea8748551c757f96de73d7
  Gas price: 1.013666863 gwei   Gas limit: 1248052   Nonce: 197
  EXPToken.constructor confirmed   Block: 10761804   Gas used: 1134593 (90.91%)  EXPToken deployed at: 0x5F0b68280cc5aD5908FCce9b841C4B7B9808AAA8

// It prompts to get me a sponsor wallet 

Execute this in other teaminal, and save result for the next input box.        
npx @api3/airnode-admin derive-sponsor-wallet-address --airnode-xpub xpub6DXSDTZBd4aPVXnv6Q3SmnGUweFv6j24SK77W4qrSFuhGgi666awUiXakjXruUSCDQhhctVG7AQt67gMdaRAsDnDXv23bBRKsMWvRzo6kbf --airnode-address 0x9d3C147cA16DB954873A498e0af5852AB39139f2 --sponsor-address 0x5F0b68280cc5aD5908FCce9b841C4B7B9808AAA8

// So now that we have a sponsor wallet, we can top it up so that it 
// can send and receive fulfillment requests 
// Rinkeby Eth Balance: 0.002 ETH on 0x272FC11d91a2F6c36DCe71E1D0c8c640aC75EA44
// Tx hash: 0x95d8cd899d530a1e71f7ceaf9d675a8feb8d91763815e9126b95b69b23ac078f

Waiting till you get the sponsor address... Press any key once received...     
Enter sponsor Wallet - 0x272FC11d91a2F6c36DCe71E1D0c8c640aC75EA44

Sponsor wallet received - 0x272FC11d91a2F6c36DCe71E1D0c8c640aC75EA44

Trimmed address is now 0x272FC11d91a2F6c36DCe71E1D0c8c640aC75EA44
Verify sponsor address. We're now setting request params. Press any key to continue...

// Once you verify that you got the sponsor address and you've topped it off
// Script will run basic erc20 functions of adding an admin and assigning some exp tokens to
// public users 

Transaction sent: 0x9f6e8de85cc7ea951c788d27bd55c1f87f4967ddf7703b0f8e90dfba8af86c89
  Gas price: 1.013666864 gwei   Gas limit: 100614   Nonce: 198
  EXPToken.setRequestParameters confirmed   Block: 10761806   Gas used: 91468 (90.91%)

Transaction sent: 0xf1a5775791c4e4f23738991eb9b49589114e26d3d0c8832c34d1a514fde3f082
  Gas price: 1.013666864 gwei   Gas limit: 52720   Nonce: 199
  EXPToken.setTokenAdmins confirmed   Block: 10761807   Gas used: 47928 (90.91%)

Transaction sent: 0xbde2046ce87a6a4dd0d5aaebd69d572f646574248317f06fcc68bd255e6c957b
  Gas price: 1.013666864 gwei   Gas limit: 78062   Nonce: 200
  EXPToken.gainExperience confirmed   Block: 10761808   Gas used: 70966 (90.91%)

Transaction sent: 0xc0f08652f60b3ad9bcc5d8f9ebcaa6f7ced3f73cec235e03efdd68a9177ccff8
  Gas price: 1.013666864 gwei   Gas limit: 59265   Nonce: 82
  EXPToken.gainExperience confirmed   Block: 10761809   Gas used: 53878 (90.91%)

Transaction sent: 0x3ed003891c1070ab390474f12c3b10ee1a9c3a80c27132d80f6eb69439bbbc74
  Gas price: 1.013666863 gwei   Gas limit: 59265   Nonce: 201
  EXPToken.gainExperience confirmed   Block: 10761810   Gas used: 53878 (90.91%)

Transaction sent: 0x7a40a292d277aa6182c0782d1adf9dd5eb99d80143789b7029a9d099dda898c1
  Gas price: 1.013666863 gwei   Gas limit: 59265   Nonce: 83
  EXPToken.gainExperience confirmed   Block: 10761811   Gas used: 53878 (90.91%)

Transaction sent: 0x48063059c1d16c2ebf51734a3ea24cd96e1898c6446bebacafa80d30755acbda
  Gas price: 1.013666862 gwei   Gas limit: 59265   Nonce: 202
  EXPToken.gainExperience confirmed   Block: 10761812   Gas used: 53878 (90.91%)

// Now we track our random number by a public variable that will be filled with 
// the return value when fulfillment callback happens 

Random number before request
0

// THIS - we successfully sent our request for random number 

Transaction sent: 0x8c20e55464d7697ac9b8ff45619bef2dae8e5e6c63c902242eb080f5ae75ff5d
  Gas price: 1.013666862 gwei   Gas limit: 126926   Nonce: 203
  EXPToken.requestRandomEXPerienceForPlayer confirmed   Block: 10761813   Gas used: 115388 (90.91%)

// Now I verified the transaction, but the next step is now to confirm if we receive random number
// or not. At the moment it seems that it hasn't. But on the sponsor address
// there is an interesting transaction 

Verify that the transaction went through. Wait for randomness fulfillment to occur. And then Press any key to continue...

Random number after request
0

// Originates from : Sponsor wallet 0x272fc11d91a2f6c36dce71e1d0c8c640ac75ea44
// Tx Hash : 0x06670ba7e950338efa7c786961b3dfb61feab2ce8dbe18eb78aeb0a5d267a2bc
// To : 0xa0AD79D995DdeeB18a14eAef56A549A04e3Aa1Bd (AirnodeRrpV0)
// here's the input data 

Function: fulfill(bytes32 requestId, address airnode, address fulfillAddress, bytes4 fulfillFunctionId, bytes data, bytes signature)

MethodID: 0x1decbf18
[0]:  7bbb9f206727428f1bd1f6c771ba3f3885eade4daadf361d284576dc7e4c22ad
[1]:  0000000000000000000000009d3c147ca16db954873a498e0af5852ab39139f2
[2]:  0000000000000000000000005f0b68280cc5ad5908fcce9b841c4b7b9808aaa8
[3]:  911a52ba00000000000000000000000000000000000000000000000000000000
[4]:  00000000000000000000000000000000000000000000000000000000000000c0
[5]:  0000000000000000000000000000000000000000000000000000000000000100
[6]:  0000000000000000000000000000000000000000000000000000000000000020
[7]:  60c694e03965ad4ce2ecafed70067d01108463b40a2e2b8119609d9bc5beb6a3
[8]:  0000000000000000000000000000000000000000000000000000000000000041
[9]:  7a24cd73fe1cb8fd480005c58d75cc783a6119b6fd37103d486656633c5f928f
[10]: 5b87070e88b4b7d3b2d1cd3bda150a1f610e41a7ab7d371cf255caeb1918e5ab
[11]: 1b00000000000000000000000000000000000000000000000000000000000000

#	  Name	                Type	Data
0	  requestId	            bytes32	0x7bbb9f206727428f1bd1f6c771ba3f3885eade4daadf361d284576dc7e4c22ad
1	  airnode	              address	0x9d3C147cA16DB954873A498e0af5852AB39139f2
2	  fulfillAddress	      address	0x5F0b68280cc5aD5908FCce9b841C4B7B9808AAA8
3	  fulfillFunctionId	    bytes4	0x911a52ba
4	  data	                bytes	0x60c694e03965ad4ce2ecafed70067d01108463b40a2e2b8119609d9bc5beb6a3
5	  signature	            bytes	0x7a24cd73fe1cb8fd480005c58d75cc783a6119b6fd37103d486656633c5f928f5b87070e88b4b7d3b2d1cd3bda150a1f610e41a7ab7d371cf255caeb1918e5ab1b


// We have a request id that is supposed to be fulfilled 
// 0x7bbb9f206727428f1bd1f6c771ba3f3885eade4daadf361d284576dc7e4c22ad
// Our fulfullment function's location - EXP token contract address 
// 0x5F0b68280cc5aD5908FCce9b841C4B7B9808AAA8
// And function selector for which function to be called 
// fulfillFunctionId	    bytes4	0x911a52ba

And here are the function signatures for better reference 

Sighash   |   Function Signature
========================
39509351  =>  increaseAllowance(address,uint256)
3d14b86c  =>  setTokenAdmins(address,bool)
f56bbc9c  =>  gainExperience(address,uint256)
8ce05e6d  =>  require(_TokenAdmins[msg.sender],"EXPToken)
e0b1e940  =>  reduceExperience(address,uint256)
a9059cbb  =>  transfer(address,uint256)
dd62ed3e  =>  allowance(address,address)
095ea7b3  =>  approve(address,uint256)
23b872dd  =>  transferFrom(address,address,uint256)
a457c2d7  =>  decreaseAllowance(address,uint256)
7bdf2525  =>  setRequestParameters(address,bytes32,address)
d9909f05  =>  requestRandomEXPerienceForPlayer(address)
911a52ba  =>  fulfillRandomNumberRequest(bytes32,bytes)   // fulfillFunctionId

Now we wait for the random number reception 

```

--------------- Work under progress ------------------