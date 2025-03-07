// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "../lib/forge-std/src/Script.sol";

import {DynamicNFT} from "../src/DynamicNFT.sol";

contract DeployDynamicNFT is Script {
    function run() external returns (DynamicNFT) {
        vm.startBroadcast();
        DynamicNFT dynamicNFT = new DynamicNFT("DynamicNFT", "DFT", msg.sender);
        vm.stopBroadcast();
        return dynamicNFT;
    }
}
