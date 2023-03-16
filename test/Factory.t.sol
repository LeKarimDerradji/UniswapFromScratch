// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { console2 } from "forge-std/console2.sol";
import { StdCheats } from "forge-std/StdCheats.sol";

import "ds-test/test.sol";

import { Token } from "../src/Token.sol";
import { AMM } from "../src/AMM.sol";
import { Factory } from "../src/Factory.sol";

interface CheatCodes {
    // Gets address for a given private key, (privateKey) => (address)
    function addr(uint256) external returns (address);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

/// @dev See the "Writing Tests" section in the Foundry Book if this is your first time with Forge.
/// https://book.getfoundry.sh/forge/writing-tests
contract FactoryTest is PRBTest, StdCheats {
    /// @dev An optional function invoked before each test case is run
    Token internal token;
    AMM internal amm;

    address public user1;
    address public user2;

    CheatCodes internal cheats = CheatCodes(HEVM_ADDRESS);

    function setUp() public {
        // solhint-disable-previous-line no-empty-blocks
        user1 = cheats.addr(1);
        token = new Token("Token", "TKN", 3000 ether);
        amm = new AMM(address(token));
        
    }
}
