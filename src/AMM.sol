// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import "@openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract AMM {
    address public tokenAddress;

    constructor(address tokenAddress_) {
        // check is contract
        // check is ERC20
        require(tokenAddress_ != address(0), "token can not be address zero");

        tokenAddress = tokenAddress_;
    }

    /**
     * @dev this function serves for adding liquidity to the pool either in ether or in tokenAddress
     * @param tokenAmount_ the amount of token to add to the liquidity pool (contract)
     */
    function addLiquidity(uint256 tokenAmount_) external payable {
        IERC20 token = IERC20(tokenAddress);
        token.transferFrom(msg.sender, address(this), tokenAmount_);
    }
}
