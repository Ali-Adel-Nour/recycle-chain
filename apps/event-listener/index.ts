import "dotenv/config";
import { ethers } from "ethers";
import { contractAddress } from "./util.ts";

import { SimpleCounter__factory } from "../../standalone/simple-counter-contract/types/ethers-contracts/factories/SimpleCounter__factory.ts";

const main = async () => {
  const wsUrl = process.env.ALCHEMY_WSS_URL || process.env.RPC_URL;
  if (!wsUrl || !wsUrl.startsWith("wss")) {
    throw new Error(
      "Missing WebSocket URL. Set ALCHEMY_WSS_URL to a wss:// endpoint.",
    );
  }

  const provider = new ethers.WebSocketProvider(wsUrl);
  const contract = SimpleCounter__factory.connect(contractAddress, provider);

  console.log("Listening for events from contract ....:");

  try {
    contract.on(contract.filters["NumberIncremented"], (updatedNumber) => {
      console.log("Number incremented:", updatedNumber);
    });
  } catch (error) {
    console.error("Error listening to Incremented events:", error);
  }

  try {
    contract.on(contract.filters["NumberDecremented"], (updatedNumber) => {
      console.log("Number decremented:", updatedNumber);
    });
  } catch (error) {
    console.error("Error listening to Decremented events:", error);
  }
};

main().catch((error) => {
  console.error("Listener failed:", error);
  process.exitCode = 1;
});
