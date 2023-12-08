/* Example in Node.js */
const axios = require("axios");
require("dotenv").config({ path: __dirname + "/../.env" });

let response = null;

new Promise(async (resolve, reject) => {
  try {
    //    response = await axios.get('https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest', {
    response = await axios.get(
      "https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?symbol=BTC,ETH",
      {
        headers: {
          "X-CMC_PRO_API_KEY": `${process.env.COINMARKETCAP_API}`,
        },
        json: true,
        gzip: true,
      }
    );
  } catch (ex) {
    response = null;
    // error
    console.log("ERROR:", ex);
    reject(ex);
  }
  if (response) {
    // success
    const json = response.data.data;
    resolve(json);
  }
}).then((json) => {
  const btc = json.BTC;
  const eth = json.ETH;
  if (btc.quote && eth.quote) {
    //    console.log("BTC Data",btc);
    //    console.log("ETH Data",eth);
    console.log(json.BTC);
    console.log(json.ETH);

    console.log("BTC", btc.quote.USD.price);
    console.log("ETH", eth.quote.USD.price);
    const fBtcPrice = btc.quote.USD.price / eth.quote.USD.price;
    console.log("BTC/ETH Price", fBtcPrice);
    console.log("My Ether active", eth.quote.USD.price * 5 * 100, "RUB");
  }
});
