// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Base64} from "../lib/openzeppelin-contracts/contracts/utils/Base64.sol";
import {console} from "../lib/forge-std/src/Console.sol";
import {IERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

contract DynamicNFT is ERC721, Ownable, ERC721URIStorage {
    //Errors
    error NotTokenOwner(address tokenOwner);
    error DynamicNFT_NotElligibleToMint(address minter);
    error DynamicNFT_NotElligibleToUpdate(address minter, uint256 tokenId);

    //Events
    event NFTMinted(
        address indexed minter,
        uint256 indexed tokenId,
        string tokenURI
    );

    //Mapping
    mapping(uint256 => address) public collectionToOwner; // Which user created which collection?
    mapping(address => uint256[]) public ownerCollections; // List of collections owned by a user

    mapping(uint256 => address) private _tokenOwners; // Which user owns which NFT?

    mapping(uint256 => uint256) public tokenToCollection; // Which collection a token belongs to?
    mapping(uint256 => mapping(string => string)) public tokenAttributes;
    mapping(uint256 => string[]) public tokenAttributesKeys;
    mapping(address => uint256[]) public ownerTokens; // List of tokens owned by a user
    mapping(address => mapping(address => bool)) public _operatorApprovals;
    mapping(uint256 => address) public _tokenApprovals;
    uint256 private _tokenIdCounter; // Total number of tokens minted
    uint256 private _collectionCounter; // Total number of collections

    constructor(
        string memory _name,
        string memory _symbol
    ) Ownable(msg.sender) ERC721(_name, _symbol) {}

    function createCollection() external {
        _collectionCounter++;
        uint256 collectionId = _collectionCounter;

        collectionToOwner[collectionId] = msg.sender;
        ownerCollections[msg.sender].push(collectionId);
    }

    function getContractsOwner() public view returns (address) {
        return owner();
    }

    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter;
    }

    modifier isElligible(address minter) {
        if (getContractsOwner() == minter && minter != address(0)) {
            revert DynamicNFT_NotElligibleToMint(minter);
        }
        _;
    }

    modifier isElligibleToUpdate(address minter, uint256 tokenId) {
        if (getTokenOwner(tokenId) != minter && minter != address(0)) {
            revert DynamicNFT_NotElligibleToUpdate(minter, tokenId);
        }
        _;
    }

    function _isApprovedOrOwner(
        address spender,
        uint256 tokenId
    ) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
    }

    function mintNFT(
        string memory _tokenURI,
        uint256 collectionId,
        string[5] memory keys,
        string[5] memory values
    ) external {
        _tokenIdCounter++;
        uint256 tokenId = _tokenIdCounter;

        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, _tokenURI);

        _tokenOwners[tokenId] = msg.sender;
        ownerTokens[msg.sender].push(tokenId);

        if (collectionId != 0) {
            tokenToCollection[tokenId] = collectionId;
        }

        tokenAttributesKeys[tokenId] = keys;
        // Store custom attributes
        for (uint256 i = 0; i < keys.length; i++) {
            tokenAttributes[tokenId][keys[i]] = values[i];
        }
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override(ERC721, IERC721) {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "Not approved or owner"
        );

        _safeTransfer(from, to, tokenId, "");
    }

    // Approves `to` to operate on `tokenId`
    function approve(
        address to,
        uint256 tokenId
    ) public override(ERC721, IERC721) {
        address tokenOwner = ownerOf(tokenId);
        console.log(tokenOwner);
        require(to != tokenOwner, "Can't approve yourself");
        require(
            msg.sender == tokenOwner ||
                isApprovedForAll(tokenOwner, msg.sender),
            "Not authorized"
        );

        _approve(to, tokenId, msg.sender);
    }

    // Approves `operator` to manage all of the assets of `owner`
    function setApprovalForAll(
        address operator,
        bool approved
    ) public override(ERC721, IERC721) {
        require(operator != msg.sender, "Can't approve yourself");

        // Set the operator's approval status
        _operatorApprovals[msg.sender][operator] = approved;

        // Emit event (this is part of ERC721 standard)
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function getApproved(
        uint256 tokenId
    ) public view override(ERC721, IERC721) returns (address) {
        return _getApproved(tokenId);
    }

    function _isApprovedForAll(
        address owner,
        address operator
    ) internal view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function isApprovedForAll(
        address _tokenOwner,
        address operator
    ) public view override(ERC721, IERC721) returns (bool) {
        return _isApprovedForAll(_tokenOwner, operator);
    }

    function updateTokenURI(
        uint256 tokenId,
        address updater,
        string memory newTokenURI
    ) external isElligibleToUpdate(updater, tokenId) {
        console.log(getTokenOwner(tokenId), "token owner");
        console.log(updater, "updater");
        _setTokenURI(tokenId, newTokenURI);
    }

    function getTokenOwner(uint256 tokenId) public view returns (address) {
        return _tokenOwners[tokenId];
    }

    function getUsersToken(
        address user
    ) public view returns (uint256[] memory) {
        return ownerTokens[user];
    }

    function getCollectionTokens(
        uint256 collectionId
    ) external view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](_tokenIdCounter);
        uint256 count = 0;

        for (uint256 i = 1; i <= _tokenIdCounter; i++) {
            if (tokenToCollection[i] == collectionId) {
                result[count] = i;
                count++;
            }
        }

        uint256[] memory trimmedResult = new uint256[](count);
        for (uint256 j = 0; j < count; j++) {
            trimmedResult[j] = result[j];
        }

        return trimmedResult;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        string memory json = string(
            abi.encodePacked(
                '{"name":"My NFT",',
                '"description":"An awesome NFT",',
                '"attributes": ['
            )
        );

        string[] memory keys = tokenAttributesKeys[tokenId]; // Define all attributes you want
        for (uint256 i = 0; i < keys.length; i++) {
            string memory key = keys[i];
            json = string(
                abi.encodePacked(
                    json,
                    '{"trait_type":"',
                    key,
                    '", "value":"',
                    tokenAttributes[tokenId][key],
                    '"}'
                )
            );
            if (i < keys.length - 1) {
                json = string(abi.encodePacked(json, ","));
            }
        }

        json = string(abi.encodePacked(json, "]}"));
        return json;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
