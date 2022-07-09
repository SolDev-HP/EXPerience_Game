# This is specifically for deploying ERC20 EXPToken on Rinkeby 
# with the support of QRNG randomness. 
import os
from time import sleep
from brownie import EXPToken, EXPerienceNFT, accounts, EthernautFactory
from dotenv import load_dotenv
load_dotenv()

# Leading this into optimism-kovan now
# We remove QRNG from EXP Token and deploy test EXP Token on optimism-kovan testnet 
def main():
    # =========================== Accounts Setup =====================================
    # As usual, take our admin account from rinkeby list 
    admin_account = accounts.add(os.getenv("PRIVATE_KEY_SADMIN"))
    second_admin = accounts.add(os.getenv("PRIVATE_KEY_ADMIN2"))

    # Public hodlers 
    hodler1 = os.getenv("PUBLIC_KEY_HODLER1")
    hodler2 = os.getenv("PUBLIC_KEY_HODLER2")
    hodler3 = os.getenv("PUBLIC_KEY_HODLER3")
    hodler4 = os.getenv("PUBLIC_KEY_HODLER4")
    hodler5 = os.getenv("PUBLIC_KEY_HODLER5")

        # Two more accounts which will be tested for random number generation and experience assignment 
    hodler6 = os.getenv("HOLDER6_RINKBY_PUB")
    hodler7 = os.getenv("HOLDER7_RINKBY_PUB")
    hodler8 = os.getenv("HOLDER8_RINKBY_PUB")

    # =========================== Airnode + QRNG Setup =====================================
    # Deploy EXPToken contract with airnodeRrp address 
    # _airnodeRrpAddress = os.getenv("FOR_QRNG_AIRNODE_RRP_RINKEBY")
    expContract = EXPToken.deploy("EXPToken", "EXP", {"from": admin_account})

    # # Now we need to set parameters for randomness first so 
    # # that we can make requests for randomness and check API3's QRNG
    # # Airnode service provider's address 
    # # ANU Quantum Random Numbers - API Provider
    # _airnode_address = os.getenv("FOR_QRNG_AIRNODE_ADDRESS")
    # # Airnode's extended public key - listed on the same provider api page
    # _airnode_xpub = os.getenv("FOR_QRNG_AIRNODE_XPUB")
    # # EXPToken contract's address
    # _expContract_address = str(expContract)

    # # Let's try and call npx to get out sponsor wallet. This shouldn't happen 
    # # every time. It's a one time call to setting the params in deployed contract.
    # # we need npm package airnode-admin to execute this. Make sure you have that 
    # # Current problem with this is --- It starts this subprocess from external python's libs 
    # # However, we want this to run in current context and venv so that we can point it correctly to 
    # # airnode-admin package for sponsor wallet generation.
    
    # # subProc = subprocess.Popen('npx @api3/airnode-admin derive-sponsor-wallet-address --airnode-xpub ' + _airnode_xpub + ' --airnode-address ' + _airnode_address + ' --sponsor-address ' + _expContract_address, stdout=subprocess.PIPE)
    # print('\nExecute this in other teaminal, and save result for the next input box.\nnpx @api3/airnode-admin derive-sponsor-wallet-address --airnode-xpub ' + _airnode_xpub + ' --airnode-address ' + _airnode_address + ' --sponsor-address ' + _expContract_address)
    # input("\n\nWaiting till you get the sponsor address... Press any key once received...")
    # # sponsorWalletResult = subProc.stdout.read()
    # sponsorWalletResult = input("Enter sponsor Wallet - ")

    # print(f'\nSponsor wallet received - {sponsorWalletResult}')
    # # The output result should be something like 
    # # Sponsor wallet address: 0xADDress 
    # # So we need to cutdown extra part and get the wallet address from the result 
    # # ----- Get wallet address 

    # _endpointIdUint256 = os.getenv("FOR_QRNG_AIRNODE_ENDPOINT_ID")
    # # To generate sponsorWallet, we need to request it using airnode-admin cli,
    # # It expects airnode_xpub + airnode_address + sponsor_address (EXPToken contract's address) 
    # # Since ethereum address is 40 hex characters, we take the 40 chars from end 
    # _sponsorWallet = '0x' + sponsorWalletResult[-40:] # Trimmed from sponsorWalletResults
    
    # # verify 
    # print(f'\nTrimmed address is now {_sponsorWallet}')
    # input("Verify sponsor address. We're now setting request params. Press any key to continue...")
   
    # # This should finally allow us to set our sponsor wallet within EXPToken contract 
    # expContract.setRequestParameters(_airnode_address, _endpointIdUint256, _sponsorWallet, {"from": admin_account})

    # # =========================== Basic ERC20 Interactions =====================================
    # # Once that is set, setup some accounts to very basic ERC20 workings 
    # # Add another admin
    sleep(2)
    expContract.setTokenAdmin(os.getenv("PUBLIC_KEY_ADMIN2"), True, {"from": admin_account})
    sleep(2)
    # Level 1 checking 
    try:
        # Mint some EXP to Hodler1 from Admin - Level 1 checking 
        expContract.gainExperience(hodler1, 1 * 10 ** 18, {"from": admin_account})
        # Give some space between sending these to reduce failed transactions 
        sleep(2)
        # Mint some EXP to Hodler2 from Admin2 - Level 1 checking 
        expContract.gainExperience(hodler2, 24 * 10 ** 18, {"from": second_admin})
        sleep(2)
        # Mint some EXP to Hodler3 from Admin - Level 2 checking 
        expContract.gainExperience(hodler3, 36 * 10 ** 18, {"from": admin_account})
        sleep(2)
        # Mint some EXP to Hodler4 from Admin2 - Level 3 checking
        expContract.gainExperience(hodler4, 67 * 10 ** 18, {"from": second_admin})
        sleep(2)
        # Mint some EXP to Hodler5 from Admin - Level 4 checking 
        expContract.gainExperience(hodler5, 93 * 10 ** 18, {"from": admin_account})
        sleep(2)

        # Mint some EXP to Hodler7 from Admin2 - Level 2 checking
        expContract.gainExperience(hodler7, 50 * 10 ** 18, {"from": second_admin})
        sleep(2)
        # Mint some EXP to Hodler8 from Admin2 - Level 3 checking
        expContract.gainExperience(hodler8, 75 * 10 ** 18, {"from": second_admin})
        sleep(2)
    except:
        print("\nDont expect these to fail. but they occasionally do. Dont stop there")

    # # =========================== Randomness Checks =====================================
    # # Add some tests here to verfiy

    # expContract.requestRandomEXPerienceForPlayer(hodler6, {"from": admin_account})
    # # Verify
    # input("\nVerify that the transaction went through. Wait for randomness fulfillment to occur. And then Press any key to continue...")

    # We need to deploy the Ethernaut factory library seperately 

    ethernaut_library = EthernautFactory.deploy({"from": admin_account})

    ethernaut_lib_address = str(ethernaut_library)
    exp_token_address = str(expContract)
    sleep(2)

    # =========================== EXPerience NFT Deployment =====================================
    EXPerienceCon = EXPerienceNFT.deploy("EXPerience NFT", "nEXP", exp_token_address, ethernaut_lib_address, {"from": admin_account})
    sleep(2)
    # Admin1 adds new admin on EXPerience NFT 
    EXPerienceCon.setTokenAdmin(os.getenv("PUBLIC_KEY_ADMIN2"), True, {"from": admin_account})
    sleep(2)
    # Mint NFT for User1 <- From Admin1
    EXPerienceCon.generateExperienceNFT(os.getenv("PUBLIC_KEY_HODLER1"), {"from": admin_account})     # Shouldn't fail - User has EXP
    sleep(2)

    # Mint NFT for User2 <- From Admin2
    EXPerienceCon.generateExperienceNFT(os.getenv("PUBLIC_KEY_HODLER2"), {"from": second_admin})     # Shouldn't fail - User has EXP
    sleep(2)

    # Mint NFT for User2 <- From Admin2
    EXPerienceCon.generateExperienceNFT(os.getenv("PUBLIC_KEY_HODLER3"), {"from": admin_account})     # Shouldn't fail - User has EXP
    sleep(2)

    # Mint NFT for User2 <- From Admin2
    EXPerienceCon.generateExperienceNFT(os.getenv("PUBLIC_KEY_HODLER4"), {"from": second_admin})     # Shouldn't fail - User has EXP
    sleep(2)

    # Mint NFT for User2 <- From Admin2
    EXPerienceCon.generateExperienceNFT(os.getenv("PUBLIC_KEY_HODLER5"), {"from": admin_account})     # Shouldn't fail - User has EXP
    sleep(2)

    ## Mint 5 more to demonstrate background changes are random 
    # Mint NFT for User1 <- From Admin1
    EXPerienceCon.generateExperienceNFT(os.getenv("HOLDER6_RINKBY_PUB"), {"from": admin_account})     # Shouldn't fail - User has EXP
    sleep(2)

    # Mint NFT for User2 <- From Admin2
    EXPerienceCon.generateExperienceNFT(os.getenv("HOLDER7_RINKBY_PUB"), {"from": second_admin})     # Shouldn't fail - User has EXP
    sleep(2)

    # Mint NFT for User2 <- From Admin2
    EXPerienceCon.generateExperienceNFT(os.getenv("HOLDER8_RINKBY_PUB"), {"from": admin_account})     # Shouldn't fail - User has EXP
    sleep(2)

    # Mint NFT for User2 <- From Admin2
    EXPerienceCon.generateExperienceNFT(os.getenv("HOLDER9_RINKBY_PUB"), {"from": second_admin})     # Shouldn't fail - User has EXP
    sleep(2)

    # Mint NFT for User2 <- From Admin2
    EXPerienceCon.generateExperienceNFT(os.getenv("HOLDER10_RINKBY_PUB"), {"from": admin_account})     # Shouldn't fail - User has EXP
    sleep(2)

   