// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {

    uint256 constant SEND_VALUE= 1 ether;

    function fundFundMe(address MostRecentlyDeployedFundMe) public {
        vm.startBroadcast();
        FundMe(payable(MostRecentlyDeployedFundMe)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe with ", SEND_VALUE);

    }
    function run() external {
        address MostRecentlyDeployedFundMe= DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        
        fundFundMe(MostRecentlyDeployedFundMe);

    }
}

contract WithdrawFundMe is Script{
    function withdrawFundMe(address MostRecentlyDeployedFundMe) public {
        vm.startBroadcast();
        FundMe(payable(MostRecentlyDeployedFundMe)).withdraw();
        vm.stopBroadcast();
        console.log("Withdrawed FundMe");

    }
    function run() external {
        address MostRecentlyDeployedFundMe= DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        
        withdrawFundMe(MostRecentlyDeployedFundMe);
        
    }
}