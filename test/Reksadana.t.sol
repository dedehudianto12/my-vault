// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {Reksadana} from "../src/Reksadana.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract ReksadanaTest is Test {
    Reksadana public reksadana;

    address weth = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address usdc = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address wbtc = 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f;

    function setUp() public {
        vm.createSelectFork(
            "https://arb-mainnet.g.alchemy.com/v2/5ESU53yV65mJYLaJfwTYa",
            357849892
        );
        reksadana = new Reksadana();
    }

    function test_TotalAsset() public {
        deal(wbtc, address(reksadana), 1e8);
        deal(weth, address(reksadana), 1e18);

        console.log("Total asset:", reksadana.totalReksadanaAsset());
    }

    function test_Deposit() public {
        address user = makeAddr("user");

        deal(usdc, user, 1000e6);

        vm.startPrank(user);
        IERC20(usdc).approve(address(reksadana), 1000e6);
        reksadana.deposit(1000e6);

        console.log("Shares:", IERC20(address(reksadana)).balanceOf(user));
        console.log("Total asset:", reksadana.totalReksadanaAsset());
        console.log("Total supply:", reksadana.totalSupply());

        vm.stopPrank();
    }

    function test_Withdraw() public {
        address user = makeAddr("user");

        deal(usdc, user, 1000e6);

        vm.startPrank(user);
        IERC20(usdc).approve(address(reksadana), 1000e6);
        reksadana.deposit(1000e6);

        uint256 shares = reksadana.balanceOf(user);
        reksadana.withdraw(shares);

        console.log("User USDC balance:", IERC20(usdc).balanceOf(user));
        console.log("User Shares balance:", reksadana.balanceOf(user));

        vm.stopPrank();
    }

    function test_Withdraw_InsufficientBalance() public {
        address user = makeAddr("user");

        deal(usdc, user, 1000e6);

        vm.startPrank(user);
        IERC20(usdc).approve(address(reksadana), 1000e6);
        reksadana.deposit(1000e6);

        vm.expectRevert(Reksadana.InsufficientBalance.selector);
        reksadana.withdraw(5000e6);

        vm.stopPrank();
    }

    function test_Withdraw_ZeroAmount() public {
        address user = makeAddr("user");

        deal(usdc, user, 1000e6);

        vm.startPrank(user);
        IERC20(usdc).approve(address(reksadana), 1000e6);
        reksadana.deposit(1000e6);

        vm.expectRevert(Reksadana.ZeroAmount.selector);
        reksadana.withdraw(0);

        vm.stopPrank();
    }
}
