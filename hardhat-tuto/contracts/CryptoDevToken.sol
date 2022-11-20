// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";

contract CryptoDevToken is ERC20, Ownable {
    // Price of 1 CryptoDev token
    uint256 public constant tokenPrice = 0.001 ether;
    // Each NFT would give the user 10 tokens
    // It needs to be represented as 10 * (10**18) as ERC20 tokens are represented by the smallest denomination possible for the token
    // By default, ERC20 tokens have the smallest denomination of 10(-18)
    // This means a balance of (1) = (10 ^ -18) tokens
    // Owning 1 full token is equivalent to owning (10^18) tokens when accounting for decimal places.
    // More information on this can be found in the Freshman Track Cryptocurrency tutorial.
    uint256 public constant tokensPerNFT = 10 * (10**18);
    // The max total supply is 10000 for Crypto Dev Tokens
    uint256 public constant maxTotalSupply = 10000 * 10**18;
    // CryptoDevsNFT contract instance
    ICryptoDevs CryptoDevsNFT;
    // Mapping to keep track of which tokenIds have been claimed
    mapping (uint256=>bool) public tokenIdsClaimed;

    constructor (address _cryptoDevsContract) ERC20("Crypto Dev Token", "CDT") {
        CryptoDevsNFT = ICryptoDevs(_cryptoDevsContract);
    }

    /**
     * @dev Mints 'amount` number of CryptoDevTokens
     * Requirements:
     * - `msg.value` should be equal or greater than the tokenPrice * amount
     */
     function mint(uint256 amount) public payable {
        // the value of ether that should be equal or greater than the tokenPrice * amount
        uint256 _requiredAmount = tokenPrice * amount;
        require(msg.value >= _requiredAmount, "Ether sent is incorrect");
        uint256 amountWithDecimals = amount * 10**18;
        require((totalSupply() + amountWithDecimals) < maxTotalSupply, "Exceeds the max supply available");
        // call the internal function from Openzeppeelin's ERC20 contract
        _mint(msg.sender, amountWithDecimals);
     }

     /**
      * @dev Mints token based on the number of NFT's held by the sender
      * Requirements:
      * balance of Crypto Dev NFT's owned by the sender should be greater than 0
      * Tokens should have not been claimed for all the NFTs owned by the sender
      */
      function claim() public {
        address sender = msg.sender;
        // Get the number of CryptoDev NFT's held by a given sender
        uint256 balance = CryptoDevsNFT.balanceOf(sender);
        // If the balance is 0, revert the transaction
        require(balance > 0, "You don't own any Crypto Dev NFTs");
        // amount keeps track of the number of unclaimed tokenIds
        uint256 amount = 0;
        // loop over the balance and get the token ID owned by the `sender` at a given `index` of its token list
        for (uint256 index = 0; index < balance; index++) {
            uint256 tokenId = CryptoDevsNFT.tokenOfOwnerByIndex(sender, index);
            // if the tokenId has not been claimed, increase the amount
            if(!tokenIdsClaimed[tokenId]) {
                amount+= 1;
                tokenIdsClaimed[tokenId] = true;
            }
        }
        // If all the tokenIds have been claimed, revert the transaction
        require(amount > 0, "You have claimed all the tokens!");
        // call the internal function from Openzeppeelin's ERC20 contract
        // mint (amount*10) tokens for each NFT
        _mint(msg.sender, amount * tokensPerNFT);
      }

      /**
         * @dev withdraws all ETH and tokens sennt to the contract
         * Requirements:
         * wallet connected must be owner's address
         */
         function withdraw() public onlyOwner {
            address _owner = owner();
            uint256 amount = address(this).balance;
            (bool sent, ) = _owner.call{value:amount}("");
            require(sent, "Failed to send Ether");
         }

      // Function to receive Ether. msg.data must be empty
      receive() external payable {}

      // Fallback function is called when msg.data is not empty
      fallback() external payable {}
}