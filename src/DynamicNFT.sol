// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract NFTToken is ERC721, ERC721URIStorage, Ownable {
    event NFTMinted(address minter, uint256 tokenId, string tokenURI);

    constructor(
        string memory _name,
        string memory _symbol,
        address initialOwner
    ) ERC721(_name, _symbol) Ownable(initialOwner) {}

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _safeMint(address to, uint256 tokenId) internal override {
        super._safeMint(to, tokenId);
    }
}
