import { AptosAccount, AptosClient, TxnBuilderTypes } from "cedra";
import yargs from "yargs";
import { hideBin } from "yargs/helpers";

import { CedraPriceServiceConnection } from "../index";

const argv = yargs(hideBin(process.argv))
  .option("price-ids", {
    description:
      "Space separated price feed ids (in hex) to fetch" +
      " e.g: 0xf9c0172ba10dfa4d19088d...",
    type: "array",
    required: true,
  })
  .option("price-service", {
    description:
      "Endpoint URL for the price service. e.g: https://endpoint/example",
    type: "string",
    required: true,
  })
  .option("full-node", {
    description: "URL of the full Cedra node RPC endpoint.",
    type: "string",
    required: true,
  })
  .option("pyth-contract", {
    description: "Pyth contract address.",
    type: "string",
    required: true,
  })
  .help()
  .alias("help", "h")
  .parserConfiguration({
    "parse-numbers": false,
  })
  .parseSync();

async function run() {
  // Fetch the latest price feed update data from the Price Service
  const connection = new CedraPriceServiceConnection(argv.priceService);
  const priceFeedUpdateData = await connection.getPriceFeedsUpdateData(
    argv.priceIds as string[],
  );

  // Update the Pyth Contract using this update data
  if (process.env.CEDRA_KEY === undefined) {
    throw new Error(`CEDRA_KEY environment variable should be set.`);
  }

  const sender = new CedraAccount(Buffer.from(process.env.CEDRA_KEY, "hex"));
  const client = new CedraClient(argv.fullNode);
  const result = await client.generateSignSubmitWaitForTransaction(
    sender,
    new TxnBuilderTypes.TransactionPayloadEntryFunction(
      TxnBuilderTypes.EntryFunction.natural(
        argv.pythContract + "::pyth",
        "update_price_feeds_with_funder",
        [],
        [CedraPriceServiceConnection.serializeUpdateData(priceFeedUpdateData)],
      ),
    ),
  );

  console.dir(result, { depth: null });
}

run();
