// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract SigTest {
    address private _signer;
    
    constructor()  {
        _signer = msg.sender;
    }
    
    function getSigner() public view returns (address) {
        return _signer;
    }

    function claim(
        uint256[] memory bdeValue,
        string[] calldata _btcAddr,
        uint256[] calldata _balances,
        uint256[] calldata _sends,
        uint256[] calldata _unfrozen,
        bytes memory signature) public view {

        bytes32 _hash;
       
            for (uint8 i = 0; i < _btcAddr.length; i++) {
                if (i == 0) _hash = keccak256(abi.encodePacked( _btcAddr[i], _balances[i],_sends[i],_unfrozen[i]));               
                else _hash = keccak256(abi.encodePacked( _btcAddr[i], _balances[i],_sends[i],_unfrozen[i], _hash));                                        
            }

        bytes32 message = withPrefix(keccak256(abi.encodePacked( bdeValue[0], _hash, _signer )));       

            require(
                recoverSigner(message, signature) == _signer, "invalid Signer!"
            );

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