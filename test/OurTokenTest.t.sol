// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";
import {console} from "forge-std/Console.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address jake = makeAddr("jake");
    address andy = makeAddr("andy");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(address(msg.sender));
        console.log("address deployer: ", address(deployer));
        console.log("address jake: ", address(jake));
        ourToken.transfer(jake, STARTING_BALANCE);
    }

    function testJakeBalance() public view {
        assertEq(ourToken.balanceOf(jake), STARTING_BALANCE);
    }

    function testAllowancesWorks() public {
        uint256 initialAllowance = 1000;
        vm.prank(jake);
        ourToken.approve(andy, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(andy);
        ourToken.transferFrom(jake, andy, transferAmount);

        assertEq(ourToken.balanceOf(andy), transferAmount);
        assertEq(ourToken.balanceOf(jake), STARTING_BALANCE - transferAmount);
    }

    function testTransferInsufficientBalance() public {
        uint256 transferAmount = ourToken.balanceOf(jake) + 1;

        vm.prank(jake);
        vm.expectRevert();
        ourToken.transfer(andy, transferAmount);
    }

    function testApproveSetsAllowance() public {
        uint256 amount = 1000;

        ourToken.approve(andy, amount);

        assertEq(ourToken.allowance(address(this), andy), amount);
    }

    function testDeployerHasInitialSupply() public view {
        assertEq(ourToken.balanceOf(address(msg.sender)), deployer.INITIAL_SUPPLY() - STARTING_BALANCE);
    }
}
