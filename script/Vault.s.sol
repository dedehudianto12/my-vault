// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {MockUSDC} from "../src/MockUSDC.sol";
import {Vault} from "../src/Vault.sol";

contract VaultScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        MockUSDC usdc = new MockUSDC();
        Vault vault = new Vault(address(usdc));

        vm.stopBroadcast();
    }   
}