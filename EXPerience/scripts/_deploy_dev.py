import os, sys
_loggerPath = os.path.abspath("./scripts/")
sys.path.append(_loggerPath)
import _logprinter as Logs
from brownie import EXPToken, accounts, Contract, AirnodeRrpV0
from dotenv import load_dotenv
load_dotenv()

def main():
    dev_sadmin = accounts.add(os.getenv("DEV_SADMIM_PRIV"))
    dev_admin2 = accounts.add(os.getenv("DEV_ADMIM2_PRIV"))
    dev_hodler1 = accounts.add(os.getenv("DEV_HODLER1_PRIV"))
    dev_hodler2 = accounts.add(os.getenv("DEV_HODLER2_PRIV"))
    # Additionally we now need AitnodeRrp address. We'll use address(0) for dev network 
    # as locally we aren't testing any randomness 
    
    # We need to deploy dummy AirnodeRrp contract so that EXPToken can be deployed 
    # Reason: EXPToken depends on AirnodeRrp's address at construction
    # IAirnodeRrp constructs by calling following 
    # IAirnodeRrpV0(_airnodeRrp).setSponsorshipStatus(address(this), true);
    # and we need to mock .setSponsorshipStatus() function call
    # We modify dev script in following way
    airnodeRrp = AirnodeRrpV0.deploy({"from": dev_sadmin})
    # @Todo Whenever deployed, check previous deployments of AirnodeRrp in artifacts/deployment
    # - Get [AirnodeRrp_address] from map.json
    # - find if [AirnodeRrp_address].json exists in dev/
    # - If it is, load the contract address into a var [airnodRrp]
    # - Else, deploy contract AirnodeRrpV0.sol from kb_contracts/ (Mock AirnodeRrp provider), store address into a var [airnodRrp]
    # - Use var [airnodRrp] address to deploy EXPToken @EXPToken.deploy(... airnodeRrp, ..)

    EXPerience = EXPToken.deploy("EXPerience", "EXP", airnodeRrp, {"from": dev_sadmin})

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
    except BaseException as err:
        Logs.logExceptionMakeReadable(err)

    try:
        EXPerience.reduceExperience(os.getenv("DEV_HODLER1_PUB"), 1 * 10 ** 18, {"from": dev_hodler1}) #should fail
    except BaseException as err:
        Logs.logExceptionMakeReadable(err)

    # Hodler1 tries to tranfer/approve 
    try:
        EXPerience.transfer(os.getenv("DEV_HODLER2_PUB"), 1 * 10 ** 18, {"from": dev_hodler1}) #should fail
    except BaseException as err:
        Logs.logExceptionMakeReadable(err)

    # Same as hodler2
    try: 
        EXPerience.approve(os.getenv("DEV_HODLER1_PUB"), 1 * 10 ** 18, {"from": dev_hodler1}) #should fail
    except BaseException as err:
        Logs.logExceptionMakeReadable(err)