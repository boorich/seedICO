var Migrations = artifacts.require("./Migrations.sol");
var DevToken = artifacts.require("./DevToken.sol");



module.exports = function(deployer, network, accounts) {
    var args = require("../constructor.js")(accounts);
    deployer.deploy(Migrations);
    var balances = [];
    for (var i = 0; i < args.balances.length; i++) {
        balances[i] = web3.toWei(args.balances[i]);
    }
    deployer.deploy(DevToken, args.name, args.symbol, web3.toWei(args.maxSupply,"ether"), args.maxStake, args.tokensPerEth, args.owners, balances, args.allowanceInterval, web3.toWei(args.allowanceValue, "ether"), args.proposalDuration, args.minVotes);
};