// SPDX-license-identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeplyFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("User");

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: 10e18}();
        _;
    }

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 10 ether);
    }

    function testMinimumDOllarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwner() public view {
        assertEq(fundMe.getowner(), msg.sender);
    }

    function testAgrregatorVersion() public view {
        uint256 version =fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundMeWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: 10e18}();
        uint256 amountfunded= fundMe.getAddressToAmtFounded(USER);
        assertEq(amountfunded, 10e18);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: 10e18}();
        address funder =fundMe.getFunders(0);
        assertEq(funder, USER);
    }


    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testSingleOwnerWithdraw() public funded {
        //Arrange
        uint256 startingOwnerBalance = fundMe.getowner().balance;
        uint256 startingContractBalance = address(fundMe).balance;

        //Act
        vm.prank(fundMe.getowner());
        fundMe.withdraw();

        //assert
        uint256 endingOwnerBalance = fundMe.getowner().balance;
        uint256 endingContractBalance = address(fundMe).balance;
        assertEq(endingOwnerBalance , startingOwnerBalance + startingContractBalance);
        assertEq(endingContractBalance, 0);
    }

    function testMultipleOwnerWithdraw() public {
        //arrange
        uint160 totalfunders=11;
        uint160 initialFunderIndex=1;

        for(uint160 i=initialFunderIndex; i<totalfunders; i++){
            hoax(address(i), 10 ether);
            fundMe.fund{value: 8 ether}();
        }

        //act 
        vm.prank(fundMe.getowner());
        fundMe.cheaperWithdraw();

        //assert
        assertEq(address(fundMe).balance, 0);
        for(uint160 i=initialFunderIndex; i<totalfunders; i++){
            assertEq(fundMe.getAddressToAmtFounded(address(i)), 0);
        }
        
    }
}
