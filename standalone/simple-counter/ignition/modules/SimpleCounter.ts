import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("SimpleCounterModule", (m) => {
  const initialNumber = 42;
  const simpleCounter = m.contract("SimpleCounter", [initialNumber]);

  m.call(simpleCounter, "increment");

  return { simpleCounter };
});
