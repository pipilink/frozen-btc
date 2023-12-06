// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FrozenBitcoin is ERC20 {

    constructor() ERC20("Frozen Bitcoin", "FBTC") {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Caller is not the owner");
        _;
    }
    
    modifier onlyERC721Contract() {
        require(ERC721Contract() == msg.sender, "Caller is not the NFT Contract");
        _;
    }

    address private _owner;
    address private _ERC721Contract;

    function owner() public view returns (address) {
        return _owner;
    }

    function ERC721Contract() public view returns (address) {
        return _ERC721Contract;
    }

    function setOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New Owner is the zero address");
        _owner = newOwner;
    }

    function setERC721Contract(address newAddr) public onlyOwner {
        require(newAddr != address(0), "New NFT Contract address is the zero address");
        _ERC721Contract = newAddr;
    }

    function decimals() public view virtual override returns (uint8) {
        return 8;
    }
    
    function mint(address _to, uint256 amount) public onlyERC721Contract {
        require(_to != address(0), "Receiver address is the zero address");
        require(amount >= 0, "Receiver fund must be > 0");
        
        _mint(_to, amount);
    }
}

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

/// @custom:security-contact support@fbtc.io
contract FBTCDeposit is ERC721, ERC721Burnable {
    constructor() ERC721("FBTC bill of exchange", "DEPO") {
        _owner = payable(msg.sender);
        _signer = msg.sender;
    }

    function _baseURI() internal view override returns (string memory) {
        return string(_baseURL); 
    }

    struct Holder {       // Holder struct
        uint256 assets;   // Holded funds in wei
        uint256 duration; // Hold duration
        bytes32 bithash;  // Bitcoin address hash
    }
    
    struct FrozenBTC {    // Bitcoin address struct
        uint256 balance;  // Bitcoin address balance
        uint256 sent;     // Bitcoin address total sent
        uint256 deposit;  // Bitcoin address unfroze amount
        bool blackList;   // will be true when any send from a bitcoin address before the deposit expires
        uint256 withdraw; // TokenId Withdraw amount
        uint16 nftCount;  // Counts NFT tokens issue for this bitcoin address
        string tRx;       // Compromising transaction from an unfrozen bitcoin address
    }

    struct CoinPrice {    // Current price new FBTC tokens
        uint256 fee;      // Non-refundable commission
        uint256 depo;     // Refundable deposit
        uint256 price;    // price = fee + depo;
    }

    event Received(address indexed, uint256);
    event SendReturns(address indexed, uint256);
    event SendFee(address indexed, uint256);
    event WithDraw(address indexed, uint256);
    
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    modifier onlySigner() {
        _checkSigner();
        _;
    }
    
    address payable private _owner; // project owner address
    address private _signer;        // web3 proof data signer
    address private _ERC20Contract; // ERC20 contract address (for mint FBTC tokens from this contract)

    string private _baseURL;        // ipfs base uri
    uint256 public teamFunds;       // charge +5% from totalMints
    uint256 public totalMints;      // FBTC tokens minted
    uint256 public prizeFund;       // incentive fund
    uint256 public prizeTokens;     // NFT count in incentive fund

    mapping(uint256 => Holder) public holders;    // map of NFT holders
    mapping(bytes32 => FrozenBTC) public frozens; // map of bitcoin address

    function owner() public view returns (address) {
        return _owner;
    }

    function getSigner() public view returns (address) {
        return _signer;
    }

    function ERC20Contract() public view returns (address) {
        return _ERC20Contract;
    }

    function _checkOwner() internal view {
        require(owner() == msg.sender, "Caller is not the owner");
    }

    function _checkSigner() internal view {
        require(getSigner() == msg.sender, "Caller is not the signer");
    }

    function setOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = payable(newOwner);
    }

    function setSigner(address newSigner) public onlyOwner {
        require(newSigner != address(0));
        _signer = newSigner;
    }

    function setERC20Contract(address newERC20Contract) public onlyOwner {
        require(newERC20Contract != address(0));
        _ERC20Contract = newERC20Contract;
    }

    function setBaseURL(string memory newBaseURL) public onlyOwner {
        _baseURL = newBaseURL;
    }

    function unfrozen( 
            uint256[] memory bdeValue,   // Inpotant data! CoinMarketCap last price in wei: BTC/ETH  ~15 ETH/1 BTC 
             string[] memory _btcAddr,   // Bitcoin address array 
            uint256[] memory _balances,  // Bitcoin address balance array 
            uint256[] memory _sent,      // Bitcoin address total sent array 
            uint256[] memory _unfrozen,  // Bitcoin address unforzen amount array  
            uint256[] memory _nft,       // NFT TokenId array
                bytes memory signature   // Signer signature of all input parameters  
        ) external payable {

        require(msg.value > 0, "Pay must be > 0");
        uint256 coinForMint;
        uint256 EthValue;
        uint256 _fees;
        CoinPrice memory cp;
        bytes32 _hash;
        Holder memory _holder;
        FrozenBTC memory _frozen;

        for (uint8 i = 0; i < _btcAddr.length; i++) {
            if (i == 0) _hash = keccak256(abi.encodePacked(_btcAddr[i], _balances[i], _sent[i], _unfrozen[i], _nft[i]));               
            else _hash = keccak256(abi.encodePacked(_btcAddr[i], _balances[i], _sent[i], _unfrozen[i], _nft[i], _hash));                                        
        }

        bytes32 message = withPrefix(keccak256(abi.encodePacked(bdeValue[0], _hash, _signer)));       
        require(recoverSigner(message, signature) != _signer, "invalid Signer!");

        cp = coinPrice(bdeValue[0]);
        require(cp.price > 0, "Maximum issue reached tokens!");

        for (uint8 i = 0; i < _btcAddr.length; i++) {
            require(_balances[i] > 0);
            require(_unfrozen[i] > 0);
            require(_unfrozen[i] <= _balances[i],"Unfrozen value > BitAddr balance");
            
            _hash = getHash(_btcAddr[i]);
            _frozen = frozens[_hash];

            require(!_frozen.blackList, "Bitcoin address has been blacklisted");
            _frozen.balance = _balances[i];
            _frozen.sent = _sent[i];            
            _frozen.deposit += _unfrozen[i];
            _frozen.nftCount++;

            require(_frozen.deposit <= _frozen.balance,"No assets for unfrozen");  

            _holder = holders[_nft[i]];
            _holder.assets = _unfrozen[i] * cp.depo / 10 ** decimals();
            totalMints += _unfrozen[i];

                _fees += (_unfrozen[i] * cp.fee / 2) / 10 ** decimals();
            prizeFund += (_unfrozen[i] * cp.fee / 2) / 10 ** decimals();

            if ((_unfrozen[i] * cp.depo) / 10 ** decimals() >= 100000000000000000)
                prizeTokens++;

            EthValue += (_unfrozen[i] * cp.price) / 10 ** decimals();
            coinForMint += _unfrozen[i];
            _safeMint(msg.sender, _nft[i]);
            require(coinForMint <= 5000*10**decimals(), "You cannot issue more 5000 FBTC tokens in one trx");
            _holder.duration = block.timestamp;// + 1 days * 365;  
            _holder.bithash = _hash;
            holders[_nft[i]] = _holder;
            frozens[_hash] = _frozen;
        }

        // Call FrozenBitcoin contract and mint FBTC tokens for sender
        FrozenBitcoin fbtc = FrozenBitcoin(ERC20Contract());
        fbtc.mint(msg.sender, coinForMint);

        require(msg.value >= EthValue, "Insufficient funds to pay");
        emit Received(msg.sender, msg.value);

        if (msg.value > EthValue) {
            address payable retAddr = payable(msg.sender);
            retAddr.transfer(msg.value - EthValue);
            emit SendReturns(retAddr, msg.value - EthValue);
            delete retAddr;
        }

        if (_fees > 0) {
            _owner.transfer(_fees);
            emit SendFee(_owner, _fees);            
        }        
    }

    function bitAddress(string memory _bitAddr) public view returns (FrozenBTC memory) {
        return frozens[getHash(_bitAddr)];
    }

    function coinPrice(uint cRate) public view returns (CoinPrice memory) {
        CoinPrice memory cp;
        uint currentRate;
        currentRate = rate();
        cp.depo = (cRate * currentRate) / 20000;
        cp.fee = (cp.depo * currentRate) / 10000;
        cp.price = cp.depo + cp.fee;
        return (cp);
    }

    function rate() public view returns (uint) {
        uint _count = totalMints / 10 ** decimals();
        if (_count == 0) return uint(1);
        if (_count > 5000000) return uint(0);
        return (_count / 500 + 1);
    }

    function withDraw(uint256 tokenId) external {
        _burn(tokenId);
    }    

    function _burn(uint256 tokenId) internal override(ERC721) {
        Holder memory holder;
        FrozenBTC memory _frozen;

        uint256 delay = uint(block.timestamp);
        uint256 amount;
        uint256 prize;

        address payable holderAddr = payable(ownerOf(tokenId));
        require(holderAddr == msg.sender, "You are not owner of this token");

        holder = holders[tokenId];
        require( holder.assets > 0 && delay > holder.duration, "No holder assets for return now");
        require( !inStopList(holder.bithash), "Bitcoin address has been blacklisted");

        _frozen = frozens[holder.bithash];
        _frozen.withdraw += holder.assets;
        _frozen.nftCount--;
        frozens[holder.bithash] = _frozen;

        amount = holder.assets;
        holder.assets = 0;
        holders[tokenId] = holder;

        if (amount >= 100000000000000000 && prizeFund > 0 && prizeTokens > 0) {
            prize = prizeFund/prizeTokens;
            prizeFund -= prize;
            amount += prize;
            prizeTokens--;
        }    

        holderAddr.transfer(amount);
        super._burn(tokenId);
        emit WithDraw(holderAddr, amount);        
    }

    function getIncome() external onlyOwner {
        uint256 income = (totalMints * 5) / 100 - teamFunds;
        require(income >= 20, "Team Income < 20 FBTC");
        teamFunds += income;

        // Call FrozenBitcoin contract and mint FBTC tokens for sender
        FrozenBitcoin fbtc = FrozenBitcoin(ERC20Contract());
        fbtc.mint(owner(), income);
    }

    function decimals() private pure returns (uint8) {
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

    function getHash(string memory s) internal pure returns (bytes32 ret) {
        return keccak256(bytes(s));
    }

    function inStopList(bytes32 _btc) internal view returns (bool ret) {
        return (frozens[_btc].blackList);
    }

    function setBlackList(string memory _bitAddr, string memory _trx) public onlySigner {
        bytes32  _hash = getHash(_bitAddr);
        require(!frozens[_hash].blackList && frozens[_hash].balance > 0, "Address alredy in black list");
        frozens[_hash].tRx = _trx;
        frozens[_hash].blackList = true;
        prizeFund += (frozens[_hash].deposit-frozens[_hash].withdraw);
        if (prizeTokens > frozens[_hash].nftCount) 
            prizeTokens -= frozens[_hash].nftCount;
    }
}