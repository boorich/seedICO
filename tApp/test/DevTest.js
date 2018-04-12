var DevToken = artifacts.require("./DevToken.sol");
var devInstance;
contract("DevToken", accounts => {
    var args = require("../constructor.js")(accounts);
    before(async() => {
        devInstance = await DevToken.deployed();
    });
    // test inital variables
    it("init testing", async() => {
        var balance = await devInstance.balanceOf.call(args.owners[0]);
        assert.equal(balance.toNumber(), toWei(args.balances[0]), 
        "initial balance of first account should be " + args.balances[0] + " DVT");

        var totalSupply = await devInstance.totalSupply.call();
        assert.equal(totalSupply.toNumber(), toWei(args.balances[0]), 
        "totalSupply should be " + args.balances[0] + " DVT");
        console.log("totalSupply: " + fromWei(totalSupply));

        var maxSupply = await devInstance.maxSupply.call();
        assert.equal(maxSupply.toNumber(), toWei(args.maxSupply), 
        "maxSupply should be " + args.maxSupply + " DVT");
        console.log("maxSupply: " + fromWei(maxSupply));

        var tokensPerEth = await devInstance.tokensPerEth.call();
        assert.equal(tokensPerEth.toNumber(), args.tokensPerEth, 
        "tokensPerEth should be " + args.tokensPerEth + " DVT");
        console.log("tokensPerEth: " + tokensPerEth);
        
        var maxStake = await devInstance.maxStake.call();
        assert.equal(maxStake.toNumber(), args.maxStake, 
        "maxStake should be " + args.maxStake + " DVT");
        console.log("maxStake: " + maxStake);

        var allowanceValue = await devInstance.allowanceValue.call();
        assert.equal(allowanceValue.toNumber(), toWei(args.allowanceValue), 
        "allowanceValue should be " + args.allowanceValue + " DVT");
        console.log("allowanceValue: " + fromWei(allowanceValue) + " ETH");

        var allowanceBalance = await devInstance.allowanceBalance.call();
        assert.equal(allowanceBalance.toNumber(), toWei(args.allowanceValue), 
        "allowanceBalance should be " + args.allowanceValue + " DVT");
        console.log("allowanceBalance: " + fromWei(allowanceBalance) + " ETH");

        var allowanceInterval = await devInstance.allowanceInterval.call();
        assert.equal(allowanceInterval.toNumber(), args.allowanceInterval, 
        "allowanceInterval should be " + args.allowanceInterval + " DVT");
        console.log("allowanceInterval: " + allowanceInterval);

        var owner = await devInstance.owner.call();
        assert.equal(owner, accounts[0], 
        "wrong owner");
        console.log("maxStakeinToken = %s\nmaxStakeinEth = %s\n", args.maxStakeinToken, args.maxStakeinEth);
    });

    it("Funding", async() => {
        console.log("\nbalance account 0: " + args.balances[0]);
        try {
            var balance = await devInstance.balanceOf.call(args.owners[0]);
            await devInstance.sendTransaction({from: args.owners[0], value: 1});
            var balance1 = await devInstance.balanceOf.call(args.owners[0]);
            assert.fail("Testing maxStake: should have failed, balance before: " + fromWei(balance) + ", balance afterwards: " + fromWei(balance1));
        } catch(error) {
            assertVMError(error);
        }
        try {
            await devInstance.sendTransaction({from: accounts[9], value: 0});
            assert.fail("Testing fallback function: should have failed, not accepting 0 ETH");
        } catch(error) {
            assertVMError(error);
        }

        // fill available accounts with maxStake until full
        var totalSupply = await devInstance.totalSupply.call();
        var maxSupply = await devInstance.maxSupply.call();
        var balance0 = args.balances[0];

        for (var i = 1; i < 9; i++) {
            if ((maxSupply-totalSupply) <= toWei(args.maxStakeinToken)) {
                var balance = (maxSupply-totalSupply)/args.tokensPerEth;
                await devInstance.sendTransaction({from: accounts[i], value: balance});
                totalSupply = await devInstance.totalSupply();
                assert.equal(totalSupply.toNumber(), maxSupply.toNumber(), 
                "should have totalSupply (equal to maxSupply) of " + fromWei(maxSupply) + " DVT, actual totalSupply: " + fromWei(totalSupply) + " DVT");
                balance = await devInstance.balanceOf.call(accounts[i]); 
                console.log("balance account " + i + ": " + fromWei(balance) + "\n");
                break;
            } else {
                await devInstance.sendTransaction({from: accounts[i], value: toWei(args.maxStakeinEth)});
                totalSupply = await devInstance.totalSupply();
                var balance = toWei(balance0+i*args.maxStakeinToken);
                assert.equal(totalSupply.toNumber(), balance,
                "should have totalSupply of " + fromWei(balance) + " DVT, actual totalSupply: " + fromWei(totalSupply) + " DVT");
                var balance = await devInstance.balanceOf.call(accounts[i]);
                console.log("balance account " + i + ": " + fromWei(balance));
            }
        }
        try {
            await devInstance.sendTransaction({from: accounts[9], value: 1});
            var totalSupply = await devInstance.totalSupply.call();
            assert.fail("Testing maxSupply: should have failed, should not be able to invest more than maxSupply");
        } catch(error) {
            assertVMError(error);
        }
    });
    it("ownerAllowance", async() => {
        try {
            await devInstance.allowanceWithdrawal(1,{from: accounts[1]});
            assert.fail("Testing owner: should have failed, wrong address");
        } catch(error) {
            assertVMError(error);
        }

        await devInstance.allowanceWithdrawal(toWei(args.allowanceValue/2),{from: accounts[0]});
        var allowanceBalance = await devInstance.allowanceBalance.call();
        assert.equal(toWei(args.allowanceValue/2), allowanceBalance.toNumber(),
        "should have allowanceBalance of " + args.allowanceValue/2 + " ETH, actual allowanceBalance: " + fromWei(allowanceBalance) + " ETH");
        
        await devInstance.allowanceWithdrawal(toWei(args.allowanceValue/2),{from: accounts[0]});
        var allowanceBalance = await devInstance.allowanceBalance.call();
        assert.equal(0, allowanceBalance.toNumber(),
        "should have allowanceBalance of " + 0 + " ETH, actual allowanceBalance: " + fromWei(allowanceBalance) + " ETH");

        try {
            await devInstance.allowanceWithdrawal(toWei(args.allowanceValue),{from: accounts[0]});
            assert.fail("Testing allowanceBalance: should have failed");
        } catch(error) {
            assertVMError(error);
        }
        // wait x seconds to check balance after allowance interval 
        wait(args.allowanceInterval);
        await devInstance.allowanceWithdrawal(toWei(args.allowanceValue),{from: accounts[0]});
        var allowanceBalance = await devInstance.allowanceBalance.call();
        assert.equal(0, allowanceBalance.toNumber(),
        "should have allowanceBalance of " + 0 + " ETH, actual allowanceBalance: " + fromWei(allowanceBalance) + " ETH");
        
        try {
            await devInstance.allowanceWithdrawal(toWei(args.allowanceValue),{from: accounts[0]});
            assert.fail("Testing allowanceBalance: should have failed");
        } catch(error) {
            assertVMError(error);
        }
    })
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
function wait(seconds) {
    var wait = new Date().getTime();
    var waitend = wait;
    while(waitend < wait + seconds*(1000)) {
        waitend = new Date().getTime();
    }
}