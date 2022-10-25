// deploy/05_deploy_name_store.js
module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const UniversalRegistrar = await deployments.get("UniversalRegistrar");
  await deploy("NameStore", {
    from: deployer,
    args: [UniversalRegistrar.address],
    log: true,
  });
};

module.exports.tags = ["NameStore"];
module.exports.dependencies = ["UniversalRegistrar"];
