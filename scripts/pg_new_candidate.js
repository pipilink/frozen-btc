const axios = require("axios");
const Pool = require("pg").Pool;
require("dotenv").config({ path: __dirname + "/../.env" });
const pool = new Pool({
  user: `${process.env.PG_USER}`,
  host: `${process.env.PG_HOST}`,
  database: `${process.env.PG_DATABASE}`,
  password: `${process.env.PG_PASSWORD}`,
  port: `${process.env.PG_PORT}`,
});

let response = null;
let block_hight;

const run = () => {
  let lastId;
  pool.connect().then((client) => {
    return client
      .query("select max(block_index) last_id from  public.fbtc_candidates")
      .then((res) => {
        client.release();
        block_hight = res.rows[0].last_id + 1;
        getNextBlock(block_hight);
      })
      .catch((e) => {
        client.release();
        console.log("ERROR STACK=>", err.stack); // your callback here
      });
  });
};

function getNextBlock(block_hight) {
  new Promise(async (resolve, reject) => {
    try {
      response = await axios.get(
        `https://blockchain.info/block-height/${block_hight}`,
        {
          headers: {},
        }
      );
    } catch (ex) {
      response = null;
      // error
      console.log("ERROR =>", ex);
      reject(ex);
    }
    if (response) {
      if (response.data.blocks.length && response.data.blocks[0].n_tx == 1) {
        const block_index = response.data.blocks[0].block_index;
        const btc = response.data.blocks[0].tx[0].out[0].addr;
        getAddr(btc, block_index);
        resolve(btc);
      } else {
        console.log("add block manual...", block_hight + 1);
        getNextBlock(block_hight + 1);
        resolve(response);
      }
    }
  });
}

function getAddr(addr, block_index) {
  let response = null;
  new Promise(async (resolve, reject) => {
    try {
      response = await axios.get(
        `https://blockchain.info/multiaddr?active=${addr}`,
        {
          headers: {},
        }
      );
    } catch (ex) {
      response = null;
      // error
      console.log(ex);
      reject(ex);
    }
    if (response) {
      // success
      const btcAddr = { block_index, ...response.data.addresses[0] };
      if (btcAddr.final_balance > 0) {
        newRecord(btcAddr);
      } else {
        getNextBlock(btcAddr.block_index + 1);
      }
      resolve(btcAddr);
    }
  });
}

pool.on("error", (err, client) => {
  console.error("Unexpected error on idle client", err);
  process.exit(-1);
});

function newRecord(btcAddr) {
  let { block_index, address, final_balance, total_received, total_sent } =
    btcAddr;
  pool.connect().then((client) => {
    return client
      .query(
        "INSERT INTO public.fbtc_candidates \
                        (block_index, address, final_balance, total_received, total_sent) \
                         VALUES ($1, $2, $3, $4, $5) RETURNING *",
        [block_index, address, final_balance, total_received, total_sent]
      )
      .then((res) => {
        client.release();
        console.log(res.rows); // your callback here
        //        pool.end()
      })
      .catch((e) => {
        client.release();
        console.log(e.stack); // your callback here
      });
  });
}

setInterval(() => run(), 45000);
//run();
