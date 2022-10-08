# This deployment script is to test everything related to badgefactory
from brownie import EXPToken, EXPerienceNFT, BadgeFactory, EthernautFactory, Contract, accounts, interface, web3
import os 
from dotenv import load_dotenv
load_dotenv()

def main():
    # Get the deployers (local) - deplying to goerli
    badgefactory_deployer = accounts.add(os.getenv("PRIVATE_KEY_SADMIN"))
    # deploy badgefactory

    badgefactory_contract = BadgeFactory.deploy({"from": badgefactory_deployer})
    
    # Total deployers should be zero right now
    print("Total Points (ERC20) Deployers: " + str(badgefactory_contract.get_total_points_deployers()))

    # Allow user 1 to deploy 3 EXPTokens contracts 
    user1 = accounts.add(os.getenv("PRIVATE_KEY_ADMIN2"))
    tx1_deploy_points = badgefactory_contract.deploy_points_erc20("TEStokn1", "TSK1", {"from": user1})
    tx1_deploy_points.wait(1)
    tx2_deploy_points = badgefactory_contract.deploy_points_erc20("TESTok2", "TOK2", {"from": user1})
    tx2_deploy_points.wait(1)
    tx3_deploy_points = badgefactory_contract.deploy_points_erc20("ERC20_34", "ET3", {"from": user1})
    tx3_deploy_points.wait(1)

    # Total deployers should be 1 as user1 is now using badgefactory
    print("Total Points (ERC20) Deployers: " + str(badgefactory_contract.get_total_points_deployers()))
    # Let's check the balance of user's deployment (points - erc20)
    print("Total Points contracts deployed by " + str(user1.address) + " : " + str(badgefactory_contract.get_total_points_deployments_by_owner(user1.address)))

    # And print their addresses 
    print("[Points] Contract 0 At " + str(badgefactory_contract.get_nth_points_contract_address(user1.address, 0)))
    print("[Points] Contract 1 At " + str(badgefactory_contract.get_nth_points_contract_address(user1.address, 1)))
    print("[Points] Contract 2 At " + str(badgefactory_contract.get_nth_points_contract_address(user1.address, 2)))
    print("[Points] Contract 47 (max-invalid) At " + str(badgefactory_contract.get_nth_points_contract_address(user1.address, 47)))

    # take a test ERC20 address for ERC721 deployments
    points_address = badgefactory_contract.get_nth_points_contract_address(user1.address, 0)

    points2_address = badgefactory_contract.get_nth_points_contract_address(user1.address, 0)
    # Library needs to be deployed seperately
    library_contract = EthernautFactory.deploy({"from": badgefactory_deployer})
    
    # Allow user2 to deploy 3 badge contracts 
    user2 = accounts.add(os.getenv("PRIVATE_KEY_HODLER1"))
    tx4_deploy_points = badgefactory_contract.deploy_points_erc20("MyToken", "MTK", {"from": user2})
    tx4_deploy_points.wait(1)

    # At this point, total deployers number is updated 
    print("Total Points (ERC20) Deployers: " + str(badgefactory_contract.get_total_points_deployers()))

    # But ERC721 remains at 0
    print("Total Badges (ERC721) Deployers: " + str(badgefactory_contract.get_total_badges_deployers()))

    tx1_deploy_badges = badgefactory_contract.deploy_badges_erc721_with_erc20_attached(
        points_address,
        library_contract,
        "EXPerienceNFT",
        "nEXP",
        {"from": user2}
    )
    tx1_deploy_badges.wait(1)

    tx2_deploy_badges = badgefactory_contract.deploy_badges_erc721_with_erc20_attached(
        points2_address,
        library_contract,
        "BadgeCentral",
        "eBadge",
        {"from": user2}
    )
    tx2_deploy_badges.wait(1)

    tx3_deploy_badges = badgefactory_contract.deploy_badges_erc721_with_erc20_attached(
        points_address,
        library_contract,
        "Randome",
        "RAND",
        {"from": user2}
    )
    tx3_deploy_badges.wait(1)

    # Total deployers should be 1 as user2 is now using badgefactory
    print("Total Points (ERC721) Deployers: " + str(badgefactory_contract.get_total_badges_deployers()))
    # Let's check the balance of user's deployment (badges - erc721)
    print("Total Badges contracts deployed by " + str(user2.address) + " : " + str(badgefactory_contract.get_total_badges_deployments_by_owner(user2.address)))

    # And print their addresses 
    print("[Badges] Contract 0 At " + str(badgefactory_contract.get_nth_badges_contract_address(user2.address, 0)))
    print("[Badges] Contract 1 At " + str(badgefactory_contract.get_nth_badges_contract_address(user2.address, 1)))
    print("[Badges] Contract 2 At " + str(badgefactory_contract.get_nth_badges_contract_address(user2.address, 2)))
    print("[Badges] Contract 6872 (max-invalid) At " + str(badgefactory_contract.get_nth_badges_contract_address(user2.address, 6872)))

    # Let's mint EXP Token to the user3 and allow user3 to mint NFT
    # Grab first token address and mint some EXPTokens to user3
    # EXPToken("TEStokn1", "TSK1", {"from": user1})
    TEStokn1_contract = interface.IEXPToken(points_address)

    # As the ownershipTransfer happened, there was no way to set the tokenadmin
    # So add self into tokenAdmins to perform other operations
    tx_add_self = TEStokn1_contract.setTokenAdmin(user1.address, True, {"from": user1})
    tx_add_self.wait(1)

    user3_pub = os.getenv("LOCAL_U3_PUB")
    # mint them 15 TSK1 tokens as points
    # user1 should have the ownership 
    tx_mint_EXPTokens = TEStokn1_contract.gainExperience(user3_pub, 15 * 1e18, {"from": user1})
    tx_mint_EXPTokens.wait(1)

    # Allow user to mint badges now 
    user3 = accounts.add(os.getenv("LOCAL_U3_PRIV"))
    # Mint from first contract  
    nft_contract_address = badgefactory_contract.get_nth_badges_contract_address(user2.address, 0)
    experience_contract = interface.IEXPerienceNFT(nft_contract_address)

    tx_mint_exp_nft = experience_contract.generateExperienceNFT({"from": user3})
    tx_mint_exp_nft.wait(1)

    # Print NFT tokenURI to verify library usage 
    print(experience_contract.tokenURI(0))