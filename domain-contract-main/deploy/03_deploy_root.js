// deploy/03_deploy_root.js
module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const ENSRegistry = await deployments.get("ENSRegistry");
  await deploy("Root", {
    from: deployer,
    args: [ENSRegistry.address],
    log: true,
  });
};

module.exports.tags = ["Root"];
module.exports.dependencies = ["ENSRegistry"];
