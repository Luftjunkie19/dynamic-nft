// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Base64} from "../lib/openzeppelin-contracts/contracts/utils/Base64.sol";
import {console} from "../lib/forge-std/src/Console.sol";

contract DynamicNFT is ERC721, ERC721URIStorage, Ownable {
    error NotTokenOwner(address tokenOwner);
    error DynamicNFT_NotElligibleToMint(address minter);

    event NFTMinted(address minter, uint256 tokenId, string tokenURI);

    uint256 private _tokenIdCounter;
    mapping(uint256 => address) private _tokenOwners;

    string private attributeName;

    address private _owner;

    constructor(
        string memory _name,
        string memory _symbol,
        address initialOwner,
        string memory _attributeName
    ) ERC721(_name, _symbol) Ownable(initialOwner) {
        attributeName = _attributeName;
        _owner = initialOwner;
    }

    function getContractsOwner() public view returns (address) {
        return _owner;
    }

    modifier isElligible(address minter) {
        if (_owner != minter && minter != address(0)) {
            revert DynamicNFT_NotElligibleToMint(minter);
        }
        _;
    }

    function mintNFT(
        address minter,
        string memory _tokenURI
    ) external isElligible(minter) {
        uint256 tokenId = _tokenIdCounter;
        _safeMint(minter, tokenId);
        _setTokenURI(tokenId, _tokenURI);

        _tokenOwners[tokenId] = minter;
        emit NFTMinted(minter, tokenId, _tokenURI);

        _tokenIdCounter++; // Increment token ID for next mint
    }

    function updateTokenURI(
        uint256 tokenId,
        address updater,
        string memory newTokenURI
    ) external isElligible(updater) {
        console.log(getTokenOwner(tokenId), "token owner");
        console.log(updater, "updater");
        if (getTokenOwner(tokenId) != updater) {
            revert NotTokenOwner(updater);
        }
        _setTokenURI(tokenId, newTokenURI);
    }

    function getTokenOwner(uint256 tokenId) public view returns (address) {
        return _tokenOwners[tokenId];
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name(), // You can add whatever name here
                                '", "description":"An NFT that reflects the mood of the owner, 100% on Chain!", ',
                                '"attributes": [{"trait_type": "',
                                attributeName,
                                '","value": 100"',
                                '"image":"',
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
