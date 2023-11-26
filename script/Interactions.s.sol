//SPDX-License-Identifier:MIT

pragma solidity ^0.8.19;

import {Script, console2} from "lib/forge-std/src/Script.sol";
import {FundMe} from "src/FundMe.sol";

import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script {
    uint256 constant STARTING_FUND_VALUE = 0.1 ether;

    function fundFundMe(address fundMe) public {
        vm.startBroadcast();
        FundMe(payable(fundMe)).fund{value: STARTING_FUND_VALUE}();
        vm.stopBroadcast();
        console2.log("Funded FundMe with %s", STARTING_FUND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        fundFundMe(mostRecentlyDeployed);
    }
}

contract WithdrawFundMe is Script {
    uint256 constant STARTING_FUND_VALUE = 0.1 ether;

    function withdrawFundMe(address fundMe) public {
        vm.startBroadcast();
        FundMe(payable(fundMe)).withdraw();
        vm.stopBroadcast();
        console2.log("Funded FundMe with %s", STARTING_FUND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        withdrawFundMe(mostRecentlyDeployed);
    }
}
