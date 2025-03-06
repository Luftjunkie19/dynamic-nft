// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "../lib/forge-std/src/Script.sol";

import {DynamicNFT} from "../src/DynamicNFT.sol";

contract DeployDynamicNFT is Script {
    function run(
        string memory _name,
        string memory _symbol,
        address owner,
        string memory _attributeName
    ) external returns (DynamicNFT) {
        vm.startBroadcast();
        DynamicNFT dynamicNFT = new DynamicNFT(
            _name,
            _symbol,
            owner,
            _attributeName
        );
        vm.stopBroadcast();
        return dynamicNFT;
    }
}
