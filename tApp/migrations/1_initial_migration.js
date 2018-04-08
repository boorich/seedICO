var Migrations = artifacts.require("./Migrations.sol");
var DevToken = artifacts.require("./DevToken.sol");

module.exports = function(deployer, network, accounts) {
    deployer.deploy(Migrations);
    deployer.deploy(DevToken, "DevToken", "DVT", 1000000000000000000000, 25, 5, [accounts[0]], [20000000000000000000], 60, 50);
};