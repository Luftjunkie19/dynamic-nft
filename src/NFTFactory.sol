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
    struct Attribute {
        string trait_type;
        string value;
    }

    struct Token {
        string tokenName;
        string tokenURI;
        string tokenImageURI;
        string description;
        Attribute[] attributes;
    }

mapping(address=>address[]) private collections;

    function createCollection(
        string memory name,
        string memory symbol,
        Token[] memory tokens
    ) external {
        DynamicNFT newCollection = new DynamicNFT(name, symbol, msg.sender);

        string[5] memory keys;
        string[5] memory values;

        for (uint256 i = 0; i < tokens.length; i++) {
            for (uint256 j = 0; j < tokens[i].attributes.length; j++) {
                keys[i] = (tokens[i].attributes[j].trait_type);
                values[i] = (tokens[i].attributes[j].value);
            }
        }

        if(tokens.length > 0) {     
        for (uint256 i = 0; i < tokens.length; i++) {
            newCollection.mintNFT(
                tokens[i].tokenName,
                tokens[i].tokenImageURI,
                tokens[i].tokenURI,
                tokens[i].description,
                keys,
                values
            );
        }
        }
        collections[msg.sender].push(address(newCollection));
        
        emit CollectionCreated(
            msg.sender,
            name,
            symbol,
            address(newCollection)
        );
    }


    function getUsersCollections() external view returns(address[] memory) {
        return collections[msg.sender];
    }
}
