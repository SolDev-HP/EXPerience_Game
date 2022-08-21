# Test on goerli before moving on to optimism mainnet

import os
from brownie import EXPToken, EXPerienceNFT, accounts, Contract
from dotenv import load_dotenv
load_dotenv()

def main():
    # Deployer to deploy EXPToken and EXPerience NFT Contract
    deployer_account = accounts.add(os.getenv("PRIVATE_KEY_DEPLOYER_GOERLI_ADMIN1"))
    admin2_account = accounts.add(os.getenv("PRIVATE_KEY_DEPLOYER_GOERLI_ADMIN2"))
    # Public hodlers 
    hodler2 = os.getenv("PUBLIC_KEY_HODLER2_GOERLI")

    # Deploy EXPToken ERC20 contract on Goerli
    expContract = EXPToken.deploy("EXPToken", "EXP", {"from": deployer_account}, publish_source=True)
    # Set another admin for ERC20 contract EXPToken
    expContract.setTokenAdmin(os.getenv("PUBLIC_KEY_DEPLOYER_GOERLI_ADMIN2"), True, {"from": deployer_account})

    # Distribute
    try: 
        tx_gain = expContract.gainExperience(hodler2, 24 * 10 ** 18, {"from": deployer_account})
        tx_gain.wait(1)
        # Keeping hodler5 out of this to check 0 EXP balance for NFT
    except:
        print("\nDont expect these to fail. but they occasionally do. Dont stop there")

    
    exp_token_address = str(expContract)
    
    EXPerienceCon = EXPerienceNFT.deploy("EXPerience NFT", "nEXP", exp_token_address, {"from": deployer_account})
    
    # Mint NFT for self - NO EXP balance 
    # holder1 = accounts.add(os.getenv("PRIVATE_KEY_HODLER1_GOERLI"))
    # tx_hodler1 = EXPerienceCon.generateExperienceNFT({"from": holder1})     # Shouldn't fail - User has EXP
    # tx_hodler1.wait(1)

    # # Has EXPTokens in wallet
    # holder2 = accounts.add(os.getenv("PRIVATE_KEY_HODLER2_GOERLI"))
    # tx_hodler2 = EXPerienceCon.generateExperienceNFT({"from": holder2})     # Shouldn't fail - User has EXP
    # tx_hodler2.wait(1)
    
    admin_tx = EXPerienceCon.generateExperienceNFT({"from": deployer_account})
    admin_tx.wait(1)

    # admin2_tx = EXPerienceCon.generateExperienceNFT({"from": admin2_account})
    # admin2_tx.wait(1)
    # Check if one per address works 
    try: 
        holder_remint = expContract.gainExperience({"from": deployer_account})
        holder_remint.wait(1)
        # holder2_remint = expContract.gainExperience({"from": holder2})
        # holder2_remint.wait(1)
        # Keeping hodler5 out of this to check 0 EXP balance for NFT
    except:
        print("\nThis has to fail. It's expected")