var DevToken = artifacts.require("./DevToken.sol");
var devInstance;
contract("DevToken", accounts => {
    var args = require("../constructor.js")(accounts);
    before(async() => {
        devInstance = await DevToken.deployed();
    });
    console.log("\nmaxSupply = %s\nmaxStake = %s\ntokensPerEth = %s\nmaxStakeinToken = %s\nmaxStakeinEth = %s\n", args.maxSupply, args.maxStake, args.tokensPerEth, args.maxStakeinToken, args.maxStakeinEth);
    it("init testing", async() => {
        var balance = await devInstance.balanceOf.call(args.owners[0]);
        assert.equal(balance.toNumber(), toWei(args.balances[0]), 
        "initial balance of first account should be " + args.balances[0] + " DVT");
        console.log("balance account 0: " + args.balances[0])

        var balance = await devInstance.balanceOf.call(args.owners[1]);
        assert.equal(balance.toNumber(), toWei(args.balances[1]), 
        "initial balance of second account should be " + args.balances[1] + " DVT");
        console.log("balance account 1: " + args.balances[1])

        var totalSupply = await devInstance.totalSupply.call();
        assert.equal(totalSupply.toNumber(), toWei(args.balances[0]+args.balances[1]), 
        "totalSupply should be " + args.balances[0]+args.balances[1] + " DVT");
        console.log("totalSupply: " + fromWei(totalSupply));

        var maxSupply = await devInstance.maxSupply.call();
        assert.equal(maxSupply.toNumber(), toWei(args.maxSupply), 
        "maxSupply should be " + args.maxSupply + " DVT");
        console.log("maxSupply: " + fromWei(maxSupply));

        var tokensPerEth = await devInstance.tokensPerEth.call();
        assert.equal(tokensPerEth.toNumber(), args.tokensPerEth, 
        "tokensPerEth should be " + args.tokensPerEth + " DVT");
        console.log("maxSupply: " + tokensPerEth);

        var owner = await devInstance.owner.call();
        assert.equal(owner, accounts[0], 
        "wrong owner");
    });
    it("Funding", async() => {
        try {
            var balance = await devInstance.balanceOf.call(args.owners[1]);
            await devInstance.sendTransaction({from: args.owners[1], value: toWei(args.maxStakeinEth)});
            var balance1 = await devInstance.balanceOf.call(args.owners[1]);
            assert.fail("Testing maxStake: should have failed, balance before: " + fromWei(balance) + ", balance afterwards: " + fromWei(balance1));
        } catch(error) {
            assertVMError(error);
        }
        try {
            await devInstance.sendTransaction({from: accounts[4], value: 0});
            var totalSupply = await devInstance.totalSupply.call();
            assert.fail("Testing fallback function: should have failed, not accepting 0 ETH");
        } catch(error) {
            assertVMError(error);
        }
        
        await devInstance.sendTransaction({from: accounts[1], value: toWei(args.maxStakeinEth/2)});
        totalSupply = await devInstance.totalSupply();
        assert.equal(totalSupply.toNumber(), toWei(args.maxSupply*3/4), 
        "should have totalSupply of " + args.maxSupply*3/4 + " DVT, actual totalSupply: " + fromWei(totalSupply) + " DVT");

        await devInstance.sendTransaction({from: accounts[2], value: toWei(args.maxStakeinEth)});
        totalSupply = await devInstance.totalSupply();
        var maxSupply = await devInstance.maxSupply();
        assert.equal(totalSupply.toNumber(), maxSupply.toNumber(), 
        "should have totalSupply (equal to maxSupply) of " + fromWei(maxSupply) + " DVT, actual totalSupply: " + fromWei(totalSupply) + " DVT");

        try {
            await devInstance.sendTransaction({from: accounts[3], value: 1});
            var totalSupply = await devInstance.totalSupply.call();
            assert.fail("Testing maxSupply: should have failed, should not be able to invest more than maxSupply");
        } catch(error) {
            assertVMError(error);
        }
    });
    
});

function assertVMError(error){
    if(error.message.search('VM Exception')==-1)console.log(error);
    assert.isAbove(error.message.search('VM Exception'), -1, 'Error should have been caused by EVM');
}
function toWei(x) {
    return web3.toWei(x, "ether");
}
function fromWei(x) {
    return web3.fromWei(x, "ether");
}