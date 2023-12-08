const hre = require("hardhat");
const ethers = hre.ethers;
const FrozenBitcoin = require("../artifacts/contracts/nft-fbtc.sol/FrozenBitcoin.json");

async function main() {
  const _signer = await ethers.getSigners();
  const frozenBitcoinAddr = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";

  const frozenBitcoinContract = new ethers.Contract(
    frozenBitcoinAddr,
    FrozenBitcoin.abi,
    _signer[1]
  );

  console.log("FBTC ERC20 Contract 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512");
  console.log(
    "Holder balance",
    (await frozenBitcoinContract.balanceOf(
      "0xf93Cda5C985933EA3Edb40ddefE3169d3Cb28cBF"
    )) /
      10 ** 8,
    "FBTC"
  );
  console.log(
    "Owner BALANCE:",
    (await ethers.provider.getBalance(await frozenBitcoinContract.owner())) /
      10 ** 18,
    "ETH"
  );
  console.log(
    "NFT CONTRACT BALANCE:",
    (await ethers.provider.getBalance(
      "0x5FbDB2315678afecb367f032d93F642f64180aa3"
    )) /
      10 ** 18,
    "ETH"
  );
  console.log("owner", await frozenBitcoinContract.owner());
  console.log(
    "totalSupply",
    (await frozenBitcoinContract.totalSupply()) / 10 ** 8,
    "FBTC"
  );
  console.log("\n");

  // const frozenBitcoinAddr = '0x5FbDB2315678afecb367f032d93F642f64180aa3'
  //console.log(await frozenBitcoinContract.transferFeeOwnership("0xf93Cda5C985933EA3Edb40ddefE3169d3Cb28cBF"))
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

// random address
// address raddress = address(uint160(uint(keccak256(abi.encodePacked(blockhash(block.timestamp))))));

// npx hardhat run .\scripts\fb-views.js --network localhost
