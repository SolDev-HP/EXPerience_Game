# Testing this on L1 first before moving on to Optimism deployment changes 

# from branch dev/for_optimism_deployment we have seperated NFT URI generator library
# and EXPerienceNFT contract. This means we have to deploy two contracts initially
# but later updates are easier and have functions exposed from EXPerienceNFT contract
# to allow changes 
import os 
from brownie import EthernautFactory, EXPerienceNFT, Contract, accounts
from dotenv import load_dotenv
load_dotenv()

def main():
    # deployment instructions.
    pass