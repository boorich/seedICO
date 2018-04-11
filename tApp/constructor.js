//values have to be entered without decimals
module.exports = function(accounts) {
    var maxStake = 25;
    var maxSupply = 100;
    var tokensPerEth = 5;
    var maxStakeinToken = maxStake*maxSupply/100;
    var maxStakeinEth = maxStake*maxSupply/(100*tokensPerEth);
    // calculate initial balance so we can test maxSupply
    // we have 8 spare accounts to fill the contract
    var balance0 = maxStake*maxSupply/100;
    if (8*maxStake*maxSupply/100 < maxSupply) {
        balance0 = maxSupply - 8*maxStake*maxSupply/100;
    }
    if (balance0 < maxSupply*0.4) {
        balance0 = maxSupply*0.4;
    }

    return arguments = {
        name: "DevToken",
        symbol: "DVT",
        maxSupply: maxSupply,
        maxStake: maxStake,
        tokensPerEth: tokensPerEth,
        owners: [
            accounts[0],
        ],
        balances: [
            balance0,
        ],
        allowanceInterval: 20,
        allowanceValue: 1,
        proposalDuration: 60,
        minVotes: 50,
        maxStakeinToken: maxStakeinToken,
        maxStakeinEth: maxStakeinEth,
    }
}