#!/bin/bash
export PATH=/root/.nvm/versions/node/v9.11.2/bin:/root/.local/bin:/usr/bin:/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin:/opt/oracle/product/18c/dbhomeXE/bin
export LD_LIBRARY_PATH=/opt/oracle/product/18c/dbhomeXE/lib:/usr/local/lib:/usr/lib:/usr/local/lib64:/usr/lib64
export ORACLE_HOME=/opt/oracle/product/18c/dbhomeXE
export ORACLE_SID=XE
export ORAENV_ASK=NO

python3.9 /home/bitcoin/rpcdata/load_blocks.py
