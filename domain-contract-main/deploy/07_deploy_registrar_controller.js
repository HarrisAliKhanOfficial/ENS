// deploy/07_deploy_registrar_controller.js
module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const UniversalRegistrar = await deployments.get("UniversalRegistrar");
  const SLDPriceOracle = await deployments.get("SLDPriceOracle");
  const NameStore = await deployments.get("NameStore");
  await deploy("UniversalRegistrarController", {
    from: deployer,
    args: [
      UniversalRegistrar.address,
      SLDPriceOracle.address,
      NameStore.address,
      60,
      86400,
    ],
    log: true,
  });
};

module.exports.tags = ["UniversalRegistrarController"];
module.exports.dependencies = [
  "UniversalRegistrar",
  "SLDPriceOracle",
  "NameStore",
];
