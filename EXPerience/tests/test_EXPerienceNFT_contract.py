import brownie 
import os
from brownie import accounts, EXPerienceNFT, EXPToken
import pytest 
from dotenv import load_dotenv
load_dotenv()

# Setup:
# exptoken = EXPToken Contract 
# exptoken has to be deployed first in order to supply that address to EXPerienceNFT
# expnft = EXPerienceNFT Contract 
# accounts[0] = Contract deployer - super admin
# accounts[1] = Admin - added by super admin
# accounts[2] = User 1 
# accounts[3] = User 2

# Create EXPToken fixture we will use to test NFT contract
@pytest.fixture(scope="module")
def exptoken():
    return accounts[0].deploy(EXPToken, "EXPerience Token", "EXP", os.getenv("FOR_QRNG_DEVELOPMENT"));

# Creating EXPerience NFT fixture 
@pytest.fixture(scope="module")
def expnft(exptoken):
    return accounts[0].deploy(EXPerienceNFT, "EXPerience NFT", "nEXP", exptoken)

# 
# Perform necessry destribution to the users
# So remaining tests regarding NFT can have an initial state to continue

def test_make_sure_exptoken_setup_correctly(exptoken):
    # Add admin 
    exptoken.setTokenAdmin(accounts[1], True, {"from": accounts[0]})
    # Generate exp for self - 1 EXP
    exptoken.gainExperience(accounts[0], 1 * 10 ** 18, {"from": accounts[0]})
    # Admin2 Generate exp for self - 1 EXP
    exptoken.gainExperience(accounts[1], 1 * 10 ** 18, {"from": accounts[1]})
    # Admin1 Generate exp for user1 - 1 EXP
    exptoken.gainExperience(accounts[2], 1 * 10 ** 18, {"from": accounts[0]})
    # Admin2 Generate exp for user2 - 1 EXP
    exptoken.gainExperience(accounts[3], 1 * 10 ** 18, {"from": accounts[1]})
    
def test_only_admin_can_generate_nft(expnft):
    with brownie.reverts("typed error: 0x35f1f74c"):    # Reverts our custom error, copied from bronie output to reference that error
        expnft.generateExperienceNFT(accounts[1], {"from": accounts[1]})
    # Only deployer can generate EXPerience 
    expnft.generateExperienceNFT(accounts[0], {"from": accounts[0]})
    # verify totalsupply, it should be 1 so far 
    assert expnft.totalSupply({"from": accounts[0]}) == 1
    # If account 1 is added by admin, then they can also generate EXPerience 
    expnft.setTokenAdmin(accounts[1], True, {"from": accounts[0]})
    # Now try generating, it shouldn't fail
    expnft.generateExperienceNFT(accounts[1], {"from": accounts[1]})
    # verify totalSupply again ==2?
    assert expnft.totalSupply({"from": accounts[0]}) == 2

# We now allow players to have NFT even if their EXP balance is zero.
# Should this reset back to original, uncomment below test
# def test_receiver_should_have_exp_balance(expnft):
#     with brownie.reverts("EXPerience: Insufficient EXP balance"):
#         expnft.generateExperienceNFT(accounts[4], {"from": accounts[0]})

# Currently no functionality to support changing EXPToken contract address
# Once we refactor factories, we should uncomment below tests to see 
# exp contract address changes
# setExpContractAddress can only be called by the owner 
# def test_set_exp_contract_only_owner(expnft):
#     with brownie.reverts("EXPToken (AccessControl): Not authorized."):
#         expnft.setExpContractAddress(accounts[2], {"from": accounts[1]})
#         # Parameter is supposed to be a contract, but its going to fail any way so any address works 

# 0xDeaD check 
# def test_set_exp_contract_valid_address_check(expnft):
#     with brownie.reverts("Invalid EXP Token Contract address"):
#         expnft.setExpContractAddress(os.getenv("DEAD_ADD"), {"from": accounts[0]})

# total supply should match with everyone's balance 
def test_total_supply(expnft):
    assert expnft.totalSupply() == (expnft.balanceOf(accounts[0]) + expnft.balanceOf(accounts[1]) + expnft.balanceOf(accounts[2]) + expnft.balanceOf(accounts[3]))