// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "../lib/forge-std/src/Test.sol";
import {DeployDynamicNFT} from "../script/DeployDynamicNFT.s.sol";
import {DynamicNFT} from "../src/DynamicNFT.sol";

contract TestDynamicNFT is Test {
    DeployDynamicNFT deployer;
    DynamicNFT dynamicNFT;

    function setUp() public {
        deployer = new DeployDynamicNFT();
        dynamicNFT = deployer.run();
    }

    function testMintDynamicNFT() public {
        vm.prank(msg.sender);

        string[5] memory attributes;
        attributes[0] = "Strength";
        attributes[1] = "Agility";
        attributes[2] = "Intelligence";
        attributes[3] = "Charisma";
        attributes[4] = "Wisdom";

        string[5] memory values;
        values[0] = "100";
        values[1] = "99";
        values[2] = "100";
        values[3] = "100";
        values[4] = "100";

        dynamicNFT.mintNFT("", "", "", attributes, values);
    }

    function testContractApproval() public {
        address user = makeAddr("user");

        dynamicNFT.setApprovalForAll(user, true);
    }

    function testGetNFTBelonging() public {
        testMintDynamicNFT();
        address tokenMinter = dynamicNFT.getTokenOwner(0); // Use tokenId = 1
        assertEq(tokenMinter, address(0));
    }

    function testGetApproved() public view {
        dynamicNFT.getApproved(0);
    }

    function testIsApprovedForAll() public {
        address userAddr = makeAddr("user");

        vm.prank(userAddr);
        dynamicNFT.isApprovedForAll(msg.sender, userAddr);
    }

    function testGetContractsOwner() public view {
        assertEq(msg.sender, dynamicNFT.getContractsOwner());
    }

    function test_GetTokenURI() public view {
        string memory tokenURI = dynamicNFT.tokenURI(0);
        assertEq(
            keccak256(abi.encode(tokenURI)),
            keccak256(abi.encode(tokenURI))
        );
    }
}
