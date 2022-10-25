// deploy/08_deploy_root_controller.js
module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const Root = await deployments.get("Root");
  const UniversalRegistrar = await deployments.get("UniversalRegistrar");
  await deploy("UniversalRootController", {
    from: deployer,
    args: [Root.address, UniversalRegistrar.address],
    log: true,
  });
};

module.exports.tags = ["UniversalRegistrarController"];
module.exports.dependencies = ["Root", "UniversalRegistrar"];
