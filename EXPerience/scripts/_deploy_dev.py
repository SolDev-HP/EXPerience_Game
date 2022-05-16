import os
from brownie import EXPToken, accounts, Contract
from dotenv import load_dotenv
load_dotenv()

def main():
    dev_sadmin = accounts.add(os.getenv("DEV_SADMIM_PRIV"))
    dev_admin2 = accounts.add(os.getenv("DEV_ADMIM2_PRIV"))
    dev_hodler1 = accounts.add(os.getenv("DEV_HODLER1_PRIV"))
    dev_hodler2 = accounts.add(os.getenv("DEV_HODLER2_PRIV"))

    EXPerience = EXPToken.deploy("EXPerience", "EXP", {"from": dev_sadmin})

    # Add another admin
    EXPerience.setTokenAdmins(os.getenv("DEV_ADMIM2_PUB"), True, {"from": dev_sadmin})
    # Mint some EXP to Hodler1 from Admin1
    # It's like adding a new user to play the game. Every user starts with 1 EXP minted by admin for them
    EXPerience.gainExperience(os.getenv("DEV_HODLER1_PUB"), 1 * 10 ** 18, {"from": dev_sadmin})
    # Mint some EXP to Hodler2 from Admin2 
    EXPerience.gainExperience(os.getenv("DEV_HODLER2_PUB"), 1 * 10 ** 18, {"from": dev_admin2})

    # Need to test more functions like transfer/approve/fallback/receive
    # Hodler1 tries to gain/loose experience 
    try:
        EXPerience.gainExperience(os.getenv("DEV_HODLER1_PUB"), 1 * 10 ** 18, {"from": dev_hodler1}) #should fail
    except:
        print(f'AccessControl failure')

    try:
        EXPerience.reduceExperience(os.getenv("DEV_HODLER1_PUB"), 1 * 10 ** 18, {"from": dev_hodler1}) #should fail
    except:
        print(f'AccessControl failure')

    # Hodler1 tries to tranfer/approve 
    try:
        EXPerience.transfer(os.getenv("DEV_HODLER2_PUB"), 1 * 10 ** 18, {"from": dev_hodler1}) #should fail
    except:
        print(f'Unsupported action')

    # Same as hodler2
    try: 
        EXPerience.approve(os.getenv("DEV_HODLER1_PUB"), 1 * 10 ** 18, {"from": dev_hodler1}) #should fail
    except:
        print(f'Unsupported action')