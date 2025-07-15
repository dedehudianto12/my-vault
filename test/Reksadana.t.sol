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

    function test_SetOwner() public {
        // Owner deploy and become owner
        address owner = makeAddr("owner");
        vm.startPrank(owner);
        reksadana = new Reksadana();
        assertEq(reksadana.owner(), owner);
        vm.stopPrank();

        // User try to set owner
        address user = makeAddr("user");
        vm.startPrank(user);
        vm.expectRevert("Not the owner");
        reksadana.setOwner(user);
        vm.stopPrank();

        // Owner change the ownership to user
        vm.startPrank(owner);
        vm.expectEmit(true, true, true, true);
        emit Reksadana.SetNewOwner(owner, user);
        reksadana.setOwner(user);
        assertEq(reksadana.owner(), user);
        vm.stopPrank();
    }

    function test_SetFeeRate() public {
        // Owner deploy reksadana and set the fee rate to 10%
        address owner = makeAddr("owner");
        vm.startPrank(owner);
        reksadana = new Reksadana();
        vm.expectEmit(true, true, true, true);
        emit Reksadana.SetFeeRate(1000);
        reksadana.setFeeRate(1000);
        assertEq(reksadana.feeRate(), 1000);
        vm.stopPrank();

        // Should revert if fee rate is greater than 10%
        vm.startPrank(owner);
        vm.expectRevert("Fee rate must be less than 10%");
        reksadana.setFeeRate(1001);
        vm.stopPrank();

        // Should rever if user try to set fee rate
        address user = makeAddr("user");
        vm.startPrank(user);
        vm.expectRevert("Not the owner");
        reksadana.setFeeRate(1000);
        vm.stopPrank();
    }

    function test_WithdrawWithFee() public {
        // Owner deploy and set the fee rate
        address owner = makeAddr("owner");
        vm.startPrank(owner);
        reksadana = new Reksadana();
        reksadana.setFeeRate(100);
        vm.stopPrank();

        // User deposit 1000 USDC
        address user = makeAddr("user");
        deal(usdc, user, 1000e6);

        vm.startPrank(user);
        IERC20(usdc).approve(address(reksadana), 1000e6);
        vm.expectEmit(true, true, true, true);
        emit Reksadana.Deposit(user, 1000e6, 1000e6);
        reksadana.deposit(1000e6);
        vm.stopPrank();

        // User withdraw 500 Shares
        vm.startPrank(user);
        reksadana.withdraw(500e6);
        console.log("User USDC balance:", IERC20(usdc).balanceOf(user));
        console.log("User Shares balance:", reksadana.balanceOf(user));
        console.log("Collected fee:", reksadana.collectedFee());
        vm.stopPrank();
    }
}
