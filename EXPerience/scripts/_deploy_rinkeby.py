import os 
from brownie import EXPToken, accounts, network
from dotenv import load_dotenv
load_dotenv()

# Using the same file as Ropsten deploy script. Nothing much changes here 
# as both accounts of admin, and user within environment has enough rinkeby and ropsten eths
# to process test transactions 
def main():
    sadmin_account = accounts.add(os.getenv("PRIVATE_KEY_SADMIN"))
    admin2_account = accounts.add(os.getenv("PRIVATE_KEY_ADMIN2"))

    EXPerience = EXPToken.deploy("EXPerience", "EXP", {"from": sadmin_account}) #, publish_source=True)

    # Add another admin
    EXPerience.setTokenAdmins(os.getenv("PUBLIC_KEY_ADMIN2"), True, {"from": sadmin_account})
    # Mint some EXP to Hodler1 from Admin1
    # It's like adding a new user to play the game. Every user starts with 1 EXP minted by admin for them
    # Level 1 checking 
    EXPerience.gainExperience(os.getenv("PUBLIC_KEY_HODLER1"), 15 * 10 ** 18, {"from": sadmin_account})
    # Mint some EXP to Hodler2 from Admin2 - Level 2 checking 
    EXPerience.gainExperience(os.getenv("PUBLIC_KEY_HODLER2"), 29 * 10 ** 18, {"from": admin2_account})
    # Mint some EXP to Hodler2 from Admin2 - Level 3 checking 
    EXPerience.gainExperience(os.getenv("PUBLIC_KEY_HODLER3"), 42 * 10 ** 18, {"from": admin2_account})
    # Mint some EXP to Hodler2 from Admin2 - Level 4 checking 
    EXPerience.gainExperience(os.getenv("PUBLIC_KEY_HODLER4"), 69 * 10 ** 18, {"from": admin2_account})
    # Mint some EXP to Hodler2 from Admin2 - Level 2 checking 
    EXPerience.gainExperience(os.getenv("PUBLIC_KEY_HODLER5"), 97 * 10 ** 18, {"from": admin2_account})

