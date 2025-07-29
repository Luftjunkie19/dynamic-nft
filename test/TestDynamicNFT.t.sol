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
    address customUserAddress2 = makeAddr("user626");

    function setUp() public {
        deployer = new DeployDynamicNFT();
        (dynamicNFT, ) = deployer.run();
    }

    function testMintNFT(address caller) public {
        vm.assume(caller != address(0));
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

    function helperMinterFunction(address caller) public {
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


    function testRevertMintNft() public {
        vm.expectRevert();
           dynamicNFT.mintNFT(
            address(0),
            "ipfs://bafkreibc53zyfwu7n74gk734bed37jc5x3lrdikmc2gdmxhvztxsgvcv3a",
            "ipfs://bafkreihpupfva7vteubfyfm5iuds4fcs6fdngyc2gbl64tlu4jgpydtasq",
            "Cool_NFT",
            "This is a coolish description",
            ["Strength", "Shooting", "Health", "Accuracy", "Tactics"],
            ["74", "97", "83", "96", "86"]
        );
    }


function testRevertUpdateOrBurnTokenURI() public {
    vm.prank(customUserAddress);
    helperMinterFunction(customUserAddress);

vm.startPrank(customUserAddress2);
    vm.expectRevert();
    dynamicNFT.updateTokenURI(1, customUserAddress2, "ipfs://new-uri");
    vm.stopPrank();

    vm.startPrank(customUserAddress2);
    vm.expectRevert();
    dynamicNFT.burnToken(1);
    vm.stopPrank();
    }

function testTokenURI() public {
vm.prank(customUserAddress);
    helperMinterFunction(customUserAddress);

    vm.expectRevert();
    dynamicNFT.tokenURI(2); // Token ID 2 does not exist

    string memory tokenURI = dynamicNFT.tokenURI(1);
    assert(keccak256(abi.encodePacked(tokenURI)) != keccak256(abi.encodePacked("")));

}

function testTokenApprove() public {
    vm.prank(customUserAddress);
    helperMinterFunction(customUserAddress);

      vm.prank(customUserAddress2);
    helperMinterFunction(customUserAddress2);

vm.startPrank(customUserAddress);
    vm.expectRevert();
    dynamicNFT.approve(customUserAddress2, 1);
    vm.stopPrank();

    vm.startPrank(customUserAddress2);
    dynamicNFT.approve(customUserAddress2, 2);
    vm.stopPrank();
}

    function testUpdateTokenURI() public {
        helperMinterFunction(customUserAddress);
        // Update the token URI
        dynamicNFT.updateTokenURI(1, customUserAddress, "ipfs://");
        assert(
            keccak256(abi.encodePacked(dynamicNFT.tokenURI(1))) ==
                keccak256(abi.encodePacked("ipfs://"))
        );
    }

    function testBurnToken() public {
        helperMinterFunction(customUserAddress);
        //Burning token
        vm.startPrank(customUserAddress);
        dynamicNFT.burnToken(1);

        assert(dynamicNFT.getOwnersTokensAll(customUserAddress).length == 0);
        vm.stopPrank();
    }

    function testOwnership() public {
        helperMinterFunction(msg.sender);
        assert(dynamicNFT.getTokenOwner(1) == msg.sender);
    }

    function testGetOwnersTokensAll(address user) public {
        vm.assume(user != address(0));

        helperMinterFunction(user);

        assert(dynamicNFT.getOwnersTokensAll(user).length > 0);
    }

    function testTransferTokenAndApprove() public {
        helperMinterFunction(customUserAddress);
        assert(dynamicNFT.getTokenOwner(1) == customUserAddress);

        vm.startPrank(customUserAddress2);
        vm.expectRevert();
        dynamicNFT.safeTransferFrom(customUserAddress, msg.sender, 2);

        dynamicNFT.safeTransferFrom(customUserAddress, msg.sender, 1);
        vm.stopPrank();
    }

    function testSetApprovedForAll() public {
        vm.prank(customUserAddress);
        helperMinterFunction(msg.sender);

        assert(
            keccak256(abi.encodePacked(dynamicNFT.tokenURI(1))) !=
                keccak256(abi.encodePacked(""))
        );

        vm.prank(customUserAddress);
        dynamicNFT.setApprovalForAll(customUserAddress2, true);
    }

    function testCheckIfTokenRemovedAfterTransfer() public {
        helperMinterFunction(customUserAddress);
        dynamicNFT.safeTransferFrom(customUserAddress, msg.sender, 1);

        assert(dynamicNFT.getOwnersTokensAll(customUserAddress).length == 0);
    }
}
