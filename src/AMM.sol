// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import "@openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract AMM {
    address public tokenAddress;

    error AddressZero();
    error InvalidReserves();
    error InvalidInputAmount();

    constructor(address tokenAddress_) {
        // check is contract
        // check is ERC20
        if (tokenAddress_ == address(0)) revert AddressZero();

        tokenAddress = tokenAddress_;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          SETTERS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /**
     * @dev this function serves for adding liquidity to the pool either in ether or in tokenAddress
     * @param tokenAmount_ the amount of token to add to the liquidity pool (contract)
     */
    function addLiquidity(uint256 tokenAmount_) external payable {
        IERC20 token = IERC20(tokenAddress);
        token.transferFrom(msg.sender, address(this), tokenAmount_);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          GETTERS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function getReserve() public view returns (uint256 tokenBalance_) {
        uint256 tokenBalance = IERC20(tokenAddress).balanceOf(address(this));
        return tokenBalance;
    }

    function getPrice(uint256 inputReserve, uint256 outputReserve) public pure returns (uint256) {
        if (inputReserve == 0 && outputReserve == 0) revert InvalidReserves();
        return (inputReserve * 1000) / outputReserve;
    }

    function getTokenAmount(uint256 ethSold_) public view returns (uint256) {
        if (ethSold_ == 0) revert InvalidInputAmount();

        uint256 tokenReserve = getReserve();

        return getAmount(ethSold_, address(this).balance, tokenReserve);
    }

    function getEthAmount(uint256 tokenSold_) public view returns (uint256) {
        if (tokenSold_ == 0) revert InvalidInputAmount();

        return getAmount(tokenSold_, getReserve(), address(this).balance);
    }

    function getAmount(
        uint256 inputAmount,
        uint256 inputReserve,
        uint256 outputReserve
    )
        private
        pure
        returns (uint256)
    {
        if (inputReserve == 0 && outputReserve == 0) revert InvalidReserves();
        // Delta de X fois Y divisé par X plus delta de X
        return (inputAmount * outputReserve) / (inputReserve * inputAmount);
    }
}
