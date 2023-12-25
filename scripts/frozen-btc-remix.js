const hre = require("hardhat");
const ethers = hre.ethers;
const FrozenBitcoin = require("../artifacts/contracts/nft-fbtc.sol/FBTCDeposit.json");

async function main() {
  const [signer, caller] = await ethers.getSigners();
  const frozenBitcoinAddr = "0x5FbDB2315678afecb367f032d93F642f64180aa3";

  await network.provider.send("hardhat_setBalance", [
    caller.address,
    "0x10000000000000000000000",
  ]);

  const frozenBitcoinContract = new ethers.Contract(
    frozenBitcoinAddr,
    FrozenBitcoin.abi,
    caller
  );

  // console.log("caller", caller);
  console.log("owner", await frozenBitcoinContract.owner());
  console.log("signer", await frozenBitcoinContract.getSigner());
  console.log("teamFunds", await frozenBitcoinContract.teamFunds());

  console.log("rate:", (await frozenBitcoinContract.rate()) / 100, "%");
  price = await frozenBitcoinContract.coinPrice("18695834918402597000");
  console.log("fee:", price.fee / 10 ** 18, "ETH / 1FBTC");
  console.log("depo:", price.depo / 10 ** 18, "ETH / 1FBTC");
  console.log("price:", price.price / 10 ** 18, "ETH / 1FBTC");

  const params = [
// ["18595772122781557000"],["1F6LxhtjaGkkYseh9WKM5BmSfb9yGBpMb6","1Pe3Na7MZB6hVePDsLKse2bWPuTK2Lamej"],["5000000547","5000003282"],["0","0"],["5000000000","5000000000"],[1,2],
["18595772122781557000"],["1Bu3Ex1GoNHFvaoNRzE2FeehyAVtgT47Wg"],["10000000000"],["0"],["5000000000"],["5"],
  ];
  const signature = await getSignature(...params, signer);
  console.log(params);
  console.log("signature:", signature);
}
async function getSignature(v1, v2, v3, v4, v5, v6, signer) {
  let _hash = 0;
  for (let i = 0; i < v2.length; i++) {
    if (i == 0)
      _hash = ethers.utils.solidityKeccak256(
        ["string", "uint256", "uint256", "uint256", "uint256"],
        [v2[i], v3[i], v4[i], v5[i], v6[i]]
      );
    else
      _hash = ethers.utils.solidityKeccak256(
        ["string", "uint256", "uint256", "uint256", "uint256", "bytes32"],
        [v2[i], v3[i], v4[i], v5[i], v6[i], _hash]
      );
  }

  const hash = ethers.utils.solidityKeccak256(
    ["uint256", "bytes32", "address"],
    [v1[0], _hash, signer.address]
  );
  const messageHashBin = ethers.utils.arrayify(hash);
  const signature = await signer.signMessage(messageHashBin);
  //console.log("signature:", signature);
  return signature;
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

  //const { ethers } = require("ethers");
  // const ba = "1Bu3Ex1GoNHFvaoNRzE2FeehyAVtgT47Wg"
  // ethers.utils.keccak256(ethers.utils.toUtf8Bytes(ba))


// ["18695834918402597000"],["1MS2hBF8JqbZM7bPMGCzEcGLFDDuvVGmzT","1Pe3Na7MZB6hVePDsLKse2bWPuTK2Lamej"],["5000000547","5000003282"],["0","0"],["5000000000","5000000000"],["3","4"],0x52c1e7ef295b226a3cebe36926629c25336df4835d2bc0c2a964b3ca269256270b6fa41fd23e7a90f066eff98f51a0ae497fe29246e029cf0a2e4fb12e724b051c
// ["18595772122781557000"],["1F6LxhtjaGkkYseh9WKM5BmSfb9yGBpMb6"],["100000000000"],["0"],["100000000000"],["5"],0xc3429eae1738dfcc59f1c4b598c8f30825ecc517501221531ce7ba05538d39db437514ab2818e33bac0243eeb7a84a0b7390c9fac5ba13ed3404cb0f9b7417c51b
// ["18595772122781557000"],["1Bu3Ex1GoNHFvaoNRzE2FeehyAVtgT47Wg"],["100000000000000"],["0"],["500000000000"],["7"],0x80f57794d6543824c3fd8c6600f5417440bf18d9912ebfd32a90f7097e021d0d2a1d79bc7a77699222f3c97c24012aeabd5b16007ae612767933d7584e430dfc1c
// ["18595772122781557000"],["1F6LxhtjaGkkYseh9WKM5BmSfb9yGBpMb6","1Pe3Na7MZB6hVePDsLKse2bWPuTK2Lamej"],["5000000547","5000003282"],["0","0"],["5000000000","5000000000"],[1,2],0x91f8edff8b89a197c725da22cdf9528336f3efc9a152563d512849c0846205ac559fd61f1251c9957b648ceed1730b4fb8b46e9a192d2e19f0640d8b72da66a71c