
# HyperMint NFT-Smart Contract

A simple dynamic NFT (ERC-721) minting and managing smart-contract. This repository consists of 
2 smart contracts.
- `DynamicNFT.sol` - Which is basically the NFT (ERC-721) smart contract.
- `NFTFactory.sol` - Which is the contract deployer for `DynamicNFT.sol`, the user customized collection.



## Main functions for `DynamicNFT.sol`

```solidity
function mintNFT(address recipient,
        string memory _tokenURI,
        string memory _tokenImageURI,
        string memory tokenName,
        string memory description,
        string[5] memory keys,
        string[5] memory values){}



```
This function takes 5 parameters besides, the obvious ones, I'd like to clarify the last to ones. 

- `string[5] memory keys` - this contains the property names of the attributes

- `string[5] memory values` - this contains the values of the attributes

It's been done this way because solidity cannot implicitly add the struct array.

The function is responsible for as the name says **MINTING** 🤯. But besides it, it also manages adding the NFT to mappings like:
```
    mapping(uint256 => address) private _tokenOwners; // Which user owns which NFT Token ?

    mapping(address => uint256[]) private ownerTokens; // List of token addressed owned by a user.

    mapping(address => mapping(uint256 => Token)) private _tokens; 
    // Manages the assignment of a specific Token to the tokenId, which mapping is assigned
// to the address of the owner.
```

```
 // NFT Ownership State Management Functions (Transfer, Burn, Etc.)
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override(ERC721, IERC721) {
    }
```
It manages removing the data from the current owner, assigning to a new one and getting rid of the token from current owner's account.

```
  // Helper function to remove token from owner's list
    function _removeFromOwnerToken(address from, uint256 tokenId) internal {
    }
```
This function includes for loop to get rid of certain items in mapping's array and also deletes certain key-value pair from mappings.
```
// Updates the URI of the token
    function updateTokenURI(
        uint256 tokenId,
        address updater,
        string memory newTokenURI
    ) external isElligibleToUpdate(updater, tokenId) {
    }
```
It set's the tokenURI to a new one and updates the mappings.

```
    function burnToken(
        uint256 tokenId
    ) external isElligibleToUpdate(msg.sender, tokenId) {
        // Remove from owner mappings
        address tokenOwner = ownerOf(tokenId);
        _removeFromOwnerToken(tokenOwner, tokenId);

        _burn(tokenId);

        emit NFTBurned(msg.sender, tokenId);
    }
```
This function calls special function called `_burn` and the `_removeFromOwnerToken`






## Acknowledgements

  - [Patrick Collins, CEO Of Cyfrin](https://github.com/patrickalphac) - Who Created an awesome course on Solidity and Foundry.

## Lessons Learned

- Write VERY specific tests to know if something in the code is not broken or flawed.

- Sometimes the errors might come from unexpected parts of the code.

- Don't overcomplicate the code. Coz the block-size matters while deployment.

- ####  READ THE FUCKING DOCS !

- Branches test stands for the decision blocks.
## Running Tests

To run tests (generally), run the following command

```bash
  forge test 
```
If you want to run the tests with details, run

```bash
  forge test  -vvvvv
```

The example above shows the most specific testing command, you can lower the amount, but not increase (5 v's is the most v's you can put to see logs).

## Support

If something get's broken message me on - [X](https://x.com/luftjunkie) or message me on discord Luftjunkie#1566

## Related

Here is the web-app if you would like to mint your NFT on the Holesky testnet 😅.

[Webapp](https://github.com/Luftjunkie19/HyperMint)


## Tech Stack

**Programming language:** Solidity

**Framework:** Foundry

**Additional Libraries:** Openzeppelin (For the ERC721 standard import)

