// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import "./AMM.sol";

contract Factory {
    error invalidTokenAddress(address tokenAddress);
    error exchangeAlreadyExists(address exchangeAddress);

    mapping(address tokenAddress => address Exchange) public tokenToExchange;

    function createExchange(address tokenAddress_) external returns (address newExchange) {
        if (tokenAddress_ == address(0)) revert invalidTokenAddress(tokenAddress_);
        if (tokenToExchange[tokenAddress_] != address(0)) revert exchangeAlreadyExists(tokenAddress_);
        AMM exchange = new AMM(tokenAddress_);
        tokenToExchange[tokenAddress_] = address(exchange);
        return address(exchange);
    }
}
