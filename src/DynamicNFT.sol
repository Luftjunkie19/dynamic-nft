// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Base64} from "../lib/openzeppelin-contracts/contracts/utils/Base64.sol";
import {console} from "../lib/forge-std/src/Console.sol";
import {ERC721Burnable} from "../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {IERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {ReentrancyGuard} from "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {PropertyCorrectnessCheckLib} from "../lib/Comparisons.sol";

contract DynamicNFT is
    ERC721,
    Ownable,
    ERC721URIStorage,
    ERC721Burnable,
    ReentrancyGuard
{
    //Errors
    error NotTokenOwner(address tokenOwner);

    error DynamicNFT_InvalidTokenURI();

    error DynamicNFT_NotElligibleToMint(address minter);

    error DynamicNFT_NotElligibleToUpdate(address minter, uint256 tokenId);

    error DynamicNFT_EmptyOrNotFittingConditionsPropertyNameOrValue();

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

    event NFTTransfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    event NFTBurned(address indexed minter, uint256 indexed tokenId);

    // Struct
    struct Attribute {
        string trait_type;
        string value;
    }

    struct Token {
        uint256 tokenId;
        string tokenName;
        string tokenURI;
        string tokenImageURI;
        string description;
        Attribute[] attributes;
    }

    // Mappings

    mapping(uint256 => Attribute[]) public _tokenAttributes;

    mapping(uint256 => address) public _tokenOwners; // Which user owns which NFT?

    mapping(address => uint256[]) public ownerTokens; // List of tokens owned by a user

    mapping(address => mapping(uint256 => Token)) public _tokens;

    mapping(address => Token[]) public _ownerToTokenStruct;

    mapping(address => mapping(address => bool)) public _operatorApprovals;

    mapping(uint256 => address) public _tokenApprovals;

    uint256 private _tokenIdCounter; // Total number of tokens minted

    constructor(
        string memory _name,
        string memory _symbol,
        address _owner
    ) Ownable(_owner) ERC721(_name, _symbol) {}

    // Checking functions and modifiers for proving noone not-allowed is calling the functions.
    modifier isElligible(address minter) {
        if (minter == address(0)) {
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
    using PropertyCorrectnessCheckLib for string;

    function mintNFT(
        address recipient,
        string memory _tokenURI,
        string memory _tokenImageURI,
        string memory tokenName,
        string memory description,
        string[5] memory keys,
        string[5] memory values
    ) external nonReentrant isElligible(recipient) {
        _tokenIdCounter++;
        uint256 tokenId = _tokenIdCounter;

        if (
            !tokenName.checkIfNotEmptyStringAndMatchesRequirements(3, 25) ||
            !description.checkIfNotEmptyStringAndMatchesRequirements(1, 300)
        ) {
            revert DynamicNFT_EmptyOrNotFittingConditionsPropertyNameOrValue();
        }

        if (
            !_tokenURI.contains("ipfs://") ||
            !_tokenImageURI.contains("ipfs://")
        ) {
            revert DynamicNFT_InvalidTokenURI();
        }

        _safeMint(recipient, tokenId);

        _setTokenURI(tokenId, _tokenURI);

        _tokenOwners[tokenId] = recipient;
        ownerTokens[recipient].push(tokenId);

        for (uint256 i = 0; i < keys.length; i++) {
            if (
                !keys[i].checkIfNotEmptyStringAndMatchesRequirements(1, 17) &&
                !values[i].checkIfNotEmptyStringAndMatchesRequirements(0, 24)
            ) {
                revert DynamicNFT_EmptyOrNotFittingConditionsPropertyNameOrValue();
            }

            _tokenAttributes[tokenId].push(Attribute(keys[i], values[i]));
        }

        _tokens[recipient][tokenId] = Token(
            tokenId,
            _tokenURI,
            _tokenImageURI,
            description,
            tokenName,
            _tokenAttributes[tokenId]
        );

        _ownerToTokenStruct[recipient].push(
            Token(
                tokenId,
                tokenName,
                _tokenURI,
                _tokenImageURI,
                description,
                _tokenAttributes[tokenId]
            )
        );

        emit NFTMinted(recipient, tokenId, _tokenURI);
    }

    // Getter Functions
    function getTokenOwner(uint256 tokenId) public view returns (address) {
        return ownerOf(tokenId);
    }

    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter;
    }

    function getOwnersTokensAll(
        address user
    ) public view returns (Token[] memory) {
        return _ownerToTokenStruct[user];
    }

    // NFT Ownership State Management Functions (Transfer, Burn, Etc.)
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override(ERC721, IERC721) {
        if (!_isApprovedOrOwner(from, tokenId)) {
            revert NotTokenOwner(from);
        }

        // Transfer the token
        _safeTransfer(from, to, tokenId, "");



        _transferOwnership(to);

        // Add to new owner's list
        ownerTokens[to].push(tokenId);
        _tokenOwners[tokenId] = to;
        _ownerToTokenStruct[to].push(_tokens[from][tokenId]);
        _tokens[to][tokenId] = _tokens[from][tokenId];

        // Remove from the old owner's token list
        _removeFromOwnerTokens(from, tokenId);

        approve(to, tokenId);

        emit NFTTransfer(from, to, tokenId);
    }

    // Helper function to remove token from owner's list
    function _removeFromOwnerTokens(address from, uint256 tokenId) internal {
        // Remove ownership details
        delete _tokenOwners[tokenId];
        delete _tokenAttributes[tokenId];
        delete _tokens[from][tokenId]; 
       

        for (uint256 i = 0; i < ownerTokens[from].length; i++) {
            if (_tokens[from][ownerTokens[from][i]].tokenId == tokenId &&  _ownerToTokenStruct[from][ownerTokens[from][i]].tokenId == tokenId) {
              delete  _tokens[from][ownerTokens[from][i]];
            delete _ownerToTokenStruct[from][ownerTokens[from][i]];
                break;
            }
        }
    }

    // Approves `to` to operate on `tokenId`
    function approve(
        address to,
        uint256 tokenId
    ) public override(ERC721, IERC721) {
        address tokenOwner = ownerOf(tokenId);

        // Ensure only the owner or an approved operator can approve a new address
        if (
            msg.sender != tokenOwner &&
            !isApprovedForAll(tokenOwner, msg.sender)
        ) {
            revert NotTokenOwner(msg.sender);
        }

        // Approve `to` to transfer the token
        _approve(to, tokenId, address(0));
    }

    // Approves `operator` to manage all of the assets of `owner`
    function setApprovalForAll(
        address operator,
        bool approved
    ) public override(ERC721, IERC721) {
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
        _tokens[updater][tokenId].tokenURI = newTokenURI;

        for (uint256 i = 0; i < _ownerToTokenStruct[updater].length; i++) {
            if (_ownerToTokenStruct[updater][i].tokenId == tokenId) {
                _ownerToTokenStruct[updater][i].tokenURI = newTokenURI;
                break;
            }
        }

        emit NFTUpdated(updater, tokenId, newTokenURI);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        if (_requireOwned(tokenId) == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
        return super.tokenURI(tokenId);
    }

    function burnToken(
        uint256 tokenId
    ) external isElligibleToUpdate(msg.sender, tokenId) {
        // Remove from owner mappings
        address tokenOwner = ownerOf(tokenId);
        _removeFromOwnerTokens(tokenOwner, tokenId);

        _burn(tokenId);

        emit NFTBurned(msg.sender, tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
