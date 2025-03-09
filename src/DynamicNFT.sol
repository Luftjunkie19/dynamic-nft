// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Base64} from "../lib/openzeppelin-contracts/contracts/utils/Base64.sol";
import {console} from "../lib/forge-std/src/Console.sol";
import {ERC721Burnable} from "../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {IERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

contract DynamicNFT is ERC721, Ownable, ERC721URIStorage, ERC721Burnable {
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

    event NFTUpdated(
        address indexed minter,
        uint256 indexed tokenId,
        string tokenURI
    );

    event NFTBurned(address indexed minter, uint256 indexed tokenId);

    //Structs

    struct Attribute {
        string trait_type;
        string value;
    }

    struct DynamicToken {
        address owner;
        uint256 tokenId;
        string tokenURI;
        string imageURI;
        string description;
        Attribute[] attributes;
    }

    //Mappings
    mapping(uint256 => address) public collectionToOwner; // Which user created which collection?
    mapping(address => uint256[]) public ownerCollections; // List of collections owned by a user

    mapping(address => mapping(uint256 => DynamicToken)) private userToTokenObj;
    mapping(uint256 => address) private _tokenOwners; // Which user owns which NFT?

    mapping(uint256 => uint256) public tokenToCollection; // Which collection a token belongs to?
    mapping(uint256 => mapping(string => string)) public tokenAttributes;
    mapping(uint256 => string[]) public tokenAttributesKeys;
    mapping(address => uint256[]) public ownerTokens; // List of tokens owned by a user
    mapping(address => mapping(address => bool)) public _operatorApprovals;

    mapping(address => mapping(uint256 => string)) private ownerTotokenImageURI;

    mapping(uint256 => address) public _tokenApprovals;
    mapping(uint256 => string) tokenIdToTokenURI;
    uint256 private _tokenIdCounter; // Total number of tokens minted
    uint256 private _collectionCounter; // Total number of collections

    constructor(
        string memory _name,
        string memory _symbol
    ) Ownable(msg.sender) ERC721(_name, _symbol) {}

    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter;
    }

    // Checking functions and modifiers for proving noone not-allowed is calling the functions.
    modifier isElligible(address minter) {
        if (minter != address(0)) {
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
        return (spender == ownerOf(tokenId) ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(ownerOf(tokenId), spender));
    }

    function _isApprovedForAll(
        address _owner,
        address operator
    ) internal view returns (bool) {
        return _operatorApprovals[_owner][operator];
    }

    function isApprovedForAll(
        address _tokenOwner,
        address operator
    ) public view override(ERC721, IERC721) returns (bool) {
        return _isApprovedForAll(_tokenOwner, operator);
    }

    // Main function created to enable anyone to mint his own NFT.

    function mintNFT(
        string memory _tokenURI,
        string memory _tokenImageURI,
        string memory description,
        uint256 collectionId,
        string[5] memory keys,
        string[5] memory values
    ) external isElligible(msg.sender) {
        _tokenIdCounter++;
        uint256 tokenId = _tokenIdCounter;

        tokenIdToTokenURI[tokenId] = _tokenURI;
        _safeMint(msg.sender, tokenId);
        super._setTokenURI(tokenId, _tokenURI);

        ownerTotokenImageURI[msg.sender][tokenId] = _tokenImageURI;

        _tokenOwners[tokenId] = msg.sender;
        ownerTokens[msg.sender].push(tokenId);

        if (collectionId != 0) {
            tokenToCollection[tokenId] = collectionId;
        }

        userToTokenObj[msg.sender][tokenId] = DynamicToken({
            owner: msg.sender,
            tokenId: tokenId,
            tokenURI: _tokenURI,
            imageURI: _tokenImageURI,
            description: description,
            attributes: new Attribute[](0)
        });

        tokenAttributesKeys[tokenId] = keys;

        for (uint256 i = 0; i < keys.length; i++) {
            tokenAttributes[tokenId][keys[i]] = values[i];
            userToTokenObj[msg.sender][tokenId].attributes.push(
                Attribute({trait_type: keys[i], value: values[i]})
            );
        }

        emit NFTMinted(msg.sender, tokenId, _tokenURI);
    }

    // Getter Functions
    function getTokenOwner(uint256 tokenId) public view returns (address) {
        return _tokenOwners[tokenId];
    }

    function getUsersTokens(
        address user
    ) public view returns (uint256[] memory) {
        return ownerTokens[user];
    }

    function getUsersTokensStructs(
        address _user
    ) public view returns (DynamicToken[] memory) {
        uint256[] memory tokenIds = getUsersTokens(_user);

        DynamicToken[] memory tokenStructs = new DynamicToken[](
            tokenIds.length
        );

        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenStructs[i] = userToTokenObj[_user][tokenIds[i]];
        }

        return tokenStructs;
    }

    function getTokenImageURI(
        address addr,
        uint256 tokenId
    ) public view returns (string memory) {
        return ownerTotokenImageURI[addr][tokenId];
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

        return result;
    }

    function getContractsOwner() public view returns (address) {
        return owner();
    }

    // Create collection
    function createCollection() external {
        _collectionCounter++;
        uint256 collectionId = _collectionCounter;

        collectionToOwner[collectionId] = msg.sender;
        ownerCollections[msg.sender].push(collectionId);
    }

    // NFT Ownership State Management Functions (Transfer, Burn, Etc.)
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override(ERC721, IERC721) {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "Not approved or owner"
        );

        DynamicToken memory token = userToTokenObj[from][tokenId];

        userToTokenObj[to][tokenId] = token;

        userToTokenObj[to][tokenId].owner = to;

        delete userToTokenObj[from][tokenId];

        // Remove from previous owner's list
        uint256[] storage fromTokens = ownerTokens[from];
        for (uint256 i = 0; i < fromTokens.length; i++) {
            if (fromTokens[i] == tokenId) {
                fromTokens[i] = fromTokens[fromTokens.length - 1]; // Swap with last element
                fromTokens.pop(); // Remove last element
                break;
            }
        }

        // Transfer the token
        _safeTransfer(from, to, tokenId, "");

        // Add to new owner's list
        ownerTokens[to].push(tokenId);
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

    // Gets the address of the approved token
    function getApproved(
        uint256 tokenId
    ) public view override(ERC721, IERC721) returns (address) {
        return _getApproved(tokenId);
    }

    // Updates the URI of the token
    function updateTokenURI(
        uint256 tokenId,
        address updater,
        string memory newTokenURI
    ) external isElligibleToUpdate(updater, tokenId) {
        console.log(getTokenOwner(tokenId), "token owner");
        console.log(updater, "updater");
        _setTokenURI(tokenId, newTokenURI);

        tokenIdToTokenURI[tokenId] = newTokenURI;

        userToTokenObj[updater][tokenId].tokenURI = newTokenURI;

        emit NFTUpdated(updater, tokenId, newTokenURI);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        require(
            _tokenOwners[tokenId] != address(0),
            "ERC721Metadata: URI query for nonexistent token"
        );

        return super.tokenURI(tokenId);
    }

    function burnToken(
        uint256 tokenId
    ) external isElligibleToUpdate(msg.sender, tokenId) {
        // Remove from owner's token list
        uint256[] storage tokens = ownerTokens[ownerOf(tokenId)];
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == tokenId) {
                tokens[i] = tokens[tokens.length - 1]; // Swap with last token
                tokens.pop(); // Remove last token
                break;
            }
        }

        // Remove ownership mappings
        delete _tokenOwners[tokenId];
        delete tokenIdToTokenURI[tokenId];
        delete tokenToCollection[tokenId];
        delete userToTokenObj[msg.sender][tokenId];

        // Clear token attributes
        delete tokenAttributesKeys[tokenId];
        for (uint256 i = 0; i < tokenAttributesKeys[tokenId].length; i++) {
            delete tokenAttributes[tokenId][tokenAttributesKeys[tokenId][i]];
        }

        _burn(tokenId);

        emit NFTBurned(msg.sender, tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
