import json, os, sys, cx_Oracle
from bitcoinrpc.authproxy import AuthServiceProxy, JSONRPCException
from dotenv import load_dotenv
from decoder import bitaddr

load_dotenv()

rpc_user=os.getenv('RPC_USER')
rpc_password=os.getenv('RPC_PASSWORD')
rpc_port = os.getenv('RPC_PORT')

connection = cx_Oracle.connect(
    user=os.getenv('ORACLE_USER'),
    password=os.getenv('ORACLE_PASSWORD'),
    dsn=os.getenv('ORACLE_DNS'))

cursor = connection.cursor()
cursor.execute('select max(block)+1 block_number from node')
row = cursor.fetchall()
block_number = row[0][0]

def add_rec(block,datetime,address,trx,inout,value,move):
    cursor.execute('insert into node (id, block, datetime,address,trx,inout,value,move) values(-1, :1, :2, :3, :4, :5, :6, :7 )',(block,datetime,address,trx,inout,value,move))

rpc_connection = AuthServiceProxy(f'http://{rpc_user}:{rpc_password}@localhost:{rpc_port}')

while True:
    blockhash = rpc_connection.getblockhash(block_number)
    block = rpc_connection.getblock(blockhash)
    print('block #:', block['height'])

    for txid in block['tx']:
        raw_tx = rpc_connection.getrawtransaction(txid)
        decoded_tx = rpc_connection.decoderawtransaction(raw_tx)
        for vin_rec in decoded_tx['vin']:
            if (vin_rec.get('coinbase') is None):
                out_tx = rpc_connection.getrawtransaction(vin_rec.get('txid'))
                dout_tx = rpc_connection.decoderawtransaction(out_tx)
                rec_tx =dout_tx['vout'][int(vin_rec['vout'])]

                if (float(rec_tx['value']) > 0):
                    if( rec_tx['scriptPubKey']['type'] == 'pubkey'):
                        addr = bitaddr(rec_tx['scriptPubKey']['asm'])
                    elif (rec_tx['scriptPubKey']['type'] in ['multisig','nonstandard']):
                        addr = 'Unknown'
                    else:
                        addr = rec_tx['scriptPubKey']['address']

                    add_rec(block['height'],block['time'],addr,vin_rec.get('txid'),'IN',rec_tx['value'],-1)

        for vout_rec in decoded_tx['vout']:
            if (float(vout_rec['value']) > 0):
                if( vout_rec['scriptPubKey']['type'] == 'pubkey'):
                    addr = bitaddr(vout_rec['scriptPubKey']['asm'])
                elif (vout_rec['scriptPubKey']['type'] in ['multisig','nonstandard']):
                    addr = 'Unknown'
                else:
                    addr = vout_rec['scriptPubKey']['address']

                add_rec(block['height'],block['time'],addr,decoded_tx['txid'],'OUT',vout_rec['value'],1)

        connection.commit()
    block_number += 1
