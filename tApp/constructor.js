function toWei(x) {
    return x*(10**18);
}
module.exports = function(accounts) {
    return arguments = {
        name: "DevToken",
        symbol: "DVT",
        maxSupply: toWei(100),
        maxStake: 25,
        tokensPerEther: 5,
        owners: [
            accounts[0],
        ],
        balances: [
            toWei(20),
        ],
        allowanceInterval: 60,
        allowanceValue: toWei(1),
        proposalDuration: 60,
        minVotes: 50,
    }
}