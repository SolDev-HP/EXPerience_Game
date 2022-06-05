import os 
from brownie import accounts, BadgeFactory
from dotenv import load_dotenv
load_dotenv()

def main():
    account = accounts.add(os.getenv(""))
    