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

    # Send some exp tokens to the hodlers 
    # Hodler1 = 0 - to test NFT on non EXP hodler
    try:
        expToken.gainExperience(os.getenv("PUBLIC_KEY_HODLER2"), 1 * 10 ** 18, {"from": admin_account})
        expToken.gainExperience(os.getenv("PUBLIC_KEY_HODLER3"), 26 * 10 ** 18, {"from": second_admin})
        expToken.gainExperience(os.getenv("PUBLIC_KEY_HODLER4"), 57 * 10 ** 18, {"from": second_admin})
        expToken.gainExperience(os.getenv("PUBLIC_KEY_HODLER5"), 79 * 10 ** 18, {"from": second_admin})
        expToken.gainExperience(os.getenv("HOLDER6_RINKBY_PUB"), 99 * 10 ** 18, {"from": second_admin})
    except:
        print("Some problem while generating EXP tokens")
    # Send EXP NFT to hodlers 
    try:
        experienceNFT.generateExperienceNFT(os.getenv("PUBLIC_KEY_HODLER1"), {"from": admin_account})
        experienceNFT.generateExperienceNFT(os.getenv("PUBLIC_KEY_HODLER2"), {"from": second_admin})
        experienceNFT.generateExperienceNFT(os.getenv("PUBLIC_KEY_HODLER3"), {"from": second_admin})
        experienceNFT.generateExperienceNFT(os.getenv("PUBLIC_KEY_HODLER4"), {"from": second_admin})
        experienceNFT.generateExperienceNFT(os.getenv("PUBLIC_KEY_HODLER5"), {"from": second_admin})
        experienceNFT.generateExperienceNFT(os.getenv("HOLDER6_RINKBY_PUB"), {"from": second_admin})
    except:
        print("Some problem while generating EXP NFT")

    # Verify all deployment and NFT representation on opensea and rarible 

    # Deploy ethernaut factory