const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env"});
const { CRYPTO_DEVS_NFT_CONTRACT_ADDRESS }  = require("../constants");

let  contractAddress;

const cryptoDevsNFTContract = CRYPTO_DEVS_NFT_CONTRACT_ADDRESS;
async function main() {
// !        Address of the Crypto Dev nft contract here I am using Punk NFt which I made

const cryptoDevsTokenContract = await ethers.getContractFactory("CryptoDevToken");

//  *       Lets deploy the contract 
const deployedCryptoDevsTokenContract = await cryptoDevsTokenContract.deploy(cryptoDevsNFTContract);

// *   print the address of the deployed contract 
console.log("Crypto Devs Token Contract Address: ", deployedCryptoDevsTokenContract.address);


contractAddress = deployedCryptoDevsTokenContract.address;


saveAbi();
saveContractAddress();

}

function saveAbi() {
    const fs = require("fs");
    const abiDir = __dirname + "/../../my-app/constants/";

    if (!fs.existsSync(abiDir)) {
        fs.mkdir(abiDir);
    }

    const artifact = artifacts.readArtifactSync("CryptoDevToken");
    fs.writeFileSync(
        abiDir + "/CryptoDevToken.json",
        JSON.stringify(artifact, null, 2)
    );
}

function saveContractAddress() {
    const fs = require("fs");
    const abiDir = __dirname + "/../../my-app/constants/";

    if (!fs.existsSync(abiDir)) {
        fs.mkdir(abiDir);
    }

    const data = `export const NFT_CONTRACT_ADDRESS = "${cryptoDevsNFTContract}";
    export const TOKEN_CONTRACT_ADDRESS="${contractAddress}"; `;
    fs.writeFileSync(
        abiDir + "/contract.js", data
    );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
      console.error(error);
      process.exit(1);
  });