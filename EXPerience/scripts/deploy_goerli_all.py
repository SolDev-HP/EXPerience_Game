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

    # # Deploy EXPToken ERC20 contract on Goerli
    expContract = EXPToken.deploy("EXPToken", "EXP", {"from": deployer_account})
    # Set another admin for ERC20 contract EXPToken
    # expContract.setTokenAdmin(os.getenv("PUBLIC_KEY_DEPLOYER_GOERLI_ADMIN2"), True, {"from": deployer_account})

    # Distribute
    try: 
        tx_gain = expContract.gainExperience(hodler2, 24 * 10 ** 18, {"from": deployer_account})
        tx_gain.wait(1)
        # Keeping hodler5 out of this to check 0 EXP balance for NFT
    except:
        print("\nDont expect these to fail. but they occasionally do. Dont stop there")

    
    exp_token_address = str(expContract)
    input('Verify EXPToken, we are moving to EXPerienceNFT deployment')
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

    admin2_account = accounts.add(os.getenv("PRIVATE_KEY_DEPLOYER_GOERLI_ADMIN2"))
    hodl1_tx = EXPerienceCon.generateExperienceNFT({"from": admin2_account})
    hodl1_tx.wait(1)

    hodl2acc = accounts.add(os.getenv("PRIVATE_KEY_HODLER1_GOERLI"))
    hodl2_tx = EXPerienceCon.generateExperienceNFT({"from": hodl2acc})
    hodl2_tx.wait(1)

    hodl3acc = accounts.add(os.getenv("PRIVATE_KEY_HODLER2_GOERLI"))
    hodl3_tx = EXPerienceCon.generateExperienceNFT({"from": hodl3acc})
    hodl3_tx.wait(1)

    # These will revert, unless we mention gas_limit and allow_revert, brownie wont even broadcast 
    # the transaction. So let's add those and expect them to fail as only one NFT per wallet is 
    # allowed 

    admin_tx_rev = EXPerienceCon.generateExperienceNFT({"from": deployer_account, "gas_limit": 150000, "allow_revert": True})
    admin_tx_rev.wait(1)

    hodl1_tx_rev = EXPerienceCon.generateExperienceNFT({"from": admin2_account, "gas_limit": 150000, "allow_revert": True})
    hodl1_tx_rev.wait(1)

    hodl2_tx_rev = EXPerienceCon.generateExperienceNFT({"from": hodl2acc, "gas_limit": 150000, "allow_revert": True})
    hodl2_tx_rev.wait(1)

    hodl3_tx_rev = EXPerienceCon.generateExperienceNFT({"from": hodl3acc, "gas_limit": 150000, "allow_revert": True})
    hodl3_tx_rev.wait(1)
    # admin2_tx = EXPerienceCon.generateExperienceNFT({"from": admin2_account})
    # admin2_tx.wait(1)
    # Check if one per address works 
    # try: 
    #     holder_remint = EXPerienceCon.generateExperienceNFT({"from": deployer_account})
    #     holder_remint.wait(1)
    #     # holder2_remint = expContract.gainExperience({"from": holder2})
    #     # holder2_remint.wait(1)
    #     # Keeping hodler5 out of this to check 0 EXP balance for NFT
    # except:
    #     print("\nThis has to fail. It's expected")