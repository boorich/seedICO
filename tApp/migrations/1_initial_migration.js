var Migrations = artifacts.require("./Migrations.sol");
var DevToken = artifacts.require("./DevToken.sol");
var RevToken = artifacts.require("./RevToken.sol");


module.exports = function(deployer, network, accounts) {
    var args = require("../constructor.js")(accounts);
    deployer.deploy(Migrations);
    var balances = [];
    for (var i = 0; i < args[0].balances.length; i++) {
        balances[i] = web3.toWei(args[0].balances[i]);
    }
    deployer.deploy(DevToken, args[0].name, args[0].symbol, web3.toWei(args[0].maxSupply,"ether"), args[0].maxStake, args[0].tokensPerEth, args[0].owners, balances, args[0].allowanceInterval, web3.toWei(args[0].allowanceValue, "ether"), args[0].proposalDuration, args[0].minVotes).then(function() {
        return deployer.deploy(RevToken, args[1].name, args[1].symbol, DevToken.address);
    });
};