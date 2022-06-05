import os 
from brownie import EXPToken, accounts, network
from dotenv import load_dotenv
load_dotenv()

def main():
    sadmin_account = accounts.add(os.getenv("PRIVATE_KEY_SADMIN"))
    admin2_account = accounts.add(os.getenv("PRIVATE_KEY_ADMIN2"))
    hodler1_account = accounts.add(os.getenv("PRIVATE_KEY_HODLER1"))
    hodler2_account = accounts.add(os.getenv("PRIVATE_KEY_HODLER2"))

    EXPerience = EXPToken.deploy("EXPerience", "EXP", {"from": sadmin_account}) #, publish_source=True)

    # Add another admin
    EXPerience.setTokenAdmins(os.getenv("PUBLIC_KEY_ADMIN2"), True, {"from": sadmin_account})
    # Mint some EXP to Hodler1 from Admin1
    # It's like adding a new user to play the game. Every user starts with 1 EXP minted by admin for them
    EXPerience.gainExperience(os.getenv("PUBLIC_KEY_HODLER1"), 1 * 10 ** 18, {"from": sadmin_account})
    # Mint some EXP to Hodler2 from Admin2 
    EXPerience.gainExperience(os.getenv("PUBLIC_KEY_HODLER2"), 1 * 10 ** 18, {"from": admin2_account})


"""
// Keeping this for future reference, further implementation requires some reference and this is a 
// good starting point.
def main():
    # requires brownie account to have been created
    if network.show_active()=='development':
        # add these accounts to metamask by importing private key
        owner = accounts[0]
        SolidityStorage.deploy({'from':accounts[0]})
        VyperStorage.deploy({'from':accounts[0]})

    elif network.show_active() == 'kovan':
        # add these accounts to metamask by importing private key
        owner = accounts.load("main")
        SolidityStorage.deploy({'from':owner})
        VyperStorage.deploy({'from':owner})
"""