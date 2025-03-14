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

    // Struct

    struct Token {
        string tokenName;
        string tokenURI;
        string tokenImageURI;
        string description;
    }

    mapping(address => address[]) private collections;

    function createCollection(
        string memory name,
        string memory symbol,
        Token memory token,
        string[5] memory traitsTypes,
        string[5] memory values
    ) external {
        // Create collection and update state BEFORE minting to avoid reentrancy
        DynamicNFT newCollection = new DynamicNFT(name, symbol, msg.sender);

        collections[msg.sender].push(address(newCollection));

        emit CollectionCreated(
            msg.sender,
            name,
            symbol,
            address(newCollection)
        );

        newCollection.mintNFT(
            msg.sender,
            token.tokenImageURI,
            token.tokenURI,
            token.tokenName,
            token.description,
            traitsTypes,
            values
        );
    }

    function getUsersCollections() external view returns (address[] memory) {
        return collections[msg.sender];
    }
}
