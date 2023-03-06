// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

contract AMM {
    address public tokenAddress;

    constructor(address tokenAddress_) {
        // check is contract
        // check is ERC20
        require(tokenAddress_ != address(0), "token can not be address zero");

        tokenAddress = tokenAddress_;
    }
}
