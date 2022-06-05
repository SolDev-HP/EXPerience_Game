import os 
from brownie import EXPerienceNFT, accounts
from dotenv import load_dotenv
load_dotenv()

# EXPToken is deployed at XX-Retest-To-Find-Out on dev 
def main():
    dev_admin1 = accounts.add(os.getenv("DEV_SADMIM_PRIV"))
    dev_admin2 = accounts.add(os.getenv("DEV_ADMIM2_PRIV"))
    dev_hodler1 = os.getenv("DEV_HODLER1_PUB")
    dev_hodler2 = os.getenv("DEV_HODLER2_PUB")

    # Deploy library first, we need to pass that address into EXPerience NFT 
    # expLib = EthernautFactory.deploy({"from": dev_admin1})
    # Deploy EXPerience NFT contract 
    expNFT = EXPerienceNFT.deploy("EXPerience-NFT", "EXPNFT", os.getenv("EXP_CONTRACT_DEV"), {"from": dev_admin1})

    print(expNFT)
    print(expNFT.address)
    # Admin1 adds new admin on EXPerience NFT 
    expNFT.setTokenAdmin(os.getenv("DEV_ADMIM2_PUB"), True, {"from": dev_admin1})

    # Mint NFT for User1 <- From Admin1
    expNFT.genExperience(dev_hodler1, {"from": dev_admin1})     # Shouldn't fail - User has EXP

    # Mint NFT for User2 <- From Admin2
    expNFT.genExperience(dev_hodler2, {"from": dev_admin2})     # Shouldn't fail - User has EXP

    print(expNFT.tokenURI(0))
    # Img url 
    # print(expNFT.getimgurl(1, {"from": dev_admin1} ))
    # print(expNFT.getAnimurl(1, {"from": dev_admin1} ))
    # print(expNFT.testURI(57, {"from": dev_admin1}))

    # Mint NFT for User3 <- From admin1
    # This requires further logic of whether to assign these NFTs to addresses 
    # holding EXP tokens already or not. Though at current point, it wouldn't 
    # make much sense to allow minting NFTs to addresses that do not hold EXP tokens 
    # try:
    #     expNFT.genExperience(os.getenv("PUBLIC_KEY_HODLER2"), {"from": dev_admin1})   # Should fail, user doesn't have EXP
    # except:
    #     print("Expected error. Continue...")

    # # Mint NFT again for User1 
    # try:
    #     expNFT.genExperience(dev_hodler1, {"from": dev_admin1})     # Should fail, already minted
    # except:
    #     print("Expected Error. Continue...")
    # # Mint NFT again for User1 
    # try:
    #     expNFT.genExperience(dev_hodler1, {"from": dev_admin2})     # Should fail, already minted
    # except:
    #     print("Expected error")
