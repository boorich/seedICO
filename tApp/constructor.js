//values have to be entered without decimals
module.exports = function(accounts) {
    var maxStake = 25;
    var maxSupply = 100;
    var tokensperEth = 5;
    var maxStakeinToken = maxStake*maxSupply/100;
    var maxStakeinEth = maxStake*maxSupply/(100*tokensperEth);
    return arguments = {
        name: "DevToken",
        symbol: "DVT",
        maxSupply: maxSupply,
        maxStake: maxStake,
        tokensperEth: tokensperEth,
        owners: [
            accounts[0],
            accounts[1],
        ],
        balances: [
            maxStakeinToken*2,
            maxStakeinToken/2,
        ],
        allowanceInterval: 60,
        allowanceValue: 1,
        proposalDuration: 60,
        minVotes: 50,
        maxStakeinToken: maxStakeinToken,
        maxStakeinEth: maxStakeinEth,
    }
}