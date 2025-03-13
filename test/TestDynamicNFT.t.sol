// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Vm} from "../lib/forge-std/src/Vm.sol";
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
        (dynamicNFT, ) = deployer.run();
    }

    function testMintNFT(address caller) public {
        dynamicNFT.mintNFT(
            caller,
            "ipfs://bafkreibc53zyfwu7n74gk734bed37jc5x3lrdikmc2gdmxhvztxsgvcv3a",
            "ipfs://bafkreihpupfva7vteubfyfm5iuds4fcs6fdngyc2gbl64tlu4jgpydtasq",
            "Cool_NFT",
            "This is a coolish description",
            ["Strength", "Shooting", "Health", "Accuracy", "Tactics"],
            ["74", "97", "83", "96", "86"]
        );
    }

    function testUpdateTokenURI() public {
        testMintNFT(customUserAddress);
        // Update the token URI
        dynamicNFT.updateTokenURI(1, customUserAddress, "ipfs://");
    }

    function testBurnToken() public {
        testMintNFT(customUserAddress);
        //Burning token
        vm.startPrank(customUserAddress);
        dynamicNFT.burnToken(1);
        vm.stopPrank();
    }

    function testOwnership() public {
        testMintNFT(msg.sender);
        assert(dynamicNFT.getTokenOwner(1) == msg.sender);
    }

    function testGetOwnersTokensAll(address user) public {
        vm.assume(user != address(0));

        testMintNFT(user);
        vm.prank(user);
        assert(dynamicNFT.getOwnersTokensAll(user).length > 0);
    }

    function testTransferTokenAndApprove() public {
        testMintNFT(customUserAddress);
        assert(dynamicNFT.getTokenOwner(1) == customUserAddress);

        vm.startPrank(msg.sender);
        dynamicNFT.safeTransferFrom(customUserAddress, msg.sender, 1);
        vm.stopPrank();
    }

    function testSetApprovedForAll() public {
        testMintNFT(msg.sender);

        assert(
            keccak256(abi.encodePacked(dynamicNFT.tokenURI(1))) !=
                keccak256(abi.encodePacked(""))
        );

        vm.prank(msg.sender);

        dynamicNFT.setApprovalForAll(customUserAddress, true);
    }
}
