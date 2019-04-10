var ChainList = artifacts.require("./IoTDevices.sol");

module.exports = function(deployer) {
  deployer.deploy(ChainList);
}
