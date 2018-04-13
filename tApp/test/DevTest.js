var DevToken = artifacts.require("./DevToken.sol");
var RevToken = artifacts.require("./RevToken.sol");
var devInstance;
var revInstance;
contract("DevToken", accounts => {
    var args = require("../constructor.js")(accounts);
    before(async() => {
        devInstance = await DevToken.deployed();
        revInstance = await RevToken.deployed();
    });

    it("init testing", async() => {
        var balance = await devInstance.balanceOf.call(args[0].owners[0]);
        assert.equal(balance.toNumber(), toWei(args[0].balances[0]), 
        "initial balance of first account should be " + args[0].balances[0] + " DVT");

        var totalSupply = await devInstance.totalSupply.call();
        assert.equal(totalSupply.toNumber(), toWei(args[0].balances[0]), 
        "totalSupply should be " + args[0].balances[0] + " DVT");
        console.log("\ntotalSupply: " + fromWei(totalSupply));

        var maxSupply = await devInstance.maxSupply.call();
        assert.equal(maxSupply.toNumber(), toWei(args[0].maxSupply), 
        "maxSupply should be " + args[0].maxSupply + " DVT");
        console.log("maxSupply: " + fromWei(maxSupply));

        var tokensPerEth = await devInstance.tokensPerEth.call();
        assert.equal(tokensPerEth.toNumber(), args[0].tokensPerEth, 
        "tokensPerEth should be " + args[0].tokensPerEth + " DVT");
        console.log("tokensPerEth: " + tokensPerEth);
        
        var maxStake = await devInstance.maxStake.call();
        assert.equal(maxStake.toNumber(), args[0].maxStake, 
        "maxStake should be " + args[0].maxStake + " DVT");
        console.log("maxStake: " + maxStake);

        var allowanceValue = await devInstance.allowanceValue.call();
        assert.equal(allowanceValue.toNumber(), toWei(args[0].allowanceValue), 
        "allowanceValue should be " + args[0].allowanceValue + " DVT");
        console.log("allowanceValue: " + fromWei(allowanceValue) + " ETH");

        var allowanceBalance = await devInstance.allowanceBalance.call();
        assert.equal(allowanceBalance.toNumber(), toWei(args[0].allowanceValue), 
        "allowanceBalance should be " + args[0].allowanceValue + " DVT");
        console.log("allowanceBalance: " + fromWei(allowanceBalance) + " ETH");

        var allowanceInterval = await devInstance.allowanceInterval.call();
        assert.equal(allowanceInterval.toNumber(), args[0].allowanceInterval, 
        "allowanceInterval should be " + args[0].allowanceInterval + " DVT");
        console.log("allowanceInterval: " + allowanceInterval);

        var owner = await devInstance.owner.call();
        assert.equal(owner, accounts[0], 
        "wrong owner");
        console.log("maxStakeinToken = %s\nmaxStakeinEth = %s\n", args[0].maxStakeinToken, args[0].maxStakeinEth);
    });

    it("Funding", async() => {
        console.log("\nbalance account 0: " + args[0].balances[0]);
        try {
            var balance = await devInstance.balanceOf.call(args[0].owners[0]);
            await devInstance.sendTransaction({from: args[0].owners[0], value: 1});
            var balance1 = await devInstance.balanceOf.call(args[0].owners[0]);
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
        var balance0 = args[0].balances[0];

        for (var i = 1; i < 9; i++) {
            if ((maxSupply-totalSupply) <= toWei(args[0].maxStakeinToken)) {
                var balance = (maxSupply-totalSupply)/args[0].tokensPerEth;
                await devInstance.sendTransaction({from: accounts[i], value: balance});
                totalSupply = await devInstance.totalSupply();
                assert.equal(totalSupply.toNumber(), maxSupply.toNumber(), 
                "should have totalSupply (equal to maxSupply) of " + fromWei(maxSupply) + " DVT, actual totalSupply: " + fromWei(totalSupply) + " DVT");
                balance = await devInstance.balanceOf.call(accounts[i]); 
                console.log("balance account " + i + ": " + fromWei(balance));
                console.log("contract balance: " + fromWei(web3.eth.getBalance(DevToken.address)) + " ETH\n");
                break;
            } else {
                await devInstance.sendTransaction({from: accounts[i], value: toWei(args[0].maxStakeinEth)});
                totalSupply = await devInstance.totalSupply();
                var balance = toWei(balance0+i*args[0].maxStakeinToken);
                assert.equal(totalSupply.toNumber(), balance,
                "should have totalSupply of " + fromWei(balance) + " DVT, actual totalSupply: " + fromWei(totalSupply) + " DVT");
                var balance = await devInstance.balanceOf.call(accounts[i]);
                console.log("balance account " + i + ": " + fromWei(balance));
            }
        }
        try {
            await devInstance.sendTransaction({from: accounts[9], value: 1});
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

        await devInstance.allowanceWithdrawal(toWei(args[0].allowanceValue/2),{from: accounts[0]});
        var allowanceBalance = await devInstance.allowanceBalance.call();
        assert.equal(toWei(args[0].allowanceValue/2), allowanceBalance.toNumber(),
        "should have allowanceBalance of " + args[0].allowanceValue/2 + " ETH, actual allowanceBalance: " + fromWei(allowanceBalance) + " ETH");
        
        await devInstance.allowanceWithdrawal(toWei(args[0].allowanceValue/2),{from: accounts[0]});
        var allowanceBalance = await devInstance.allowanceBalance.call();
        assert.equal(0, allowanceBalance.toNumber(),
        "should have allowanceBalance of " + 0 + " ETH, actual allowanceBalance: " + fromWei(allowanceBalance) + " ETH");

        try {
            await devInstance.allowanceWithdrawal(toWei(args[0].allowanceValue),{from: accounts[0]});
            assert.fail("Testing allowanceBalance: should have failed");
        } catch(error) {
            assertVMError(error);
        }
        // wait x seconds to check balance after allowance interval 
        wait(args[0].allowanceInterval);
        await devInstance.allowanceWithdrawal(toWei(args[0].allowanceValue),{from: accounts[0]});
        var allowanceBalance = await devInstance.allowanceBalance.call();
        assert.equal(0, allowanceBalance.toNumber(),
        "should have allowanceBalance of " + 0 + " ETH, actual allowanceBalance: " + fromWei(allowanceBalance) + " ETH");
        
        try {
            await devInstance.allowanceWithdrawal(toWei(args[0].allowanceValue),{from: accounts[0]});
            assert.fail("Testing allowanceBalance: should have failed");
        } catch(error) {
            assertVMError(error);
        }
    });

    it("TaskVoting testing", async() => {
        // testing proposeTask
        console.log("\nTesting TaskVoting with balances\naccount 0:40\naccount 0:25\naccount 0:25\naccount 0:10\n")
        try {
            await devInstance.propose_Task("test-name-1", "test-description-1", toWei(1) , {from: accounts[9]});
            assert.fail("Testing onlyTokenholder Modifier: should have failed");
        } catch(error) {
            assertVMError(error);
        }
        try {
            await devInstance.propose_Task("test-name-1", "test-description-1", toWei(10000), {from: accounts[0]});
            assert.fail("Testing contract balance: should have failed");
        } catch(error) {
            assertVMError(error);
        }

        await devInstance.propose_Task("test-name-1", "test-description-1", toWei(1) , {from: accounts[0]});
        var proposalLength = await devInstance.getProposalLength_Task.call();
        assert.equal(1, proposalLength.toNumber(),
        "should have proposalLength of " + 1 + ", actual proposalLength: " + proposalLength.toNumber());

        try {
            await devInstance.propose_Task("test-name-1", "test-description-1", toWei(1), {from: accounts[0]});
            assert.fail("Testing proposalDuration_Task: should have failed (account already has active proposal)");
        } catch(error) {
            assertVMError(error);
        }

        wait(args[0].proposalDuration_Task);

        await devInstance.propose_Task("test-name-2", "test-description-2", toWei(1) , {from: accounts[0]});
        var proposalLength = await devInstance.getProposalLength_Task.call();
        assert.equal(2, proposalLength.toNumber(),
        "should have proposalLength of " + 2 + ", actual proposalLength: " + proposalLength.toNumber());

        // testing voteTask
        await devInstance.vote_Task(1,false, {from: accounts[0]});
        try {
            await devInstance.vote_Task(1,false, {from: accounts[0]});
            assert.fail("testing Voting: should have failed, already voted.");
        } catch(error) {
            assertVMError(error);
        }
        await devInstance.vote_Task(1,true, {from: accounts[1]});
        await devInstance.vote_Task(1,true, {from: accounts[2]});
        await devInstance.vote_Task(1,true, {from: accounts[3]});

        await devInstance.propose_Task("test-name-3", "test-description-3", toWei(1) , {from: accounts[1]});
        var proposalLength = await devInstance.getProposalLength_Task.call();
        assert.equal(3, proposalLength.toNumber(),
        "should have proposalLength of " + 3 + ", actual proposalLength: " + proposalLength.toNumber());

        await devInstance.vote_Task(2,true, {from: accounts[0]});
        await devInstance.vote_Task(2,false, {from: accounts[1]});
        await devInstance.vote_Task(2,false, {from: accounts[2]});
        await devInstance.vote_Task(2,false, {from: accounts[3]});

        // testing endTask
        try {
            await devInstance.end_Task(2, {from:accounts[0]});
            assert.fail("testing proposalDuration_Task, should have failed, proposal still running");
        } catch(error) {
            assertVMError(error);
        }
        // ending task via vote:
        // proposal 0 should get rejected because participation is too low
        await devInstance.vote_Task(0,true, {from: accounts[0]});
        var active = await devInstance.getProposalActive_Task.call(0);
        var accepted = await devInstance.getProposalAccepted_Task.call(0);
        var rewarded = await devInstance.getProposalRewarded_Task.call(0);
        assert.equal(active, false, "proposal 0 active is: " + active + ", should be: " + false);
        assert.equal(accepted, false, "proposal 0 accepted is: " + accepted + ", should be: " + false);
        assert.equal(rewarded, false, "proposal 0 rewarded is: " + rewarded + ", should be: " + false);

        wait(args[0].proposalDuration_Task);

        // ending task via end call:
        // proposal 2 should get rejected due to votes
        await devInstance.end_Task(2, {from: accounts[0]});
        active = await devInstance.getProposalActive_Task.call(2);
        accepted = await devInstance.getProposalAccepted_Task.call(2);
        rewarded = await devInstance.getProposalRewarded_Task.call(2);
        assert.equal(active, false, "proposal 2 active is: " + active + ", should be: " + false);
        assert.equal(accepted, false, "proposal 2 accepted is: " + accepted + ", should be: " + false);
        assert.equal(rewarded, false, "proposal 2 rewarded is: " + rewarded + ", should be: " + false);
        
        // testing successful proposal 1 and reward payout
        var balance = web3.eth.getBalance(accounts[0]);
        await devInstance.end_Task(1, {from: accounts[1]});
        var balance1 = web3.eth.getBalance(accounts[0]);
        active = await devInstance.getProposalActive_Task.call(1);
        accepted = await devInstance.getProposalAccepted_Task.call(1);
        rewarded = await devInstance.getProposalRewarded_Task.call(1);
        assert.equal(active, false, "proposal 1 active is: " + active + ", should be: " + false);
        assert.equal(accepted, true, "proposal 1 accepted is: " + accepted + ", should be: " + true);
        assert.equal(rewarded, true, "proposal 1 rewarded is: " + rewarded + ", should be: " + true);
        assert.equal(balance.plus(toWei(1)).toString(10), balance1.toString(10),
        "balance after task payout: " + fromWei(balance.plus(toWei(1))) + ", should be: " + fromWei(balance1));
    });

    it("set/check DevToken and RevToken addresses", async() => {
        try {
            await devInstance.setRevContract(RevToken.address, {from: accounts[1]});
            assert.fail("Testing setRevContract: should have failed, wrong address");
        } catch(error) {
            assertVMError(error);
        }
        try {
            await devInstance.setRevContract(0x0, {from: accounts[0]});
            assert.fail("Testing setRevContract: should have failed, 0x0 as parameter");
        } catch(error) {
            assertVMError(error);
        }
        try {
            await devInstance.swap(0, {from: accounts[0]});
            assert.fail("Testing setRevContract: should have failed, address not set yet");
        } catch(error) {
            assertVMError(error);
        }
        await devInstance.setRevContract(RevToken.address, {from: accounts[0]});
        var revAddress = await devInstance.RevTokenAddress.call();
        assert.equal(revAddress, RevToken.address,
        "RevToken Address: " + revAddress + " should be equal to " + RevToken.address);
        console.log("\nRevTokenAddress: " + revAddress);
        try {
            await devInstance.setRevContract(RevToken.address, {from: accounts[0]});
            assert.fail("Testing setRevContract: should have failed, address already set");
        } catch(error) {
            assertVMError(error);
        }
        var devAddress = await revInstance.DevTokenAddress.call();
        assert.equal(devAddress, DevToken.address,
        "DevToken Address: " + devAddress + " should be equal to " + DevToken.address);
        console.log("DevTokenAddress: " + devAddress);

        try {
            await revInstance.swap(1,accounts[0], {from: accounts[0]});
            assert.fail("Testing address swap (revToken): should have failed, wrong address (not DevTokenContract)");
        } catch(error) {
            assertVMError(error);
        }

        var devBalance = await devInstance.balanceOf.call(accounts[0]);
        try {
            await devInstance.swap(devBalance.plus(1), {from: accounts[0]});
            assert.fail("Testing swap account balance: should have failed, insufficient account balance");
        } catch(error) {
            assertVMError(error);
        }

        var revBalance = await revInstance.balanceOf.call(accounts[0]);
        var revBalanceEnterprise = await revInstance.balanceOf.call("0xDEB80077101d919b6ad1e004Cff36203A0F0CE60");
        var devTotalSupply = await devInstance.totalSupply.call();
        var devMaxSupply = await devInstance.maxSupply.call();
        var revTotalSupply = await revInstance.totalSupply.call();
        
        assert.equal(0,revBalance.toNumber(),
        "should have rev balance of " + 0 + ", actual balance " + fromWei(revBalance));
        assert.equal(0,revBalanceEnterprise.toNumber(),
        "should have rev enterprise balance of " + 0 + ", actual balance " + fromWei(revBalanceEnterprise));
        assert.equal(0,revTotalSupply.toNumber(),
        "should have rev totalSupply of " + 0 + ", actual balance " + fromWei(revTotalSupply));
        
        console.log("swapping 1 DVT\n");
        devInstance.swap(toWei(1), {from: accounts[0]});

        revBalance = await revInstance.balanceOf.call(accounts[0]);
        revBalanceEnterprise = await revInstance.balanceOf.call("0xDEB80077101d919b6ad1e004Cff36203A0F0CE60");
        devTotalSupply = await devInstance.totalSupply.call();
        devMaxSupply = await devInstance.maxSupply.call();
        revTotalSupply = await revInstance.totalSupply.call();

        assert.equal(toWei(1),revBalance.toNumber(),
        "should have rev balance of " + 1 + ", actual balance " + fromWei(revBalance));
        assert.equal(toWei(0.05),revBalanceEnterprise.toNumber(),
        "should have rev enterprise balance of " + 0.05 + ", actual balance " + fromWei(revBalanceEnterprise));
        assert.equal(toWei(1.05),revTotalSupply.toNumber(),
        "should have rev totalSupply of " + 1.05 + ", actual balance " + fromWei(revTotalSupply));
    });
});

contract("RevToken", accounts => {
    var args = require("../constructor.js")(accounts);
    before(async() => {
        devInstance = await DevToken.deployed();
        // revInstance = await RevToken.deployed();
    });
})

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
    while(waitend < wait + (seconds+1)*(1000)) {
        waitend = new Date().getTime();
    }
}