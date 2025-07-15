// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

interface IVault {
    function deposit(uint256 amount) external;
    function withdraw(uint256 shares) external;
    function distributeYield(uint256 amount) external;
}

contract Vault is ERC20 {
    address public usdc;

    error InsufficientBalance();

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event DistributeYield(address indexed user, uint256 amount);

    constructor(address _usdc) ERC20("Vault", "VAULT") {
        usdc = _usdc;
    }

    function deposit(uint256 amount) public {
        if (IERC20(usdc).balanceOf(msg.sender) < amount) {
            revert InsufficientBalance();
        }

        // shares = amount / totalAsset * totalShares
        uint256 totalAsset = IERC20(usdc).balanceOf(address(this));
        uint256 totalShares = totalSupply();

        uint256 shares = 0;
        if (totalShares == 0) {
            shares = amount;
        } else {
            shares = (amount * totalShares) / totalAsset;
        }

        // mint shares to msg.sender
        _mint(msg.sender, shares);

        // transfer usdc from msg.sender to vault
        // USDC dari msg.sender diambil dikirim ke dalam vault
        IERC20(usdc).transferFrom(msg.sender, address(this), amount);

        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 shares) public {
        if (balanceOf(msg.sender) < shares) {
            revert InsufficientBalance();
        }

        // amount = shares * totalAsset / totalShares
        uint256 totalAsset = IERC20(usdc).balanceOf(address(this));
        uint256 totalShares = totalSupply();

        uint256 amount = (shares * totalAsset) / totalShares;

        _burn(msg.sender, shares);

        if (IERC20(usdc).balanceOf(address(this)) < amount) {
            revert InsufficientBalance();
        }

        // transfer usdc from vault to msg.sender
        IERC20(usdc).transfer(msg.sender, amount);

        emit Withdraw(msg.sender, amount);
    }

    function distributeYield(uint256 amount) public {
        if (IERC20(usdc).balanceOf(msg.sender) < amount) {
            revert InsufficientBalance();
        }

        IERC20(usdc).transferFrom(msg.sender, address(this), amount);

        emit DistributeYield(msg.sender, amount);
    }
}
