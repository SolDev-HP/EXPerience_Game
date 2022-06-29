# Testing this on L1 first before moving on to Optimism deployment changes 

# from branch dev/for_optimism_deployment we have seperated NFT URI generator library
# and EXPerienceNFT contract. This means we have to deploy two contracts initially
# but later updates are easier and have functions exposed from EXPerienceNFT contract
# to allow changes 
import os 
from brownie import EthernautFactory, EXPToken, EXPerienceNFT, Contract, accounts
from dotenv import load_dotenv
load_dotenv()

def main():
    # First we try to deploy ethernaut factory 
    # =========================== Accounts Setup =====================================
    # As usual, take our admin account from rinkeby list 
    admin_account = accounts.add(os.getenv("PRIVATE_KEY_SADMIN"))
    second_admin = accounts.add(os.getenv("PRIVATE_KEY_ADMIN2"))
    
    # Deploy EXP token first, as it will be used in EXPerienceNFT contract 
    expToken = EXPToken.deploy("EXP Token", "EXP", {"from": admin_account})
    expToken_address = str(expToken)

    # Now deploy Ethernaut library
    ethFactory = EthernautFactory.deploy({"from": admin_account})
    ethFactory_address = str(ethFactory)

    # Now deploy EXPerienceNFT contract 
    experienceNFT = EXPerienceNFT.deploy("EXPerienceNFT", "nEXP", expToken_address, ethFactory_address, {"from": admin_account})

    # Set second token admin on EXP Token
    expToken.setTokenAdmin(os.getenv("PUBLIC_KEY_ADMIN2"), True, {"from": admin_account})
    # Set second token admin on EXPerienceNFT
    experienceNFT.setTokenAdmin(os.getenv("PUBLIC_KEY_ADMIN2"), True, {"from": admin_account})
    
    # Deploy ethernaut factory