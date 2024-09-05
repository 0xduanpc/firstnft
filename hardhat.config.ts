import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-ethers";
import "hardhat-gas-reporter";

type Config = import("hardhat/config").HardhatUserConfig;

/** @type import('hardhat/config').HardhatUserConfig */
const config: Config = {
  solidity: "0.8.24",
  gasReporter: {
    enabled: true,
  },
};

export default config;