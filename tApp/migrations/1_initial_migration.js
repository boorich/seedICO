var Migrations = artifacts.require("./Migrations.sol");
var DevToken = artifacts.require("./DevToken.sol");
function decimals(x) {
    return x*10**18;
}

module.exports = function(deployer, network, accounts) {
    var args = require("../constructor.js")(accounts);
    deployer.deploy(Migrations);
    deployer.deploy(DevToken, args.name, args.symbol, args.maxSupply, args.maxStake, args.tokensPerEther, args.owners, args.balances, args.allowanceInterval, args.allowanceValue, args.proposalDuration, args.minVotes);
};