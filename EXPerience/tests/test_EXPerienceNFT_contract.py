import brownie 
import os
from brownie import accounts, EXPerienceNFT
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

# Creating EXPToken fixture 
@pytest.fixture(scope="module")
def expnft():
    return accounts[0].deploy(EXPerienceNFT, "EXPerience NFT", "nEXP", os.getenv("EXP_CONTRACT_DEV"))

