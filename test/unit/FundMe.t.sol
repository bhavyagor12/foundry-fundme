// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console2} from "lib/forge-std/src/Test.sol";
import {FundMe} from "src/FundMe.sol";
import {DeployFundMe} from "script/DeployFundMe.s.sol";

contract FundMeTest is Test {
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

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        //unit test
        assertEq(fundMe.getOwnerOfContract(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructures() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        address funderAddress = fundMe.getFunder(0);
        assertEq(amountFunded, SEND_VALUE);
        assertEq(funderAddress, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdrawFunds() public funded {
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() public funded {
        //Arrange

        uint256 startingOwnerBalance = fundMe.getOwnerOfContract().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.prank(fundMe.getOwnerOfContract());
        fundMe.withdraw();
        //Assert
        uint256 endingOwnerBalance = fundMe.getOwnerOfContract().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawWithMultipleFunders() public funded {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFundersIndex = 1;

        for (uint160 i = startingFundersIndex; i < numberOfFunders; i++) {
            //hoax does prank + add some value
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwnerOfContract().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.prank(fundMe.getOwnerOfContract());
        fundMe.withdraw();

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwnerOfContract().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }
}
