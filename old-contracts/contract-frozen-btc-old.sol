// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FrozenBitcoinOLD is ERC20 {

    struct Holder {
        uint256 assets; // holded funds wei
        uint256 duration; // hold duration
    }

    struct Share {
        bytes32 bitaddr; // bitcoin address hash
        uint256 assets; // holded funds wei
        uint256 duration; // hold duration
        uint256 fines; // arbirtrage fines;
        bool arbitrage; // arbitrage now?
    }

    struct Funder {
        uint256 hold; // Total hold assets
        uint256 paid; // Total Paid
        Share[] shares;
    }

    // Bitcoin account
    struct FrozenBTC {
        uint256 balance; // Bitcoin addr balance
        uint256 sends; // Bitcoin addr sends
        uint256 unfrozen; // Bitcoin unfroze count
        bool isCompromised; // will be true when any send from a bitcoin address before the deposit expires
        address[] btcOwners; // Bitcoin owners. may be more one
    }

    struct CoinPrice {
        uint256 fee;
        uint256 depo;
        uint256 price;
    }

    event Received(address indexed, uint256);
    event SendReturns(address indexed, uint256);
    event SendFee(address indexed, uint256);
    event WithDraw(address indexed, uint256);
    event TeamIncome(address indexed, uint256);
    event Unfrozen(bytes32, string, uint256, uint256, uint256); //, FrozenBTC);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event FeeOwnershipTransferred(
        address indexed previousFeeOwner,
        address indexed newFeeOwner
    );
    
    event SignershipTransferred(
        address indexed previouSigner,
        address indexed newSigner
    );

    constructor() ERC20("Frozen Bitcoin", "FBTC") {
        _owner = msg.sender;
        _signer = msg.sender;
        //_feeOwner = payable(msg.sender);
        _feeOwner = payable(0xf93Cda5C985933EA3Edb40ddefE3169d3Cb28cBF);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    modifier onlyFeeOwner() {
        _checkFeeOwner();
        _;
    }

    address private _signer;
    address private _owner;
    address payable private _feeOwner;

    uint256 public teamFunds; // charge +5% from totalMint
    uint256 public totalMints;

    Share _shr;
    Funder _funder;
    
    Holder _holder;
    mapping(address => Holder) public holders;

    mapping(bytes32 => FrozenBTC) public frozens;
    mapping(address => Funder) public funders;

    function owner() public view returns (address) {
        return _owner;
    }

    function feeOwner() public view returns (address) {
        return _feeOwner;
    }

    function getSigner() public view returns (address) {
        return _signer;
    }

    function _checkOwner() internal view {
        require(owner() == msg.sender, "Caller is not the owner");
    }

    function _checkFeeOwner() internal view {
        require(feeOwner() == msg.sender, "Caller is not the feeOwner");
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New Owner is the zero address");
        _transferOwnership(newOwner);
    }

    function transferSignership(address newSigner) public onlyOwner {
        require(newSigner != address(0), "New Signer is the zero address");
        _transferSignership(newSigner);
    }

    function transferFeeOwnership(address newFeeOwner) public onlyOwner {
        require(newFeeOwner != address(0), "New feeOwner is the zero address");
        _transferFeeOwnership(payable(newFeeOwner));
    }

    function _transferOwnership(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function _transferSignership(address newSigner) internal {
        address oldSigner = _signer;
        _signer = newSigner;
        emit SignershipTransferred(oldSigner, newSigner);             
    }

    function _transferFeeOwnership(address payable newFeeOwner) internal {
        address oldFeeOwner = _feeOwner;
        _feeOwner = newFeeOwner;
        emit FeeOwnershipTransferred(oldFeeOwner, newFeeOwner);
    }

    function getHash(string memory s) internal pure returns (bytes32 ret) {
        return keccak256(bytes(s));
    }

    function unfrozen(
        uint256[] memory bdeValue,
        string[] memory _btcAddr,
        uint256[] memory _balances,
        uint256[] memory _sends,
        uint256[] memory _unfrozen,
        bytes memory signature
    ) external payable {
        require(msg.value > 0, "Payment value must be > 0 ETH");
        require(
            _btcAddr.length == _balances.length &&
                _balances.length == _sends.length &&
                _sends.length == _unfrozen.length,
            "Arrays Lehgth not egual"
        );

        uint256 coinForMint;
        uint256 EthValue;
        uint256 _fees;
        CoinPrice memory cp;
        bytes32 _btc;

        bytes32 _hash;
       
            for (uint8 i = 0; i < _btcAddr.length; i++) {
                if (i == 0) _hash = keccak256(abi.encodePacked(_btcAddr[i], _balances[i], _sends[i], _unfrozen[i]));               
                else _hash = keccak256(abi.encodePacked(_btcAddr[i], _balances[i], _sends[i], _unfrozen[i], _hash));                                        
            }

        bytes32 message = withPrefix(keccak256(abi.encodePacked(bdeValue[0], _hash, _signer)));       

        require(
            recoverSigner(message, signature) == _signer, "invalid Signer!"
        );

//        _funder = funders[msg.sender];
          _holder = holders[msg.sender];

        cp = coinPrice(bdeValue[0]);
        require(cp.price > 0, "CoinPrice == 0");

        for (uint8 i = 0; i < _btcAddr.length; i++) {
            require(_balances[i] > 0, "Bitcoin Address Balance = 0 BTC");
            require(_unfrozen[i] > 0, "Unfrozen value must be > 0 BTC");
            require(_unfrozen[i] <= _balances[i],"Unfrozen value must by <= Bitcoin addres balance");

//            _btc = getHash(_btcAddr[i]);
//            _shr.bitaddr = _btc;
//            _shr.assets = (_unfrozen[i] * cp.depo) / 10 ** decimals(); // -- fee ( расчет fee )
//            _shr.duration = block.timestamp + 1 days * 365; // May be via storage parameters?
//            _funder.hold += _shr.assets;
            _holder.assets += (_unfrozen[i] * cp.depo) / 10 ** decimals();
            _holder.duration = block.timestamp + 1 days * 365;  
            totalMints += _unfrozen[i];
            _fees += (_unfrozen[i] * cp.fee) / 10 ** decimals();
            EthValue += (_unfrozen[i] * cp.price) / 10 ** decimals();
            coinForMint += _unfrozen[i];
/*
            if (frozens[_btc].balance == 0) {
                frozens[_btc].balance = _balances[i];
                frozens[_btc].sends = _sends[i];
                frozens[_btc].unfrozen = _unfrozen[i];
                frozens[_btc].btcOwners.push(msg.sender);
            } else {
                require(frozens[_btc].unfrozen + _unfrozen[i] <= frozens[_btc].balance,
                    "The amount of unfrozen funds must be less than or equal to the bitcoin address balance"
                );
                require(!getFOwner(_btc),
                    "Owner for this Bitcoin address alredy exist"
                );
                frozens[_btc].unfrozen += _unfrozen[i];
                frozens[_btc].btcOwners.push(msg.sender);
            }
            _funder.shares.push(_shr);
*/

            emit Unfrozen(
                _btc,
                _btcAddr[i],
                _balances[i],
                _sends[i],
                _unfrozen[i] //,
                // frozens[_btc]
            );
        }
        

        require(coinForMint <= 500*10**8, "You cannot issue more than 500 FBTC tokens in one transaction");

//        funders[msg.sender] = _funder;
        holders[msg.sender] = _holder;
        _mint(msg.sender, coinForMint);
        
        
        require(msg.value >= EthValue, "Insufficient funds to pay");

        if (msg.value > EthValue) {
            address payable retAddr = payable(msg.sender);
            retAddr.transfer(msg.value - EthValue);
            emit SendReturns(retAddr, msg.value - EthValue);
            delete retAddr;
        }

        if (_fees > 0) {
            _feeOwner.transfer(_fees);
            emit SendFee(feeOwner(), _fees);
        }
        emit Received(msg.sender, msg.value);
    }

    function frozenInfo(bytes32 _btc) internal view returns (FrozenBTC memory) {
        return frozens[_btc];
    }

    function bitcoinInfo(
        string calldata btcAddress
    ) public view returns (FrozenBTC memory) {
        bytes32 _hash;
        _hash = getHash(btcAddress);
        return frozens[_hash];
    }

    function funderInfo(address _addr) public view returns (Funder memory) {
        return funders[_addr];
    }

    function getFOwner(bytes32 _btc) internal view returns (bool exist) {
        address[] memory owners;
        owners = frozens[_btc].btcOwners;

        for (uint8 i = 0; i < owners.length; i++) {
            if (owners[i] == msg.sender) return true;
        }
        return false;
    }

    function coinPrice(uint cRate) public view returns (CoinPrice memory) {
        CoinPrice memory cp;
        uint256 currentRate;
        currentRate = rate();
        cp.depo = (cRate * currentRate) / 20000;
        cp.fee = (cp.depo * currentRate) / 10000;
        cp.price = cp.depo + cp.fee;
        return (cp);
    }

    function rate() public view returns (uint) {
        uint _count = totalMints / 10 ** decimals();
        if (_count == 0) return uint(1);
        if (_count >= 5000000) return uint(10000);
        return (_count / 500 + 1);
    }

    function withDraw() external payable {
        Funder storage holder;
        uint256 delay = uint(block.timestamp);
        uint256 amount;
        holder = funders[msg.sender];

        for (uint8 i = 0; i < holder.shares.length; i++) {
            if (
                !holder.shares[i].arbitrage && delay > holder.shares[i].duration
            ) {
                amount += holder.shares[i].assets;
                holder.shares[i].assets = 0;
            }
        }

        require(
            holder.hold - holder.paid > 0 && amount > 0,
            "No holder assets for return now"
        );
        holder.paid += amount;
        address payable holderAddr = payable(msg.sender);
        holderAddr.transfer(amount);
        emit WithDraw(holderAddr, amount);
    }

    function withDrawdShow(address addr) external view returns (uint256) {
        Funder memory holder;
        holder = funders[addr];
        uint256 delay = uint(block.timestamp);
        uint256 showAmount;

        for (uint8 i = 0; i < holder.shares.length; i++) {
            if (
                !holder.shares[i].arbitrage && delay > holder.shares[i].duration
            ) showAmount += holder.shares[i].assets;
        }
        if ((holder.hold - holder.paid) > 0 && showAmount > 0) {
            return (showAmount);
        } else return 0;
    }

    function getIncome() external onlyFeeOwner {
        uint256 income = (totalMints * 5) / 100 - teamFunds;
        require(income >= 20, "Team Income < 20 FBTC");
        teamFunds += income;
        _mint(_feeOwner, income);
        emit TeamIncome(_feeOwner, income);
    }

    function decimals() public view virtual override returns (uint8) {
        return 8;
    }
    function recoverSigner(bytes32 message, bytes memory signature) private pure returns(address) {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);
        return ecrecover(message, v, r, s);
    }

    function splitSignature(bytes memory signature) private pure returns(uint8 v, bytes32 r, bytes32 s) {
        require(signature.length == 65);

        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
        return(v, r, s);
    }

    function withPrefix(bytes32 _hash) private pure returns(bytes32) {
        return keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                _hash
            )
        );
    }
}

// https://www.alchemy.com/gwei-calculator
//     1000000000000000 wei
//           5000000000 wei
// 0.002000005000001011 ETH

// 15000000000000000000,[ab,cd,ef,gh,ij,kl,mn,op,qr,st],[50,50,50,50,50,50,50,50,50,50],[0,0,0,0,0,0,0,0,0,0],[1,2,3,4,5,6,7,8,9,10]
// 15000000000000000000,[ab,cd,ef,gh,ij,kl,mn],[50,50,50,50,50,50,50],[0,0,0,0,0,0,0],[1,2,3,4,5,6,7]
// 15000000000000000000,[ab1,cd1,ef1,gh1,ij1,kl1,mn1,op1,qr1,st1],[50,50,50,50,50,50,50,50,50,50],[0,0,0,0,0,0,0,0,0,0],[1,2,3,4,5,6,7,8,9,10]

// [1KNm4K8GUK8sMoxc2Z3zU8Uv5FDVjrA72p],[947314073223],[1446585469678633],[100000000000]
// 15000000000000000000,[1KNm4K8GUK8sMoxc2Z3zU8Uv5FDVjrA82p],[100000000000000],[0],[10000000000000]
// 15000000000000000000,[1KNm4K8GUK8sMoxc2Z3zU8Uv5FDVjrA62p],[100000000000000],[0],[50000000000]
// 15000000000000000000,[1KNm4K8GUK8sMoxc2Z3zU8Uv5FDVjrA63p],[1000000000],[0],[1000000000]
// 14684902682798530000,[1KNm4K8GUK8sMoxc2Z3zU8Uv5FDVjrA74p],[100000000000000],[0],[500000000000]
// 14684902682798530000,[1KNm4K8GUK8sMoxc2Z3zU8Uv5FDVjrA92p],[1000000000000],[0],[10]

// 14459935897435900000,[13A1W4jLPP75pzvn2qJ5KyyqG3qPSpb9jM],[5004736427],[0],[2504736427]
/*
"0": "tuple(uint256,uint256,uint256,bool,address[]): 
100000000000000,0,2850000000000,false,
    0x0a44Bda4EB1955A252adb50879bB3B86a0c8CF7F,
    0xA3d66558D5F6108eDe9E7E7f953210B037887992,
    0xd49a989580Fb07fd041407505eaCf5AA7dC4CEB6,
    0x6C30101165cB48Cbf2f96142812bC365d0718796,
    0x9BcA45Bb66972A0B7068bB9cBf973014D1b5Ae9C
"

tuple(uint256,uint256,tuple(bytes32,uint256,uint256,uint256,bool)[]): 
3828725670699630000,
3671225670699630000,
 157500000000000000
0x34a7739724a99a4c25ac750475cc5b1347914ccd1a27bc5be422670cc5b13ad9,0,1685371362,0,false,
0xe50d70e723aced6dc6f60944008fbe56f24c32676d2a1c5be18280b0de62edf0,157500000000000000,1685371543,0,false
*/
