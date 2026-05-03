import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("RecycleChain", (m) => {
  const recycleChain = m.contract("RecycleChain");

  return { recycleChain };
});
