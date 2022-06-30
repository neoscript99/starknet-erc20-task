%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_caller_address

from contracts.token.ERC20.ERC20_base import (
    ERC20_name,
    ERC20_symbol,
    ERC20_totalSupply,
    ERC20_decimals,
    ERC20_balanceOf,
    ERC20_allowance,
    ERC20_mint,
    ERC20_initializer,
    ERC20_approve,
    ERC20_increaseAllowance,
    ERC20_decreaseAllowance,
    ERC20_transfer,
    ERC20_transferFrom,
)
const LevelToken = 100 * 1000000000000000000

@storage_var
func allowlist_level_storage(account : felt) -> (level : felt):
end

@external
func get_tokens{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    amount : Uint256
):
    let (caller) = get_caller_address()
    let (level) = allowlist_level_storage.read(caller)
    if level == 0:
        return (Uint256(0, 0))
    else:
        let amount : Uint256 = Uint256(LevelToken * level, 0)
        ERC20_mint(caller, amount)
        return (amount)
    end
end

@view
func allowlist_level{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    account : felt
) -> (level : felt):
    return allowlist_level_storage.read(account)
end

@external
func request_allowlist{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    level_granted : felt
):
    let (caller) = get_caller_address()
    allowlist_level_storage.write(caller, 1)
    return (1)
end

@external
func request_allowlist_level{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    level_requested : felt
) -> (level_granted : felt):
    let (caller) = get_caller_address()
    allowlist_level_storage.write(caller, level_requested)
    return (level_requested)
end
