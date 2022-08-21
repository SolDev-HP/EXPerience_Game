# from branch dev/for_optimism_deployment we have seperated NFT URI generator library
# and EXPerienceNFT contract. This script expects that EXP erc20 contract has already been 
# deployed and contract address is present in .env file @ OPT_EXP_TOKEN_CONTRACT
# EXP NFT contract constructor expects following input 
# EXPerience("Name", "Symbol", EXP Token contract address)
import os 
from brownie import EXPerienceNFT, Contract, accounts
from dotenv import load_dotenv
load_dotenv()

def main():
    # First we try to deploy ethernaut factory 
    # =========================== Accounts Setup =====================================
    # As usual, take our admin account from rinkeby list 
    admin_account = accounts.add(os.getenv("OPT_KOVAN_SADMIN_PRIV"))
    second_admin = accounts.add(os.getenv("OPT_KOVAN_ADMIN2_PRIV"))
    
    expToken_address = str(os.getenv("OPT_EXP_TOKEN_CONTRACT"))

    # Now deploy EXPerienceNFT contract 
    experienceNFT = EXPerienceNFT.deploy("EXPerienceNFT", "nEXP", expToken_address, {"from": admin_account})

    # Set second token admin on EXPerienceNFT
    experienceNFT.setTokenAdmin(os.getenv("OPT_KOVAN_SADMIN_PUB"), True, {"from": admin_account})

    # Send EXP NFT to hodlers 
    try:
        # Send to self first
        experienceNFT.generateExperienceNFT(os.getenv("OPT_KOVAN_SADMIN_PUB"), {"from": admin_account})
        # Allow second admin to send to self
        experienceNFT.generateExperienceNFT(os.getenv("OPT_KOVAN_ADMIN2_PUB"), {"from": second_admin})
        # Test send to other holders
        experienceNFT.generateExperienceNFT(os.getenv("OPT_KOVAN_HODL1_PUB"), {"from": second_admin})
        experienceNFT.generateExperienceNFT(os.getenv("OPT_KOVAN_HODL2_PUB"), {"from": second_admin})
    except:
        print("Some problem while generating EXP NFT")

    # Verify all deployment and NFT representation on opensea and rarible 

    # Deploy ethernaut factory