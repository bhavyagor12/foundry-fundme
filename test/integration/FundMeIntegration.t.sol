// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console2} from "lib/forge-std/src/Test.sol";
import {FundMe} from "src/FundMe.sol";
import {DeployFundMe} from "script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "script/Interactions.s.sol";

contract FundMeIntegrationTest is Test {
    FundMe fundMe;
    address immutable USER = makeAddr("Bhavya");

    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployer = new DeployFundMe();
        fundMe = deployer.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFund() external {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withDrawFundMe = new WithdrawFundMe();
        withDrawFundMe.withdrawFundMe(address(fundMe));

        assertEq(address(fundMe).balance, 0);
    }
}
