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

    // Struct
    struct Attribute {
        string trait_type;
        string value;
    }

    // Mappings

    mapping(uint256 => string) private _tokenImageURIs;

    mapping(uint256 => Attribute[]) private _tokenAttributes;

    mapping(uint256 => string) private _tokenDescriptions;

    mapping(uint256 => address) private _tokenOwners; // Which user owns which NFT?

    mapping(address => uint256[]) public ownerTokens; // List of tokens owned by a user

    mapping(address => mapping(address => bool)) public _operatorApprovals;

    mapping(address => mapping(uint256 => string)) private ownerTotokenImageURI;

    mapping(uint256 => address) public _tokenApprovals;

    uint256 private _tokenIdCounter; // Total number of tokens minted

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
            _isApprovedForAll(ownerOf(tokenId), spender));
    }

    function _isApprovedForAll(
        address _owner,
        address operator
    ) internal view returns (bool) {
        return _operatorApprovals[_owner][operator];
    }

    // Main function created to enable anyone to mint his own NFT.

    function mintNFT(
        string memory _tokenURI,
        string memory _tokenImageURI,
        string memory description,
        string[5] memory keys,
        string[5] memory values
    ) external isElligible(msg.sender) {
        _tokenIdCounter++;
        uint256 tokenId = _tokenIdCounter;

        _safeMint(msg.sender, tokenId);
        super._setTokenURI(tokenId, _tokenURI);

        ownerTotokenImageURI[msg.sender][tokenId] = _tokenImageURI;

        _tokenOwners[tokenId] = msg.sender;
        ownerTokens[msg.sender].push(tokenId);
        _tokenDescriptions[tokenId] = description;

        for (uint256 i = 0; i < keys.length; i++) {
            _tokenAttributes[tokenId].push(Attribute(keys[i], values[i]));
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

    function getUsersTokenInfo(
        uint256 tokenId
    )
        public
        view
        returns (
            string memory,
            string memory,
            string memory,
            Attribute[] memory,
            uint256
        )
    {
        return (
            super.tokenURI(tokenId),
            _tokenImageURIs[tokenId],
            _tokenDescriptions[tokenId],
            _tokenAttributes[tokenId],
            tokenId
        );
    }

    function getTokenImageURI(
        address addr,
        uint256 tokenId
    ) public view returns (string memory) {
        return ownerTotokenImageURI[addr][tokenId];
    }

    function getContractsOwner() public view returns (address) {
        return owner();
    }

    // NFT Ownership State Management Functions (Transfer, Burn, Etc.)
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override(ERC721, IERC721) {
        if (!_isApprovedOrOwner(msg.sender, tokenId)) {
            revert NotTokenOwner(msg.sender);
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

        if (
            to != tokenOwner ||
            msg.sender != tokenOwner ||
            !_isApprovedForAll(tokenOwner, msg.sender)
        ) {
            revert NotTokenOwner(msg.sender);
        }

        _approve(to, tokenId, msg.sender);
    }

    // Approves `operator` to manage all of the assets of `owner`
    function setApprovalForAll(
        address operator,
        bool approved
    ) public override(ERC721, IERC721) {
        if (operator != msg.sender) {
            revert NotTokenOwner(msg.sender);
        }

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
        _setTokenURI(tokenId, newTokenURI);

        emit NFTUpdated(updater, tokenId, newTokenURI);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        if (_tokenOwners[tokenId] != address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
        return super.tokenURI(tokenId);
    }

    function burnToken(
        uint256 tokenId
    ) external isElligibleToUpdate(msg.sender, tokenId) {
        // Remove ownership mappings
        delete _tokenOwners[tokenId];

        _burn(tokenId);

        emit NFTBurned(msg.sender, tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
