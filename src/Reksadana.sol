// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {ISwapRouter} from "../lib/v3-periphery/contracts/interfaces/ISwapRouter.sol";

interface AggregatorV3Interface {
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
    function decimals() external view returns (uint8);
    function description() external view returns (string memory);
    function version() external view returns (uint256);
    function getRoundData(
        uint80 _roundId
    )
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

contract Reksadana is ERC20 {
    error InsufficientBalance();

    address uniswapRouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564;

    address weth = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address usdc = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address wbtc = 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f;

    address baseFeed = 0x50834F3163758fcC1Df9973b6e91f0F0F0434aD3;
    address wbtcFeed = 0x6ce185860a4963106506C203335A2910413708e9;
    address wethFeed = 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612;

    constructor() ERC20("Reksadana", "RDN") {}

    // Events
    event Deposit(address indexed user, uint256 amount, uint256 shares);
    event Withdraw(address indexed user, uint256 shares, uint256 amount);

    // Total asset adalah jumlah WBTC + WETH dalam bentuk USDC
    function totalAsset() public view returns (uint256) {
        // Ambil harga USDC ke USD
        (, int256 usdcPrice, , , ) = AggregatorV3Interface(baseFeed)
            .latestRoundData();
        // Ambil harga WBTC ke USD
        (, int256 wbtcPrice, , , ) = AggregatorV3Interface(wbtcFeed)
            .latestRoundData();
        uint256 wbtcPriceInUsd = (uint256(wbtcPrice) * 1e6) /
            uint256(usdcPrice);
        // Ambil harga WETH ke USD
        (, int256 wethPrice, , , ) = AggregatorV3Interface(wethFeed)
            .latestRoundData();
        uint256 wethPriceInUsd = (uint256(wethPrice) * 1e6) /
            uint256(usdcPrice);

        // Hitung total asset
        uint256 totalWethAsset = (IERC20(weth).balanceOf(address(this)) *
            wethPriceInUsd) / 1e18;
        uint256 totalWbtcAsset = (IERC20(wbtc).balanceOf(address(this)) *
            wbtcPriceInUsd) / 1e8;

        return totalWethAsset + totalWbtcAsset;
    }

    function deposit(uint256 amount) external {
        if (IERC20(usdc).balanceOf(msg.sender) < amount) {
            revert InsufficientBalance();
        }

        // ambil usdc dari user
        IERC20(usdc).transferFrom(msg.sender, address(this), amount);
        // total asset
        uint256 totalAsset = totalAsset();
        // total shares
        uint256 totalShares = totalSupply();
        // hitung shares yang didaptkan
        uint256 shares;
        if (totalShares == 0) {
            shares = amount;
        } else {
            shares = (amount * totalShares) / totalAsset;
        }
        // shares dikirim ke user
        _mint(msg.sender, shares);

        // ambil usdc dari user
        // transfer usdc dari user ke uniswap untuk convert ke weth
        // transfer usdc dari user ke uniswap untuk convert ke wbtc
    }
}
