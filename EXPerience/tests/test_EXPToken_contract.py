import brownie
import pytest 
from brownie import accounts, EXPToken

# Create a fixture, initial conditions requires for test. A fixture, contract, 
# will be passed along in every test function and executed every time a test is executed 
# Ref: https://eth-brownie.readthedocs.io/en/stable/tests-pytest-intro.html#:~:text=.balance()-,Fixtures,include%20the%20fixture%20name%20as%20an%20input%20argument%20for%20the%20test%3A,-1%0A%202%0A%203

# Setup:
# exptoken = EXPToken Contract 
# accounts[0] = Contract deployer - super admin
# accounts[1] = Admin - added by super admin
# accounts[2] = User 1 
# accounts[3] = User 2

# Creating EXPToken fixture 
@pytest.fixture(scope="module")
def exptoken():
    return accounts[0].deploy(EXPToken, "EXPerience Token", "EXP")
    #yield ET

# Test cases 
"""
================== Access Control =====================
"""
# Token creator can add other admins 
def test_token_creator_add_admin(exptoken):
    exptoken.setTokenAdmins(accounts[1], True, {"from": accounts[0]});

# Token admins can not add other admins
def test_token_admins_cannot_add_admin(exptoken):
    with brownie.reverts("EXPToken (AccessControl): Not authorized."):
        exptoken.setTokenAdmins(accounts[2], True, {"from": accounts[1]});

# 3. Ordinary users can not add admins 
def test_users_cannot_add_admins(exptoken):
    with brownie.reverts("EXPToken (AccessControl): Not authorized."):
        exptoken.setTokenAdmins(accounts[3], True, {"from": accounts[2]})

# User's can't gain or reduce experience 
def test_users_not_allowed_admin_actions(exptoken):
    with brownie.reverts("EXPToken (AccessControl): Not authorized."):
        exptoken.gainExperience(accounts[3], 1 * 10 ** 18, {"from": accounts[2]})
    with brownie.reverts("EXPToken (AccessControl): Not authorized."):
        exptoken.reduceExperience(accounts[3], 1 * 10 ** 18, {"from": accounts[2]})

"""
================== Token Allocation/Deallocation Authority/Token Balances =====================
"""
# 4. Token creator can gain experience 
# Gain 1 EXP, and assert account balance 
def test_token_creator_gain_experience(exptoken):
    exptoken.gainExperience(accounts[0], 1 * 10 ** 18, {"from": accounts[0]})
    assert exptoken.balanceOf(accounts[0]) == 1 * 10 ** 18

# 5. Cumulative experience cannot go above 100 
# Try adding more experience 
def test_upper_experience_limit_more_input_value(exptoken):
    with brownie.reverts("EXPToken (Balance): Will go above Max(100)."):
        exptoken.gainExperience(accounts[0], 150 * 10 ** 18, {"from": accounts[0]})

# 6. Cumulative experience cannot go above 100
# Try adding experience within a limit, yet see it overflow above 100 and not allowed 
def test_upper_experience_limit_addition_above_100(exptoken):
    exptoken.gainExperience(accounts[0], 99 * 10 ** 18, {"from": accounts[0]})
    assert exptoken.balanceOf(accounts[0]) == 100 * 10 ** 18
    # Now we are at maximum allowed EXP. Below request should fail '
    # even if _amount is within valid value range
    with brownie.reverts("EXPToken (Balance): Already at Max(100)."):
        exptoken.gainExperience(accounts[0], 1 * 10 ** 18, {"from": accounts[0]})

# 5. Token creator can lose experience 
# 5. Token creator can allow user to gain experience 
# 6. Token admin can allow user to gain experience 
# 7. Users can not gain experience on their own - Admin only function
# 8. Token creator can allow user to lose experience

"""
================== Supported Interfaces Checks =====================
"""
# x. Supported interface should return true for followings
#    - IERC20           - 0x01ffc9a7
#    - IERC20Metadata   - 0xa219a025
#    - IERC721          - 0x80ac58cd  - Not supported
def test_supports_ierc20_interface(exptoken):
    assert exptoken.supportsInterface('0x01ffc9a7', {"from": accounts[0]}) == True

def test_supports_ierc20_metadata_interface(exptoken):
    assert exptoken.supportsInterface('0xa219a025', {"from": accounts[0]}) == True

def test_does_not_support_ierc721_interface(exptoken):
    assert exptoken.supportsInterface('0x80ac58cd', {"from": accounts[0]}) == False

def test_checks_valid_interface_id(exptoken):
    assert exptoken.supportsInterface('0xffffffff', {"from": accounts[0]}) == False

"""
======================== Supposed To Fail ===========================
"""
# Allowance, Approve, decreaseAllowance, increaseAllowance, transfer, transferFrom are not allowed by anyone 
def test_banned_methods_always_revert(exptoken):
    # Allowance tests
    # Users should fail
    with brownie.reverts():
        exptoken.allowance(accounts[2], accounts[3], {"from": accounts[2]})
    # Even with admin it should fail
    with brownie.reverts():
        exptoken.allowance(accounts[0], accounts[1], {"from": accounts[0]})

    # Approve tests
    with brownie.reverts():
        exptoken.approve(accounts[2], 20 * 10 ** 18, {"from": accounts[2]})
    with brownie.reverts():
        exptoken.approve(accounts[0], 20 * 10 ** 18, {"from": accounts[0]})
    with brownie.reverts():
        exptoken.approve(accounts[1], 20 * 10 ** 18, {"from": accounts[1]})