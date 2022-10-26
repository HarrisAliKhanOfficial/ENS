require("@nomiclabs/hardhat-truffle5");
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ganache");
require("@nomiclabs/hardhat-etherscan");
require("hardhat-abi-exporter");
require("@nomiclabs/hardhat-solhint");
require("hardhat-gas-reporter");
require("hardhat-deploy");
require("@nomiclabs/hardhat-ethers");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

// TLD to use in deployment
const TLD = "TRH";

// Go to https://www.infura.io
const INFURA_API_KEY = "I3483a7c5292c4f009e1b3f01bee7d02c";

// Replace this private key with your account private key
// To export your private key from Metamask, open Metamask and
// go to Account Details > Export Private Key
const PRIVATE_KEY = "c0135c3c88949f5a648bb3da4dc773c4d097b315f87362822d517523857399b7";

// using ChainLink USD Oracle on Mainnet or set null to use DummyOracle
// https://data.chain.link/ethereum/mainnet/crypto-usd/eth-usd
const MAINNET_USD_ORACLE = "0x5f4ec3df9cbd43714fe2740f5e3616155c5b8419";

const accountKey = PRIVATE_KEY === "" ? "0x00" : "0x" + PRIVATE_KEY;

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  name: "Name",
  symbol: "SYMBOL",

  // 1 character names = $50
  // 2 character names = $25
  // and so on...
  prices: [100, 75, 50, 20],

  networks: {
    "truffle-dashboard": {
      url: "http://localhost:24012/rpc",
      tags: ["staging"],
      timeout: 60000,
    },
    truffle: {
      url: "http://localhost:24012/rpc",
      timeout: 60000,
      gasMultiplier: 1,
    },
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
  mocha: {},
  abiExporter: {
    path: "./build/contracts",
    clear: true,
    flat: true,
    spacing: 2,
  },
  solidity: {
    compilers: [
      {
        version: "0.8.6",
      },
      {
        version: "0.8.6",
      },
    ],
  },
};
