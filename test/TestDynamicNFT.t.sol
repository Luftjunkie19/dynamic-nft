// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "../lib/forge-std/src/Test.sol";
import {DeployDynamicNFT} from "../script/DeployDynamicNFT.sol";
import {DynamicNFT} from "../src/DynamicNFT.sol";

contract TestDynamicNFT is Test {
    DeployDynamicNFT deployer;
    DynamicNFT dynamicNFT;

    function setUp() public {
        deployer = new DeployDynamicNFT();
        dynamicNFT = deployer.run("MyNFT", "MFT", msg.sender, "IDK");
    }

    function testMintDynamicNFT() public {
        vm.prank(msg.sender);
        dynamicNFT.mintNFT(msg.sender, "");
    }

    function testGetNFTBelonging() public {
        // Get the NFT belonging to the sender
        vm.prank(msg.sender);
        address tokenMinter = dynamicNFT.getTokenOwner(0);
        assertEq(tokenMinter, 0x0000000000000000000000000000000000000000);
    }

    function testUpdateTokenURI() public {
        vm.prank(msg.sender);
        dynamicNFT.updateTokenURI(0, msg.sender, "data://");
    }

    function testGetContractsOwner() public view {
        address nftOwner = dynamicNFT.getContractsOwner();
        assertEq(nftOwner, msg.sender);
    }

    function testAddressZero() public view {
        assertEq(0x0000000000000000000000000000000000000000, address(0));
    }
}
