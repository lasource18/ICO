const { ethers } = require('hardhat')
require("dotenv").config({ path: ".env" })
const { CRYPTO_DEVS_NFT_CONTRACT_ADDRESS } = require('../constants')

async function main() {
  // address of the Crypto Devs NFT contract that you deployed in the previous modle
  const cryptoDevsNFTContract = CRYPTO_DEVS_NFT_CONTRACT_ADDRESS

   /*
    A ContractFactory in ethers.js is an abstraction used to deploy new smart contracts,
    so cryptoDevsTokenContract here is a factory for instances of our CryptoDevToken contract.
    */
  const cryptoDevsTokenContract = await ethers.getContractFactory('CryptoDevToken')

  // here we deploy the contract
  // maximun number of whitelisted addresses
  const deployedcryptoDevsTokenContract = await cryptoDevsTokenContract.deploy(cryptoDevsNFTContract)

  await deployedcryptoDevsTokenContract.deployed()

  console.log("Crypto Devs Token Contract Address:", deployedcryptoDevsTokenContract.address)
}

main()
  .then(() => process.exit(0))
  .catch((e) => {
    console.error(e)
    process.exit(1)
  })