# This script should be used/updated accordingly to deploy EXPerience NFT contract
# on Optimism mainnet 
import os 
from brownie import EXPerienceNFT, accounts, Contract
from dotenv import load_dotenv
load_dotenv()

def main():
    # Add deployer account from .env file 
    deployer_account = accounts.add(os.getenv("OPT_SADMIN_PRIV"))

    # Get EXPToken contract address from .env file, as it will be passed as contructor 
    # argument when we deploy EXPerienceNFT contract 
    exp_token_address = str(os.getenv("OPT_EXP_TOKEN_CONTRACT"))

    # Deploy contract to the optimism mainnet 
    # Run this script with 'brownie run opt..deploy.py --network optimism-mainnet
    # Convering this just in case it throws
    try:
        expContract = EXPerienceNFT.deploy("__NAME__", "__SYMBOL__", exp_token_address, {"from": deployer_account})
        # Wait for tx receipt 
        expContract.wait(1)
    except:
        print('Something went wrong, add more [details] here to debug')

    # That's it, user's should now be able to mint themselves EXPerienceNFT 
    # (limited to one per wallet, NFT is mintable to address that do not hold EXPToken - it will simple show 0)
