const Pool = require("pg").Pool;
require("dotenv").config({ path: __dirname + "/../.env" });

const pool = new Pool({
  user: `${process.env.PG_USER}`,
  host: `${process.env.PG_HOST}`,
  database: `${process.env.PG_DATABASE}`,
  password: `${process.env.PG_PASSWORD}`,
  port: `${process.env.PG_PORT}`,
});

pool.on("error", (err, client) => {
  console.error("Unexpected error on idle client", err);
  process.exit(-1);
});

pool.connect().then((client) => {
  return client
    .query("SELECT * FROM fbtc_candidates")
    .then((res) => {
      client.release();
      console.log(res.rows); // your callback here
      pool.end();
    })
    .catch((e) => {
      client.release();
      console.log(err.stack); // your callback here
    });
});
