const ElectricPlugs = artifacts.require('./ElectricPlugs.sol');
const LightBulbs = artifacts.require('./LightBulbs.sol');

module.exports = function(deployer) {
  deployer.deploy(ElectricPlugs);
  deployer.deploy(LightBulbs);
};
