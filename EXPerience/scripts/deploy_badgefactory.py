# This deployment script is to test everything related to badgefactory
from brownie import EXPToken, EXPerienceNFT, BadgeFactory, EthernautFactory, Contract, accounts
import os 
from dotenv import load_dotenv
load_dotenv()

def main():
    # Get the deployers (local) - deplying to goerli
    badgefactory_deployer = accounts.add(os.getenv("PRIVATE_KEY_SADMIN"))
    # deploy badgefactory

    badgefactory_contract = BadgeFactory.deploy({"from": badgefactory_deployer})
    input()

    # Allow user 1 to deploy 3 EXPTokens contracts 
    user1 = accounts.add(os.getenv("PRIVATE_KEY_ADMIN2"))
    tx1_deploy_points = badgefactory_contract.deploy_points_erc20("TEStokn1", "TSK1", {"from": user1})
    tx1_deploy_points.wait(1)
    tx2_deploy_points = badgefactory_contract.deploy_points_erc20("TESTok2", "TOK2", {"from": user1})
    tx2_deploy_points.wait(1)
    tx3_deploy_points = badgefactory_contract.deploy_points_erc20("ERC20_34", "ET3", {"from": user1})
    tx3_deploy_points.wait(1)

    # Let's check the balance of user's deployment (points - erc20)
    print(badgefactory_contract.get_total_points_deployments_by_owner(user1.address))

    # And print their addresses 
    print(badgefactory_contract.get_nth_points_contract_address(user1.address, 0))
    print(badgefactory_contract.get_nth_points_contract_address(user1.address, 1))
    print(badgefactory_contract.get_nth_points_contract_address(user1.address, 2))
    print(badgefactory_contract.get_nth_points_contract_address(user1.address, 47))