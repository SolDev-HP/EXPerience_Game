import brownie
import pytest 
from brownie import accounts, EXPToken

# Create a fixture, initial conditions requires for test. A fixture, contract, 
# will be passed along in every test function and executed every time a test is executed 
# Ref: https://eth-brownie.readthedocs.io/en/stable/tests-pytest-intro.html#:~:text=.balance()-,Fixtures,include%20the%20fixture%20name%20as%20an%20input%20argument%20for%20the%20test%3A,-1%0A%202%0A%203
# Creating EXPToken fixture 
@pytest.fixture(scope="module")
def exptoken():
    return accounts[0].deploy(EXPToken, "EXPerience Token", "EXP")
    #yield ET

# Test cases 
# 1. Token creator can add other admins 
def test_token_creator_add_admin(exptoken):
    exptoken.setTokenAdmins(accounts[1], True, {"from": accounts[0]});

# 2. Token admins can not add other admins
def test_token_admins_cannot_add_admin(exptoken):
    with brownie.reverts("EXPToken (AccessControl): Not authorized."):
        exptoken.setTokenAdmins(accounts[2], True, {"from": accounts[1]});

# 3. Ordinary users can not add admins 
# 4. Token creator can gain experience 
# 5. Token creator can lose experience 
# 5. Token creator can allow user to gain experience 
# 6. Token admin can allow user to gain experience 
# 7. Users can not gain experience on their own - Admin only function
# 8. Token creator can allow user to lose experience