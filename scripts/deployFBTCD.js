// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const ethers = hre.ethers 

async function main() {

  const lockedAmount = hre.ethers.utils.parseEther("0.01");

  const FBTCDeposit = await hre.ethers.getContractFactory("FBTCDeposit");
  const fbtcDeposit = await FBTCDeposit.deploy();

  await fbtcDeposit.deployed();

  console.log(
    `Lock with ${ethers.utils.formatEther(
      lockedAmount
    )}ETH and deployed FBTCDeposit to ${fbtcDeposit.address}`
  );

  const FrozenBitcoin = await hre.ethers.getContractFactory("FrozenBitcoin");
  const frozenBitcoin = await FrozenBitcoin.deploy();

  await frozenBitcoin.deployed();

  console.log(
    `Lock with ${ethers.utils.formatEther(
      lockedAmount
    )}ETH and deployed frozenBitcoin to ${frozenBitcoin.address}`
  );

  await frozenBitcoin.setERC721Contract(fbtcDeposit.address);
  await fbtcDeposit.setERC20Contract(frozenBitcoin.address);
  console.log(await fbtcDeposit.setBaseURL("https://ipfs.io/ipfs/QmZcH4YvBVVRJtdn4RdbaqgspFU8gH6P9vomDpBVpAL3u4/"));
  // await fbtcDeposit.setOwner("0xf93Cda5C985933EA3Edb40ddefE3169d3Cb28cBF");
  
  console.log("ERC721 NFT Contract is",await frozenBitcoin.ERC721Contract());
  console.log("ERC20 Token Contract is",await fbtcDeposit.ERC20Contract())
  
  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});


// npx hardhat run .\scripts\deployFBTCD.js --network localhost