var LightBulbs = artifacts.require("./LightBulbs.sol");

module.exports = function(deployer) {
    deployer.deploy(LightBulbs);
}