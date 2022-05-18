import os 
from brownie import BaseCon, BaseTwo, accounts
from dotenv import load_dotenv
from yaml import load
load_dotenv()

def main():
    dev_sadmin = accounts.add(os.getenv("DEV_SADMIM_PRIV"))
    dev_admin2 = accounts.add(os.getenv("DEV_ADMIM2_PRIV"))

    bContract = BaseCon.deploy({"from": dev_sadmin})
    b2Contract = BaseTwo.deploy({"from": dev_admin2})
    
    print("InterfaceId with XOR between interface selectors & supportInt func")
    print(bContract.supportedInterfacesBySelectors({"from": dev_sadmin}))

    print("InterfaceId with XOR between interface selectors only")
    print(bContract.supportedInterfaces({"from": dev_sadmin}))

    print("InterfaceId with type(Interface).interfaceId")
    print(bContract.supportsImpMe({"from": dev_sadmin}))

    # Must be true
    # bContract.supportedInterfaces({"from": dev_sadmin}) === bContract.supportsImpMe({"from": dev_sadmin})

    print("InterfaceId of IERC20Metadata")
    print(b2Contract.baseTwoInterface({"from": dev_sadmin}))