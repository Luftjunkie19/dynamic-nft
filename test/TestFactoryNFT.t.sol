// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Test} from "../lib/forge-std/src/Test.sol";

import {NFTFactory} from "../src/NFTFactory.sol";
import {DynamicNFT} from "../src/DynamicNFT.sol";

contract TestFactoryNFT is Test {
    NFTFactory nftFactory;
    NFTFactory.Token token;

    address customAddress = makeAddr("user_memory");

    function setUp() public {
        nftFactory = new NFTFactory();
    }

    function testFactoryInit() public view {
        assert(address(nftFactory) != address(0));
    }

    function testFactoryCreateCollection() public {
        // Create a new collection
        vm.startPrank(customAddress);

        nftFactory.createCollection(
            "TestToken",
            "TFT",
            NFTFactory.Token(
                "Clone_NFT",
                "ipfs://bafkreih5m2ryuxy4yy6bglwdczhprp3bzi6jfyuthfj3mkghuzhjeqs65u",
                "ipfs://bafkreiaep6nwlaajzonx3n3vl6jy2ygs4bypaczcmjr2qbq4aubp3q2tuq",
                "This description is super cool"
            ),
            ["freedom", "anarchy", "stupidity", "maturity", "maturity"],
            ["436", "532", "31", "954", "752"]
        );

        vm.stopPrank();
    }

    function testFactoryGetCollectionAddressByOwner() public {
        testFactoryCreateCollection();

        vm.prank(customAddress);
        assertEq(nftFactory.getUsersCollections().length, 1);
    }

    function testRevert_EmptyNameOrSymbol() public {
        vm.startPrank(customAddress);

        nftFactory.createCollection(
            "T",
            "T",
            NFTFactory.Token(
                "Clone_NFT",
                "ipfs://bafkreih5m2ryuxy4yy6bglwdczhprp3bzi6jfyuthfj3mkghuzhjeqs65u",
                "ipfs://bafkreiaep6nwlaajzonx3n3vl6jy2ygs4bypaczcmjr2qbq4aubp3q2tuq",
                "This description is super cool"
            ),
            ["freedom", "anarchy", "stupidity", "maturity", "maturity"],
            ["436", "532", "31", "954", "752"]
        );

        vm.stopPrank();
    }
}
