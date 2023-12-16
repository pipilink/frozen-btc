# Host
ssh 24mail.ru

# Oracle 
sqlplus bitcoin/weil...@xepdb

select * from node;

select * from node_status;

select * from node_report;

# Load data
./load_data.sh

# start node
docker run -v bitcoind-data:/bitcoin/.bitcoin --name=bitcoind-node -d -p 8333:8333 -p 127.0.0.1:8332:8332 kylemanna/bitcoind

# bitcoin node comand
docker logs -f bitcoind-node

https://developer.bitcoin.org/reference/rpc/


docker exec -it bitcoind-node bitcoin-cli -rpcwait getblockchaininfo

docker exec -it bitcoind-node bitcoin-cli -rpcwait getblockhash 1

docker exec -it bitcoind-node bitcoin-cli -rpcwait getblock
"00000000839a8e6886ab5951d76f411475428afc90947ee320161bbf18eb6048"

docker exec -it bitcoind-node bitcoin-cli -rpcwait getrawtransaction "0e3e2357e806b6cdb1f70b54c3a3a17b6714ee1f0e68bebb44a74b1efd512098" true

# Scripts
Load bitcoin TRX ino Oracle Database
cd /home/bitcoin/rpcdata

./load_data.sh