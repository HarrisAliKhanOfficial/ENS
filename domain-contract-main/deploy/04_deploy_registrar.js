// deploy/04_deploy_registrar.js
module.exports = async ({ getNamedAccounts, deployments, ethers, config }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const ENSRegistry = await deployments.get("ENSRegistry");
  const Root = await deployments.get("Root");
  await deploy("UniversalRegistrar", {
    from: deployer,
    args: [ENSRegistry.address, Root.address, config.name, config.symbol],
    log: true,
  });
};

module.exports.tags = ["UniversalRegistrar"];
module.exports.dependencies = ["ENSRegistry", "Root"];
