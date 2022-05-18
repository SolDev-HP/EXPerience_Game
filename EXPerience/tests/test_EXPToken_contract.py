import brownie
import os
import pytest 
from brownie import accounts, EXPToken
from dotenv import load_dotenv
load_dotenv()

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
### Increase experience
# Token creator can gain experience 
# Gain 1 EXP, and assert account balance 
def test_token_creator_gain_experience(exptoken):
    exptoken.gainExperience(accounts[0], 1 * 10 ** 18, {"from": accounts[0]})
    assert exptoken.balanceOf(accounts[0]) == 1 * 10 ** 18

# Only admin can allow gaining experience 
def test_admin_allowed_gainExperience(exptoken):
    exptoken.gainExperience(accounts[2], 1 * 10 ** 18, {"from": accounts[1]})
    assert exptoken.balanceOf(accounts[2]) == 1 * 10 ** 18

# Only admin can allow gaining experience 
def test_admin_allowed_gainExperience2(exptoken):
    exptoken.gainExperience(accounts[1], 1 * 10 ** 18, {"from": accounts[1]})
    assert exptoken.balanceOf(accounts[1]) == 1 * 10 ** 18

# Experience gainer needs to be valid address 
def test_experience_gainer_valid_address(exptoken):
    with brownie.reverts("ERC20: mint to the zero address"):
        exptoken.gainExperience(os.getenv("DEAD_ADD"), 1 * 10 ** 18, {"from": accounts[0]})

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


### Reduce Experience
# Token creator can reduce experience - Reduce previously added EXP and verify balance 
def test_token_creator_reduce_experience(exptoken):
    exptoken.reduceExperience(accounts[0], 99 * 10 ** 18, {"from": accounts[0]})
    assert exptoken.balanceOf(accounts[0]) == 1 * 10 ** 18

# Only admin can allow loosing experience 
def test_admin_allowed_reduceExperience(exptoken):
    exptoken.reduceExperience(accounts[1], 0.5 * 10 ** 18, {"from": accounts[1]})
    assert exptoken.balanceOf(accounts[1]) < 1 * 10 ** 18

# Experience looser needs to be valid address 
def test_experience_looser_valid_address(exptoken):
    with brownie.reverts("EXPToken (Balance): Insufficient balance"):
        exptoken.reduceExperience(os.getenv("DEAD_ADD"), 1 * 10 ** 18, {"from": accounts[0]})

# Can't reduce below zero 
def test_lower_experience_limit_while_reducing(exptoken):
    with brownie.reverts("EXPToken (Balance): Insufficient balance"):
        exptoken.reduceExperience(accounts[3], 1 * 10 ** 18, {"from": accounts[0]})     # account[3] is empty

# Trying to go below zero 
def test_lower_experience_calculation_below_zero(exptoken):
    # Now we try to reduce more experience that user has
    # even if _amount is within valid value range
    with brownie.reverts("ERC20: burn amount exceeds balance"):
        exptoken.reduceExperience(accounts[0], 5 * 10 ** 18, {"from": accounts[0]})

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
def test_allowance_always_revert(exptoken):
    # Allowance tests
    # Users should fail
    with brownie.reverts():
        exptoken.allowance(accounts[2], accounts[3], {"from": accounts[2]})
    # Even with admin it should fail
    with brownie.reverts():
        exptoken.allowance(accounts[0], accounts[1], {"from": accounts[0]})

def test_approve_always_revert(exptoken):
    # Approve tests
    with brownie.reverts():
        exptoken.approve(accounts[2], 20 * 10 ** 18, {"from": accounts[2]})
    with brownie.reverts():
        exptoken.approve(accounts[0], 20 * 10 ** 18, {"from": accounts[0]})     # Contract Deployer
    with brownie.reverts():
        exptoken.approve(accounts[1], 20 * 10 ** 18, {"from": accounts[1]})     # Token Admin

def test_decreaseAllowance_always_revert(exptoken):
    # decreaseAllowance tests
    with brownie.reverts():
        exptoken.decreaseAllowance(accounts[2], 20 * 10 ** 18, {"from": accounts[2]})
    with brownie.reverts():
        exptoken.decreaseAllowance(accounts[0], 20 * 10 ** 18, {"from": accounts[0]})
    with brownie.reverts():
        exptoken.decreaseAllowance(accounts[1], 20 * 10 ** 18, {"from": accounts[1]})

def test_increaseAllowance_always_revert(exptoken):
    # increaseAllowance tests
    with brownie.reverts():
        exptoken.increaseAllowance(accounts[2], 20 * 10 ** 18, {"from": accounts[2]})
    with brownie.reverts():
        exptoken.increaseAllowance(accounts[0], 20 * 10 ** 18, {"from": accounts[0]})
    with brownie.reverts():
        exptoken.increaseAllowance(accounts[1], 20 * 10 ** 18, {"from": accounts[1]})

def test_transfer_always_revert(exptoken):
    # transfer tests
    with brownie.reverts():
        exptoken.transfer(accounts[2], 20 * 10 ** 18, {"from": accounts[2]})
    with brownie.reverts():
        exptoken.transfer(accounts[0], 20 * 10 ** 18, {"from": accounts[0]})
    with brownie.reverts():
        exptoken.transfer(accounts[1], 20 * 10 ** 18, {"from": accounts[1]})

def test_transferFrom_always_revert(exptoken):
    # transferFrom tests
    with brownie.reverts():
        exptoken.transferFrom(accounts[2], accounts[3], 20 * 10 ** 18, {"from": accounts[2]})
    with brownie.reverts():
        exptoken.transferFrom(accounts[0], accounts[1], 20 * 10 ** 18, {"from": accounts[0]})
    with brownie.reverts():
        exptoken.transferFrom(accounts[1], accounts[2], 20 * 10 ** 18, {"from": accounts[1]})