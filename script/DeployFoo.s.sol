// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { Token } from "../src/Token.sol";
import { Script } from "forge-std/Script.sol";


/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract DeployFoo is Script {
    address internal deployer;
    Token internal token;

    function setUp() public virtual {
        string memory mnemonic = vm.envString("MNEMONIC");
        (deployer,) = deriveRememberKey(mnemonic, 0);
    }

    function run() public {
        vm.startBroadcast(deployer);
        token = new Token("Token", "TKN", 1000 ether);
        vm.stopBroadcast();
    }
}
