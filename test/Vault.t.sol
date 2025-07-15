// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Vault} from "../src/Vault.sol";
import {MockUSDC} from "../src/MockUSDC.sol";

contract VaultTest is Test {
    MockUSDC public usdc;
    Vault public vault;

    address public alice = makeAddr("Alice");

    function setUp() public {
        usdc = new MockUSDC();
        vault = new Vault(address(usdc));
    }

    function test_Deposit() public {
        // alice deposit 1000 usdc
        vm.startPrank(alice);
        usdc.mint(alice, 1000);
        usdc.approve(address(vault), 1000);

        vm.expectEmit(true, true, true, true);
        emit Vault.Deposit(alice, 1000);

        vault.deposit(1000);
        assertEq(vault.balanceOf(alice), 1000);
        vm.stopPrank();
    }

    function test_Withdraw() public {
        // alice deposit 1000 usdc
        vm.startPrank(alice);
        usdc.mint(alice, 1000);
        usdc.approve(address(vault), 1000);
        // expect emit deposit event
        vm.expectEmit(true, true, true, true);
        emit Vault.Deposit(alice, 1000);
        // deposit 1000 usdc
        vault.deposit(1000);
        // check balance of alice
        assertEq(vault.balanceOf(alice), 1000);
        vm.stopPrank();

        // distributeYield 1000 usdc
        usdc.mint(address(this), 1000);
        usdc.approve(address(vault), 1000);
        // expect emit distributeYield event
        vm.expectEmit(true, true, true, true);
        emit Vault.DistributeYield(address(this), 1000);
        // distributeYield 1000 usdc
        vault.distributeYield(1000);
        // check balance of vault
        assertEq(usdc.balanceOf(address(vault)), 2000);

        // alice withdraw 500 usdc
        // expect emit withdraw event
        vm.expectEmit(true, true, true, true);
        emit Vault.Withdraw(alice, 1000);
        // withdraw 500 usdc
        vm.prank(alice);
        vault.withdraw(500);
        // check balance of alice
        assertEq(usdc.balanceOf(alice), 1000);
    }
}
