// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "../lib/forge-std/src/Script.sol";

import {DynamicNFT} from "../src/DynamicNFT.sol";
import {NFTFactory} from "../src/NFTFactory.sol";

contract DeployDynamicNFT is Script {
    function run()
        external
        returns (DynamicNFT dynamicNFT, NFTFactory nftFactory)
    {
        vm.startBroadcast();
        nftFactory = new NFTFactory();
        dynamicNFT = new DynamicNFT("DynamicNFT", "DFT", msg.sender);
        vm.stopBroadcast();
        return (dynamicNFT, nftFactory);
    }
}
