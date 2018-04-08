var Migrations = artifacts.require("./Migrations.sol");
var DevToken = artifacts.require("./DevToken.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(DevToken);
};
