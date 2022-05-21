import os 
from brownie import accounts, EXPerienceNFT
from dotenv import load_dotenv
load_dotenv()

# File for Rinkeby deployment would remain same as Ropsten 
# The only change is addition of environment variable,
# we should track different chainID contracts within different 
# variables
def main():
    # These has to be the same account from _deploy_ropsten.py
    # These users have alread interacted with the EXPerience Token EXP
    sadmin_account = accounts.add(os.getenv("PRIVATE_KEY_SADMIN"))
    admin2_account = accounts.add(os.getenv("PRIVATE_KEY_ADMIN2"))

    # Deploy the 
    EXPerienceCon = EXPerienceNFT.deploy("EXPerience NFT", "nEXP", os.getenv("EXP_CONTRACT_RINKEBY"), {"from": sadmin_account})
    # Admin1 adds new admin on EXPerience NFT 
    EXPerienceCon.setTokenAdmin(os.getenv("PUBLIC_KEY_ADMIN2"), True, {"from": sadmin_account})

    # Mint NFT for User1 <- From Admin1
    EXPerienceCon.genExperience(os.getenv("PUBLIC_KEY_HODLER1"), {"from": sadmin_account})     # Shouldn't fail - User has EXP

    # Mint NFT for User2 <- From Admin2
    EXPerienceCon.genExperience(os.getenv("PUBLIC_KEY_HODLER2"), {"from": admin2_account})     # Shouldn't fail - User has EXP

    # Mint NFT for User2 <- From Admin2
    EXPerienceCon.genExperience(os.getenv("PUBLIC_KEY_HODLER3"), {"from": sadmin_account})     # Shouldn't fail - User has EXP

    # Mint NFT for User2 <- From Admin2
    EXPerienceCon.genExperience(os.getenv("PUBLIC_KEY_HODLER4"), {"from": admin2_account})     # Shouldn't fail - User has EXP

    # Mint NFT for User2 <- From Admin2
    EXPerienceCon.genExperience(os.getenv("PUBLIC_KEY_HODLER5"), {"from": sadmin_account})     # Shouldn't fail - User has EXP