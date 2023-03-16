// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { console2 } from "forge-std/console2.sol";
import { StdCheats } from "forge-std/StdCheats.sol";

import "ds-test/test.sol";

import { Token } from "../src/Token.sol";
import { AMM } from "../src/AMM.sol";

interface CheatCodes {
    // Gets address for a given private key, (privateKey) => (address)
    function addr(uint256) external returns (address);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

/// @dev See the "Writing Tests" section in the Foundry Book if this is your first time with Forge.
/// https://book.getfoundry.sh/forge/writing-tests
contract AMMTest is PRBTest, StdCheats {
    /// @dev An optional function invoked before each test case is run
    Token internal token;
    AMM internal amm;

    address public user1;
    address public user2;

    CheatCodes internal cheats = CheatCodes(HEVM_ADDRESS);

    function setUp() public {
        // solhint-disable-previous-line no-empty-blocks
        user1 = cheats.addr(1);
        user2 = cheats.addr(2);
        vm.deal(user1, 10_000 ether);
        vm.prank(user1);
        token = new Token("Token", "TKN", 3000 ether);
        amm = new AMM(address(token));
        vm.prank(user1);
        token.approve(address(amm), type(uint256).max);
    }

    function testInitBalance() external {
        assertEq(token.balanceOf(user1), 3000 ether, "user1 did not get 3000 ether");
    }

    /// @dev Simple test. Run Forge with `-vvvv` to see console logs.
    function test_AddLiquidity() external {
        vm.prank(user1);
        amm.addLiquidity(10 ether);
        assertEq(amm.getReserve(), 10 ether);
        assertEq(token.balanceOf(user1), 2990 ether);
    }

    function test_LPTokens() external {
        vm.prank(user1);
        amm.addLiquidity{ value: 1 ether }(2 ether);
        assertEq(amm.totalSupply(), 1 ether);
        assertEq(amm.balanceOf(user1), 1 ether);
    }

    function test_removeLiquidity() external {
        vm.startPrank(user1);
        amm.addLiquidity{ value: 1 ether }(2 ether);
        amm.removeLiquidity(1 ether);
        vm.stopPrank();
        assertEq(amm.totalSupply(), 0);
        assertEq(amm.balanceOf(user1), 0);
        assertEq(token.balanceOf(user1), 2999 ether);
        assertEq(user1.balance, 10_000 ether);
    }

    function test_getPrice() external {
        vm.prank(user1);
        amm.addLiquidity{ value: 1000 ether }(2000 ether);

        uint256 tokenBalance = amm.getReserve();
        uint256 etherBalance = address(amm).balance;
        // Eth per tokens
        assertEq(amm.getPrice(etherBalance, tokenBalance), 500);
        // Tokens per Eth
        assertEq(amm.getPrice(tokenBalance, etherBalance), 2000);
    }

    function test_getAmountOut() external {
        vm.prank(user1);
        amm.addLiquidity{ value: 1 ether }(2 ether);
        uint256 ethOut = amm.getEthAmount(2 ether);
        uint256 tokenOut = amm.getTokenAmount(1 ether);
        assertEq(ethOut, 497_487_437_185_929_648);
        assertEq(tokenOut, 994_974_874_371_859_296);
    }

    function test_getTokenAmountSlippage() external {
        vm.prank(user1);
        amm.addLiquidity{ value: 1 ether }(2 ether);
        uint256 tokenOut = amm.getTokenAmount(1 ether);
        assertEq(tokenOut, 994_974_874_371_859_296);
        tokenOut = amm.getTokenAmount(100 ether);
        assertEq(tokenOut, 1_980_000_000_000_000_000);
        tokenOut = amm.getTokenAmount(1000 ether);
        assertEq(tokenOut, 1_997_981_836_528_758_829);
    }

    function test_getEthAmountSlippage() external {
        vm.prank(user1);
        amm.addLiquidity{ value: 1 ether }(2 ether);
        uint256 ethOut = amm.getEthAmount(2 ether);
        assertEq(ethOut, 497_487_437_185_929_648);
        ethOut = amm.getEthAmount(100 ether);
        assertEq(ethOut, 980_198_019_801_980_198);
        ethOut = amm.getEthAmount(2000 ether);
        assertEq(ethOut, 998_990_918_264_379_414);
    }

    /// @dev Test that fuzzes an unsigned integer.
    function testFuzz_Example(uint256 x) external {
        vm.assume(x != 0);
        assertGt(x, 0);
    }

    /*
    /// @dev Test that runs against a fork of Ethereum Mainnet. You need to set `API_KEY_ALCHEMY` in your environment
    /// for this test to run - you can get an API key for free at https://alchemy.com.
    function testFork_Example() external {
        string memory alchemyApiKey = vm.envOr("API_KEY_ALCHEMY", string(""));
        // Silently pass this test if the user didn't define the API key.
        if (bytes(alchemyApiKey).length == 0) {
            return;
        }

        // Run the test normally, otherwise.
        vm.createSelectFork({ urlOrAlias: "ethereum", blockNumber: 16_428_000 });
        address usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        address holder = 0x7713974908Be4BEd47172370115e8b1219F4A5f0;
        uint256 actualBalance = IERC20(usdc).balanceOf(holder);
        uint256 expectedBalance = 196_307_713.810457e6;
        assertEq(actualBalance, expectedBalance);
    }
    */
}
