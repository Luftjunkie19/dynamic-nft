// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {DynamicNFT} from "../src/DynamicNFT.sol";

contract NFTFactory {
    event CollectionCreated(
        address indexed owner,
        string name,
        string symbol,
        address indexed collectionAddress
    );

    function createCollection(
        string memory name,
        string memory symbol
    ) external {
        DynamicNFT newCollection = new DynamicNFT(name, symbol, msg.sender);
        emit CollectionCreated(
            msg.sender,
            name,
            symbol,
            address(newCollection)
        );
    }
}
