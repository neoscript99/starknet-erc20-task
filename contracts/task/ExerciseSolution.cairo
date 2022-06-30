%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_contract_address, get_caller_address
from starkware.cairo.common.uint256 import Uint256, uint256_add, uint256_sub
from contracts.token.ERC20.IDTKERC20 import IDTKERC20

from contracts.lib.UTILS import (
    UTILS_assert_uint256_difference,
    UTILS_assert_uint256_eq,
    UTILS_assert_uint256_le,
    UTILS_assert_uint256_strictly_positive,
    UTILS_assert_uint256_zero,
    UTILS_assert_uint256_lt,
)

const Dummy_Token = 0x029260ce936efafa6d0042bc59757a653e3f992b97960c1c4f8ccd63b7a90136

@storage_var
func tokens_in_custody_storage(account : felt) -> (amount : Uint256):
end

@storage_var
func deposit_tracker_token_storage() -> (deposit_tracker_token_address : felt):
end

@external
func deposit_tokens{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    amount : Uint256
) -> (total_amount : Uint256):
    let (this_address) = get_contract_address()
    let (caller) = get_caller_address()
    IDTKERC20.transferFrom(
        contract_address=Dummy_Token, sender=caller, recipient=this_address, amount=amount
    )
    let (total_amount) = deposit_internal(caller, amount)
    return (total_amount)
end

func deposit_internal{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    account : felt, amount : Uint256
) -> (total_amount : Uint256):
    let (before_bal) = tokens_in_custody_storage.read(account)
    let (after_bal, _) = uint256_add(before_bal, amount)
    tokens_in_custody_storage.write(account, after_bal)
    return (after_bal)
end

@view
func tokens_in_custody{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    account : felt
) -> (amount : Uint256):
    return tokens_in_custody_storage.read(account)
end

@external
func get_tokens_from_contract{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ) -> (amount : Uint256):
    let (this_address) = get_contract_address()
    let (caller) = get_caller_address()
    let (balance_before) = IDTKERC20.balanceOf(contract_address=Dummy_Token, account=this_address)
    IDTKERC20.faucet(contract_address=Dummy_Token)
    let (balance_after) = IDTKERC20.balanceOf(contract_address=Dummy_Token, account=this_address)
    let (faucet_amount) = uint256_sub(balance_after, balance_before)

    deposit_internal(caller, faucet_amount)
    return (faucet_amount)
end

@external
func withdraw_all_tokens{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    amount : Uint256
):
    alloc_locals
    let (caller) = get_caller_address()
    let (amount) = tokens_in_custody_storage.read(caller)

    IDTKERC20.transfer(contract_address=Dummy_Token, recipient=caller, amount=amount)
    withdraw_internal(caller, amount)
    return (amount)
end

func withdraw_internal{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    account : felt, amount : Uint256
) -> (balance : Uint256):
    alloc_locals
    let (before_bal) = tokens_in_custody_storage.read(account)
    UTILS_assert_uint256_le(amount, before_bal)
    let (after_bal) = uint256_sub(before_bal, amount)
    tokens_in_custody_storage.write(account, after_bal)
    return (after_bal)
end

@view
func deposit_tracker_token{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    deposit_tracker_token_address : felt
):
    return deposit_tracker_token_storage.read()
end

@external
func set_deposit_tracker_token{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt
) -> ():
    deposit_tracker_token_storage.write(address)
    return ()
end
