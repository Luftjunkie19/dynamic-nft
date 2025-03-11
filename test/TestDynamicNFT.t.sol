// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "../lib/forge-std/src/Test.sol";
import {DeployDynamicNFT} from "../script/DeployDynamicNFT.s.sol";
import {DynamicNFT} from "../src/DynamicNFT.sol";

contract TestDynamicNFT is Test {
    DeployDynamicNFT deployer;
    DynamicNFT dynamicNFT;

    struct Attribute {
        string trait_type;
        string value;
    }

    address customUserAddress = makeAddr("user625");

    function setUp() public {
        deployer = new DeployDynamicNFT();
        dynamicNFT = deployer.run();
    }

    function testMintNFT() public {
        vm.prank(msg.sender);
        // Mint a new NFT
        dynamicNFT.mintNFT(
            "ipfs://bafkreibc53zyfwu7n74gk734bed37jc5x3lrdikmc2gdmxhvztxsgvcv3a",
            "ipfs://bafkreihpupfva7vteubfyfm5iuds4fcs6fdngyc2gbl64tlu4jgpydtasq",
            "This is a coolish description",
            ["Strength", "Shooting", "Health", "Accuracy", "Tactics"],
            ["74", "97", "83", "96", "86"]
        );
    }

    function testUpdateTokenURI() public {
        vm.prank(customUserAddress);
        // Mint a new NFT
        dynamicNFT.mintNFT(
            "ipfs://bafkreibc53zyfwu7n74gk734bed37jc5x3lrdikmc2gdmxhvztxsgvcv3a",
            "ipfs://bafkreihpupfva7vteubfyfm5iuds4fcs6fdngyc2gbl64tlu4jgpydtasq",
            "This is a coolish description",
            ["Strength", "Shooting", "Health", "Accuracy", "Tactics"],
            ["74", "97", "83", "96", "86"]
        );
        // Update the token URI
        dynamicNFT.updateTokenURI(1, customUserAddress, "ipfs://");
    }

    function testBurnToken() public {
        vm.startPrank(customUserAddress);
        // Mint a new NFT
        dynamicNFT.mintNFT(
            "ipfs://bafkreibc53zyfwu7n74gk734bed37jc5x3lrdikmc2gdmxhvztxsgvcv3a",
            "ipfs://bafkreihpupfva7vteubfyfm5iuds4fcs6fdngyc2gbl64tlu4jgpydtasq",
            "This is a coolish description",
            ["Strength", "Shooting", "Health", "Accuracy", "Tactics"],
            ["74", "97", "83", "96", "86"]
        );
        //Burning token
        dynamicNFT.burnToken(1);
        vm.stopPrank();
    }

    function testOwnership() public {
        vm.prank(msg.sender);
        dynamicNFT.mintNFT(
            "ipfs://bafkreibc53zyfwu7n74gk734bed37jc5x3lrdikmc2gdmxhvztxsgvcv3a",
            "ipfs://bafkreihpupfva7vteubfyfm5iuds4fcs6fdngyc2gbl64tlu4jgpydtasq",
            "This is a coolish description",
            ["Strength", "Shooting", "Health", "Accuracy", "Tactics"],
            ["74", "97", "83", "96", "86"]
        );
        assert(dynamicNFT.getTokenOwner(1) == msg.sender);
    }

    function testGetOwnersTokensAll(address user) public {
        vm.assume(user != address(0));

        vm.prank(user);
        dynamicNFT.mintNFT(
            "ipfs://bafkreibc53zyfwu7n74gk734bed37jc5x3lrdikmc2gdmxhvztxsgvcv3a",
            "ipfs://bafkreihpupfva7vteubfyfm5iuds4fcs6fdngyc2gbl64tlu4jgpydtasq",
            "This is a coolish description",
            ["Strength", "Shooting", "Health", "Accuracy", "Tactics"],
            ["74", "97", "83", "96", "86"]
        );

        assert(dynamicNFT.getOwnersTokensAll(user).length > 0);
    }

    function testGetUsersTokens(address user) public {
        vm.assume(user != address(0));

        vm.prank(user);
        dynamicNFT.mintNFT(
            "ipfs://bafkreibc53zyfwu7n74gk734bed37jc5x3lrdikmc2gdmxhvztxsgvcv3a",
            "ipfs://bafkreihpupfva7vteubfyfm5iuds4fcs6fdngyc2gbl64tlu4jgpydtasq",
            "This is a coolish description",
            ["Strength", "Shooting", "Health", "Accuracy", "Tactics"],
            ["74", "97", "83", "96", "86"]
        );

        assert(dynamicNFT.getUsersTokens(user).length > 0);
    }

    function testTransferTokenAndApprove() public {
        vm.startPrank(customUserAddress);
        dynamicNFT.mintNFT(
            "ipfs://bafkreibc53zyfwu7n74gk734bed37jc5x3lrdikmc2gdmxhvztxsgvcv3a",
            "ipfs://bafkreihpupfva7vteubfyfm5iuds4fcs6fdngyc2gbl64tlu4jgpydtasq",
            "This is a coolish description",
            ["Strength", "Shooting", "Health", "Accuracy", "Tactics"],
            ["74", "97", "83", "96", "86"]
        );

        assert(dynamicNFT.getTokenOwner(1) == customUserAddress);
        vm.stopPrank();

        vm.startPrank(msg.sender);
        dynamicNFT.safeTransferFrom(customUserAddress, msg.sender, 1);
    }

    function testGetContractsOwner() public view {
        assert(dynamicNFT.getContractsOwner() != address(0));
    }

    function testgetUsersTokenInfo() public {
        vm.startPrank(customUserAddress);
        dynamicNFT.mintNFT(
            "ipfs://bafkreibc53zyfwu7n74gk734bed37jc5x3lrdikmc2gdmxhvztxsgvcv3a",
            "ipfs://bafkreihpupfva7vteubfyfm5iuds4fcs6fdngyc2gbl64tlu4jgpydtasq",
            "This is a coolish description",
            ["Strength", "Shooting", "Health", "Accuracy", "Tactics"],
            ["74", "97", "83", "96", "86"]
        );
        dynamicNFT.getUsersTokenInfo(1);
        vm.stopPrank();
    }

    function testSetApprovedForAll() public {
        vm.startPrank(msg.sender);
        dynamicNFT.mintNFT(
            "ipfs://bafkreibc53zyfwu7n74gk734bed37jc5x3lrdikmc2gdmxhvztxsgvcv3a",
            "ipfs://bafkreihpupfva7vteubfyfm5iuds4fcs6fdngyc2gbl64tlu4jgpydtasq",
            "This is a coolish description",
            ["Strength", "Shooting", "Health", "Accuracy", "Tactics"],
            ["74", "97", "83", "96", "86"]
        );

        assert(
            keccak256(abi.encodePacked(dynamicNFT.tokenURI(1))) !=
                keccak256(abi.encodePacked(""))
        );

        dynamicNFT.setApprovalForAll(customUserAddress, true);

        vm.stopPrank();
    }

    function testGetTokenImageURI() public {
        vm.startPrank(msg.sender);
        dynamicNFT.mintNFT(
            "ipfs://bafkreibc53zyfwu7n74gk734bed37jc5x3lrdikmc2gdmxhvztxsgvcv3a",
            "ipfs://bafkreihpupfva7vteubfyfm5iuds4fcs6fdngyc2gbl64tlu4jgpydtasq",
            "This is a coolish description",
            ["Strength", "Shooting", "Health", "Accuracy", "Tactics"],
            ["74", "97", "83", "96", "86"]
        );
        assert(
            keccak256(
                abi.encodePacked(dynamicNFT.getTokenImageURI(msg.sender, 1))
            ) != keccak256(abi.encodePacked(""))
        );
        vm.stopPrank();
    }
}
