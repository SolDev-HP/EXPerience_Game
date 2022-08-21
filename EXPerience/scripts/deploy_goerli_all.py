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
    expContract = EXPToken.deploy("EXPToken", "EXP", {"from": deployer_account})
    # Set another admin for ERC20 contract EXPToken
    expContract.setTokenAdmin(os.getenv("PUBLIC_KEY_DEPLOYER_GOERLI_ADMIN2"), True, {"from": deployer_account})

    # Distribute
    try: 
        expContract.gainExperience(hodler2, 24 * 10 ** 18, {"from": admin2_account})
        # Keeping hodler5 out of this to check 0 EXP balance for NFT
    except:
        print("\nDont expect these to fail. but they occasionally do. Dont stop there")

    
    exp_token_address = str(expContract)
    
    EXPerienceCon = EXPerienceNFT.deploy("EXPerience NFT", "nEXP", exp_token_address, {"from": deployer_account})
    
    # Mint NFT for self - NO EXP balance 
    holder1 = accounts.add(os.getenv("PRIVATE_KEY_HODLER1_GOERLI"))
    EXPerienceCon.generateExperienceNFT(os.getenv("PUBLIC_KEY_HODLER1_GOERLI"), {"from": holder1})     # Shouldn't fail - User has EXP

    # Has EXPTokens in wallet
    holder2 = accounts.add(os.getenv("PRIVATE_KEY_HODLER2_GOERLI"))
    EXPerienceCon.generateExperienceNFT(os.getenv("PUBLIC_KEY_HODLER2_GOERLI"), {"from": holder2})     # Shouldn't fail - User has EXP

    
    EXPerienceCon.generateExperienceNFT(os.getenv("PUBLIC_KEY_DEPLOYER_GOERLI_ADMIN1"), {"from": deployer_account})

    EXPerienceCon.generateExperienceNFT(os.getenv("PUBLIC_KEY_DEPLOYER_GOERLI_ADMIN2"), {"from": admin2_account})
    