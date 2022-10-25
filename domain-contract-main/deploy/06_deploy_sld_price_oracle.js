// deploy/06_deploy_sld_price_oracle.js
module.exports = async ({
  getNamedAccounts,
  hardhatArguments,
  deployments,
  ethers,
  config,
}) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const net =
    (hardhatArguments && hardhatArguments.network) || config.defaultNetwork;
  const netConfig = config.networks[net];

  const UniversalRegistrar = await deployments.get("UniversalRegistrar");

  let oracleAddress;
  // check if there is a USD oracle in the config
  if (netConfig && netConfig.usdOracle) {
    oracleAddress = netConfig.usdOracle;
    console.log("Using USD Oracle with address: ", oracleAddress);
  } else {
    // No USD oracle ... deploy DummyOracle with 1 ETH == 1000 USD
    const dummyOracle = await deploy("DummyOracle", {
      from: deployer,
      args: [ethers.BigNumber.from("100000000000")],
      log: true,
    });
    oracleAddress = dummyOracle.address;
    console.log("Using DummyOracle with address: ", oracleAddress);
  }

  const wei = val => val + "000000000000000000";
  const weiPrices = config.prices.map(v => ethers.BigNumber.from(wei(v)));

  await deploy("SLDPriceOracle", {
    from: deployer,
    args: [UniversalRegistrar.address, oracleAddress, weiPrices],
    log: true,
  });
};

module.exports.tags = ["SLDPriceOracle"];
module.exports.dependencies = ["UniversalRegistrar", "USDOracle"];
