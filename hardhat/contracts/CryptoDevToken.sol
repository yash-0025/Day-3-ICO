// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";

contract CryptoDevToken is ERC20, Ownable {
//  Declaring price of the one Token
uint256 public constant tokenPrice = 0.01 ether;
//  Each NFT will give 10 token to the user
//  It can be represented as 10 * (10**18) 
uint256 public constant tokensPerNFT = 10 * 10**8;
// We will declare the  max supply of the tokens 
uint256 public constant maxTotalSupply = 1000 * 10**18;
//  CryptoDevs NFt contract instance
ICryptoDevs CryptoDevsNFT;
// mapping to keep the track of which token is claimed
mapping(uint256 => bool) public tokenIdsClaimed;

constructor(address _cryptoDevsContract) ERC20("Crypto Dev Token", "CDT") {
    CryptoDevsNFT = ICryptoDevs(_cryptoDevsContract);
}


// Lets declare the mint function 
function mint(uint256 amount) public payable {
    // The value which is send should be greater than tokenPrice * amount
    uint256 _requiredAmount = tokenPrice * amount;
    require(msg.value >= _requiredAmount, "Ether sent is not enough");
    // if total tokens + amount <= 10000 then revert the transaction
    uint256 amountWithDecimals = amount * 10**18;
    require((
        totalSupply() + amountWithDecimals) <= maxTotalSupply, "Exceeds the max total supply.");
    // Now call the internal function from openzeppelin ERC20 contract
    _mint(msg.sender, amountWithDecimals);
}


// Mint Token according to the NFT held by the sender
// Requirement should be
// balance of Crypto Dev NFTs owned by the sender should be greater than 0
// tokens should have not been claimed for all the NFT owned by the sender

function claim() public {
    address sender = msg.sender;
//  Lets get the total number of Crypto Dev NFT hold by the sender using given address
uint256 balance = CryptoDevsNFT.balanceOf(sender);
// If the balance is 0 than revert the transaction
require(balance > 0, "You didn't hold any Crypto Dev NFT");
// We will require something to track number of unclaimed Tokens so
uint256 amount = 0;
//  We have to create a loop which will loop over the balance and get the token Id owned by the sender at a given Index of its token list
for (uint256 i=0; i<balance; i++) {
    uint256 tokenId = CryptoDevsNFT.tokenOfOwnerByIndex(sender, i);
    // If the token id is not claimed increase the amount
    if (!tokenIdsClaimed[tokenId]) {
        amount +=1;
        tokenIdsClaimed[tokenId] = true;
    }
}
//  If all the token Ids have been claimed then revert the transaction
require(amount > 0, "You have already claimed all the tokens");
// Call the internal function from Openzeppelins ERC20 contract
// Mint (amount*10) tokens for each NFt
_mint(msg.sender, amount * tokensPerNFT);
}
// When msg.data is empty this function will help to receive ether
receive() external payable {}
// When msg.data is not empty FAllback function is called when no function is calling in the contract
fallback() external payable {}

}