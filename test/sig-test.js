const hre = require("hardhat")
const ethers = hre.ethers
const SigTest = require('../artifacts/contracts/sig-test.sol/SigTest.json')

async function main() {
    const [signer, owner, caller] = await ethers.getSigners()
    const sigTestAddr = '0x0B306BF915C4d645ff596e518fAf3F9669b97016'

    const bdeValue = ['14684902682798530000']
    const _btcAddr = ['1KNm4K8GUK8sMoxc2Z3zU8Uv5FDVjrA80p','1KNm4K8GUK8sMoxc2Z3zU8Uv5FDVjrA70p','1KNm4K8GUK8sMoxc2Z3zU8Uv5FDVjrA70p']
    const _balnces = ['100000000000000','100000000000000','10000000000']
    const _sends = ['0','0','5000000000']
    const _unfrozen = ['10000000000','10000000000','5000000000']

    const sigTestContract = new ethers.Contract(
        sigTestAddr,      
        SigTest.abi,
        caller
    )

    const getSig = await sigTestContract.getSigner()
    console.log("Signer = ",getSig)
    console.log("js Signer = ",signer.address)
    console.log("js Owner = ",owner.address)
    console.log("js caller = ",caller.address)

    let _hash  
    for (let i = 0; i < _btcAddr.length; i++) {
        if (i == 0) _hash = ethers.utils.solidityKeccak256(
            ["string", "uint256", "uint256", "uint256"],
            [_btcAddr[i], _balnces[i], _sends[i], _unfrozen[i] ])
        else 
          _hash = ethers.utils.solidityKeccak256(
            ["string", "uint256", "uint256", "uint256", "bytes32"],
            [_btcAddr[i], _balnces[i], _sends[i], _unfrozen[i], _hash])         
       console.log('_hash:',_hash)
    }  
        
    // console.log('hash -->', ethers.utils.solidityKeccak256(
    //   ["string", "bytes32"],
    //   ["\x19Ethereum Signed Message:\n32", hash]
    // ));
    const hash = ethers.utils.solidityKeccak256( ["uint256","bytes32","address"],[ bdeValue[0], _hash, signer.address]);
    console.log('hash=',hash)
    const messageHashBin = ethers.utils.arrayify(hash);
    const signature = await signer.signMessage(messageHashBin);
    console.log('signature:',signature)

    const result = await sigTestContract.claim(bdeValue, _btcAddr, _balnces, _sends, _unfrozen, signature)   

    console.log(result)

}    
    
main()
  .then(()=> process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
    

// call this: 
// npx hardhat run .\scripts\sig-test.js --network localhost  