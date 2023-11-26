//SPDX-License-Identifier:MIT

pragma solidity ^0.8.19;

import {Script} from "lib/forge-std/src/Script.sol";
import {FundMe} from "src/FundMe.sol";
import {MockV3Aggregator} from "test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed;
    }

    event HelperConfig__CreatedMockPriceFeed(address priceFeed);

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig()
        public
        pure
        returns (NetworkConfig memory sepoliaNetworkConfig)
    {
        sepoliaNetworkConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306 // ETH / USD
        });
    }

    function getOrCreateAnvilEthConfig()
        public
        returns (NetworkConfig memory anvilNetworkConfig)
    {
        //checks if there is already a config present, return that if it exists
        if (activeNetworkConfig.priceFeed != address(0)) {
            //0 indicates empty
            return activeNetworkConfig;
        }
        //1. DEPLOY MOCK contract AND RETURN ADDRESS.
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();
        anvilNetworkConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
    }
}
