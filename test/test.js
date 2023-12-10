// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {

  const lockedAmount = hre.ethers.utils.parseEther("0.001");

  const Callee = await hre.ethers.getContractFactory("Callee");
  const callee = await Callee.deploy();
  await callee.deployed();

  const Caller = await hre.ethers.getContractFactory("Caller");
  const caller = await Caller.deploy();
  await caller.deployed();


  console.log(
    `Lock with ${ethers.utils.formatEther(
      lockedAmount
    )}ETH and Callee deployed to ${callee.address}`
  );

  console.log(
    `Lock with ${ethers.utils.formatEther(
      lockedAmount
    )}ETH and Caller deployed to ${caller.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});



//  92913436599,
//    929134365999373,
//    929227279435972