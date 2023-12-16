#!/usr/bin/env python

import hashlib
import base58

compress_pubkey = False

def hash160(hex_str):
    sha = hashlib.sha256()
    rip = hashlib.new('ripemd160')
    sha.update(hex_str)
    rip.update( sha.digest() )
    return rip.hexdigest()  # .hexdigest() is hex ASCII

def bitaddr(pkey):
    pubkey = pkey.split(' ')[0]
    if (compress_pubkey):
        if (ord(bytearray.fromhex(pubkey[-2:])) % 2 == 0):
            pubkey_compressed = '02'
        else:
            pubkey_compressed = '03'
            pubkey_compressed += pubkey[2:66]
            hex_str = bytearray.fromhex(pubkey_compressed)
    else:
        hex_str = bytearray.fromhex(pubkey)

    key_hash = '00' + hash160(hex_str)
    sha = hashlib.sha256()
    sha.update( bytearray.fromhex(key_hash) )
    checksum = sha.digest()
    sha = hashlib.sha256()
    sha.update(checksum)
    checksum = sha.hexdigest()[0:8]
    address = base58.b58encode( bytearray.fromhex(key_hash + checksum) ).decode("utf-8")
    return(address)
