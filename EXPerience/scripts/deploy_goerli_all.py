# Test on goerli before moving on to optimism mainnet
# Testing on optimism goerlix

import os
from brownie import EXPToken, EXPerienceNFT, accounts, Contract
from dotenv import load_dotenv
load_dotenv()

def main():
    # Deployer to deploy EXPToken and EXPerience NFT Contract
    deployer_account = accounts.add(os.getenv("OP_GOERLI_DEPLOYER_PRIV"))
    admin2_account = accounts.add(os.getenv("OP_GOERLI_ADMIN2_PRIV"))
    # Public hodlers 
    hodler1 = os.getenv("OP_GOERLI_HODLER1_PUB")
    hodler2 = os.getenv("OP_GOERLI_HODLER2_PUB")
    hodler3 = os.getenv("OP_GOERLI_HODLER3_PUB")
    hodler4 = os.getenv("OP_GOERLI_HODLER4_PUB")
    hodler5 = os.getenv("OP_GOERLI_HODLER5_PUB")

    # # Deploy EXPToken ERC20 contract on Goerli
    expContract = EXPToken.deploy("EXPToken", "EXP", {"from": deployer_account})
    # Set another admin for ERC20 contract EXPToken
    expContract.setTokenAdmin(admin2_account.address, True, {"from": deployer_account})

    # Distribute
    try: 
        tx_gain = expContract.gainExperience(hodler1, 24 * 10 ** 18, {"from": deployer_account, "gas_limit": 15 * 10 ** 6, "allow_revert": True})
        print(tx_gain.info())
        input("Wait for 2 secs before next one")
        # hodler2 has no EXP balance and will try to mint EXP NFT
        # tx_gain2 = expContract.gainExperience(hodler2, 0.56 * 10 ** 18, {"from": deployer_account})
        # tx_gain2.wait(1)
        tx_gain3 = expContract.gainExperience(hodler3, 45 * 10 ** 18, {"from": deployer_account, "gas_limit": 15 * 10 ** 6, "allow_revert": True})
        print(tx_gain3.info())
        input("Wait for 2 secs before next one")
        tx_gain4 = expContract.gainExperience(hodler4, 99 * 10 ** 18, {"from": admin2_account, "gas_limit": 15 * 10 ** 6, "allow_revert": True})
        print(tx_gain4.info())
        input("Wait for 2 secs before next one")
        tx_gain5 = expContract.gainExperience(hodler5, 68 * 10 ** 18, {"from": admin2_account, "gas_limit": 15 * 10 ** 6, "allow_revert": True})
        print(tx_gain5.info())
        input("Wait for 2 secs before next one")
        # Keeping hodler5 out of this to check 0 EXP balance for NFT
    except Exception as error_details:
        print("\nDont expect these to fail. but they occasionally do. Dont stop there\n")
        print(error_details)

    
    exp_token_address = str(expContract)
    input('Verify EXPToken, we are moving to EXPerienceNFT deployment')
    exp_nft_contract = EXPerienceNFT.deploy("EXPerience NFT", "nEXP", exp_token_address, {"from": deployer_account})
    
    # Gas estimations from web3.eth.estamate_gas is failing, hence we need to mention gas limit 
    # Also allow tx to revert by setting allow_revert 
    admin1_mint_tx = exp_nft_contract.generateExperienceNFT({"from": deployer_account, "gas_limit": 15 * 10 ** 6, "allow_revert": True})
    admin1_mint_tx.wait(1)

    admin2_mint_tx = exp_nft_contract.generateExperienceNFT({"from": admin2_account, "gas_limit": 15 * 10 ** 6, "allow_revert": True})
    admin2_mint_tx.wait(1)

    # self Mint NFT to hodler account
    holder1 = accounts.add(os.getenv("OP_GOERLI_HODLER1_PRIV"))
    hodler1_tx = exp_nft_contract.generateExperienceNFT({"from": holder1, "gas_limit": 15 * 10 ** 6, "allow_revert": True})     # Shouldn't fail - User has EXP
    hodler1_tx.wait(1)

    # Do not have EXP token in wallet, mint operation should work, NFT will display 0 EXP token balance
    holder2 = accounts.add(os.getenv("OP_GOERLI_HODLER2_PRIV"))
    hodler2_tx = exp_nft_contract.generateExperienceNFT({"from": holder2, "gas_limit": 15 * 10 ** 6, "allow_revert": True}) 
    hodler2_tx.wait(1)

    # All of them have EXPTokens in their wallet, this minting operation should work 
    holder3 = accounts.add(os.getenv("OP_GOERLI_HODLER3_PRIV"))
    hodler3_tx = exp_nft_contract.generateExperienceNFT({"from": holder3, "gas_limit": 15 * 10 ** 6, "allow_revert": True})     # Shouldn't fail - User has EXP
    hodler3_tx.wait(1)

    holder4 = accounts.add(os.getenv("OP_GOERLI_HODLER4_PRIV"))
    hodler4_tx = exp_nft_contract.generateExperienceNFT({"from": holder4, "gas_limit": 15 * 10 ** 6, "allow_revert": True})     # Shouldn't fail - User has EXP
    hodler4_tx.wait(1)

    holder5 = accounts.add(os.getenv("OP_GOERLI_HODLER5_PRIV"))
    hodler5_tx = exp_nft_contract.generateExperienceNFT({"from": holder5, "gas_limit": 15 * 10 ** 6, "allow_revert": True})     # Shouldn't fail - User has EXP
    hodler5_tx.wait(1)

    # This should fail with the condition that only one per wallet mint is allowed 
    hodler5_tx_re = exp_nft_contract.generateExperienceNFT({"from": holder5, "gas_limit": 15 * 10 ** 6, "allow_revert": True})     # Should fail, user already has EXP NFT and trying to mint again
    hodler5_tx_re.wait(1)
