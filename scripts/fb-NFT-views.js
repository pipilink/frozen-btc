const hre = require("hardhat");
const ethers = hre.ethers;
const FrozenBitcoin = require("../artifacts/contracts/nft-fbtc.sol/FBTCDeposit.json");

let indx = 2;
let cind = 0;
let totalSupply = 0;
let frozenBitcoinContract;
let rate = 0;
let holder;
let frozen;
let PrizeFund;
let PrizeTokens;

async function main() {
  const [signer, ...caller] = await ethers.getSigners();
  const frozenBitcoinAddr = "0x5FbDB2315678afecb367f032d93F642f64180aa3";

  frozenBitcoinContract = new ethers.Contract(
    frozenBitcoinAddr,
    FrozenBitcoin.abi,
    signer
  );

  holder = await frozenBitcoinContract.holders(indx);
  console.log("Holder Info:", indx, holder);
  frozen = await frozenBitcoinContract.frozens(holder.bithash);
  console.log("Frozen Info:", frozen);
  console.log("uri:", await frozenBitcoinContract.tokenURI(indx));

  const bitAddr = await frozenBitcoinContract.bitAddress("1KNm4K8GUK8sMoxc2Z3zU8Uv5ABC100");
  console.log("typeof:",typeof(bitAddr));
  for (key in bitAddr) {  
  console.log("key:",key,":",bitAddr[key]);
  }
 
  console.log("NFT count:",bitAddr["nftCount"]);
  console.log("Bitcoin address balance:",Number(bitAddr["balance"])/10**8,"BTC");
  


  rate = (await frozenBitcoinContract.rate()) / 100;
  console.log("rate:", rate, "%");
  price = await frozenBitcoinContract.coinPrice("15000000000000000000");

  console.log("  fee:", price.fee / 10 ** 18, "ETH / 1FBTC");
  console.log(" depo:", price.depo / 10 ** 18, "ETH / 1FBTC");
  console.log("price:", price.price / 10 ** 18, "ETH / 1FBTC");
  console.log("CALLER   BALANCE:",(await ethers.provider.getBalance(caller[cind].address)) / 10 ** 18, "ETH");
  console.log("OWNER    BALANCE:",(await ethers.provider.getBalance("0xf93Cda5C985933EA3Edb40ddefE3169d3Cb28cBF")) / 10 ** 18, "ETH");
  console.log("CONTRACT BALANCE:",(await ethers.provider.getBalance(frozenBitcoinAddr)) / 10 ** 18);
  
  PrizeFund = await frozenBitcoinContract.prizeFund();
  console.log("PrizeFund:", PrizeFund / 10 ** 18, "ETH");

  PrizeTokens = await frozenBitcoinContract.prizeTokens();
  if (PrizeTokens > 0) {
    console.log("Prize Tokens:", Number(PrizeTokens));
    console.log("Prize by NFT:", PrizeFund / PrizeTokens / 10 ** 18, "ETH");
  }
  const holderNFT = await frozenBitcoinContract.balanceOf(caller[cind].address);
  console.log("Holder NFT balance", Number(holderNFT),"DEPO" );
  console.log("totalMints",(await frozenBitcoinContract.totalMints()) / 10 ** 8, "FBTC");
  console.log("owner", await frozenBitcoinContract.owner());
  console.log("signer", await frozenBitcoinContract.getSigner());

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

/*
npx hardhat node
delete contracts from artifacts,
npx hardhat compile
npx hardhat run .\scripts\deployFBTCD.js --network localhost
npx hardhat run .\scripts\frozen-btc-loop.js --network localhost

Lock with 0.001ETH and deployed to 0x5FbDB2315678afecb367f032d93F642f64180aa3


 ["15000000000000000000"],["1KNm4K8GUK8sMoxc2Z3zU8Uv5ABC"],["1000000000000000"],["0"],["5000000000"],["1"]




Accounts
========

WARNING: These accounts, and their private keys, are publicly known.
Any funds sent to them on Mainnet or any other live network WILL BE LOST.

Account #0: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (10000 ETH)
Private Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

Account #1: 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 (10000 ETH)
Private Key: 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d

Account #2: 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC (10000 ETH)
Private Key: 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a

Account #3: 0x90F79bf6EB2c4f870365E785982E1f101E93b906 (10000 ETH)
Private Key: 0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6

Account #4: 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65 (10000 ETH)
Private Key: 0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a

Account #5: 0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc (10000 ETH)
Private Key: 0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba

Account #6: 0x976EA74026E726554dB657fA54763abd0C3a0aa9 (10000 ETH)
Private Key: 0x92db14e403b83dfe3df233f83dfa3a0d7096f21ca9b0d6d6b8d88b2b4ec1564e

Account #7: 0x14dC79964da2C08b23698B3D3cc7Ca32193d9955 (10000 ETH)
Private Key: 0x4bbbf85ce3377467afe5d46f804f221813b2bb87f24d81f60f1fcdbf7cbf4356

Account #8: 0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f (10000 ETH)
Private Key: 0xdbda1821b80551c9d65939329250298aa3472ba22feea921c0cf5d620ea67b97

Account #9: 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720 (10000 ETH)
Private Key: 0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6

Account #10: 0xBcd4042DE499D14e55001CcbB24a551F3b954096 (10000 ETH)
Private Key: 0xf214f2b2cd398c806f84e317254e0f0b801d0643303237d97a22a48e01628897

Account #11: 0x71bE63f3384f5fb98995898A86B02Fb2426c5788 (10000 ETH)
Private Key: 0x701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82

Account #12: 0xFABB0ac9d68B0B445fB7357272Ff202C5651694a (10000 ETH)
Private Key: 0xa267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1

Account #13: 0x1CBd3b2770909D4e10f157cABC84C7264073C9Ec (10000 ETH)
Private Key: 0x47c99abed3324a2707c28affff1267e45918ec8c3f20b8aa892e8b065d2942dd

Account #14: 0xdF3e18d64BC6A983f673Ab319CCaE4f1a57C7097 (10000 ETH)
Private Key: 0xc526ee95bf44d8fc405a158bb884d9d1238d99f0612e9f33d006bb0789009aaa

Account #15: 0xcd3B766CCDd6AE721141F452C550Ca635964ce71 (10000 ETH)
Private Key: 0x8166f546bab6da521a8369cab06c5d2b9e46670292d85c875ee9ec20e84ffb61

Account #16: 0x2546BcD3c84621e976D8185a91A922aE77ECEc30 (10000 ETH)
Private Key: 0xea6c44ac03bff858b476bba40716402b03e41b8e97e276d1baec7c37d42484a0

Account #17: 0xbDA5747bFD65F08deb54cb465eB87D40e51B197E (10000 ETH)
Private Key: 0x689af8efa8c651a91ad287602527f3af2fe9f6501a7ac4b061667b5a93e037fd

Account #18: 0xdD2FD4581271e230360230F9337D5c0430Bf44C0 (10000 ETH)
Private Key: 0xde9be858da4a475276426320d5e9262ecfc3ba460bfac56360bfa6c4c28b4ee0

Account #19: 0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199 (10000 ETH)
Private Key: 0xdf57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e
*/
/*
  console.log('Holder balance',await fbtcDepositContract.balanceOf("0x70997970C51812dc3A010C7d01b50e0d17dc79C8")/10**8,'FBTC')
  console.log('Holder Fine',await frozenBitcoinContract.fineInfo("0x70997970C51812dc3A010C7d01b50e0d17dc79C8")/10**8,'ETH')
  const holder = await frozenBitcoinContract.holderInfo("0x70997970C51812dc3A010C7d01b50e0d17dc79C8")
  console.log('Holder deposit',holder[0]/10**18,'ETH')
  console.log('CONTRACT BALANCE:',await ethers.provider.getBalance(frozenBitcoinAddr)/10**18, 'ETH')

  console.log('rate:',await frozenBitcoinContract.rate()/100,"%")
  price = await frozenBitcoinContract.coinPrice('15000000000000000000')
  console.log('fee:',price.fee/10**18,"ETH / 1FBTC")
  console.log('depo:',price.depo/10**18,"ETH / 1FBTC")
  console.log('price:',price.price/10**18,"ETH / 1FBTC")

        console.log('owner',await frozenBitcoinContract.owner())
       console.log('signer',await frozenBitcoinContract.getSigner())
     console.log('feeOwner',await frozenBitcoinContract.feeOwner())
  console.log('totalSupply',await frozenBitcoinContract.totalSupply()/10**8)
  console.log('\n')
 */

//console.log(await frozenBitcoinContract.transferFeeOwnership("0xf93Cda5C985933EA3Edb40ddefE3169d3Cb28cBF"))
// random address
// address raddress = address(uint160(uint(keccak256(abi.encodePacked(blockhash(block.timestamp))))));

// npx hardhat run .\scripts\fbtcd-views.js --network localhost