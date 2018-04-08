var DevToken = artifacts.require("./DevToken.sol");
var devInstance;
contract("DevToken", accounts => {
    var args = require("../constructor.js")(accounts);
    before(async() => {
        devInstance = await DevToken.deployed();
    });

    it("init testing", async() => {
        var balance = await devInstance.balanceOf.call(args.owners[0]);
        assert.equal(balance.valueOf(), args.balances[0], "initial balance should have " + web3.fromWei(args.balances[0],"ether") + " DVT");
        var totalSupply = await devInstance.totalSupply.call();
        assert.equal(totalSupply.valueOf(), args.balances[0], "totalSupply should be " + web3.fromWei(args.balances[0],"ether") + " DVT");
        var maxSupply = await devInstance.maxSupply.call();
        assert.equal(maxSupply.valueOf(), args.maxSupply, "maxSupply should be " + web3.fromWei(args.maxSupply,"ether") + " DVT")
        var owner = await devInstance.owner.call();
        assert.equal(owner, accounts[0], "wrong owner");
    });

    it("Funding", async() => {
        try {
            await devInstance.sendTransaction({from: accounts[0], value: toWei(2)});
            var totalSupply = await devInstance.totalSupply.call();
            assert.fail("should have failed, totalSupply: " + web3.fromWei(totalSupply,"ether"));
        } catch(error) {
            assertVMError(error);
        }

        await devInstance.sendTransaction({from: accounts[0], value: toWei(1)});
        var totalSupply = await devInstance.totalSupply();
        assert.equal(totalSupply.valueOf(), toWei(25), "should have totalSupply of 25 DVT");

        await devInstance.sendTransaction({from: accounts[1], value: toWei(5)});
        totalSupply = await devInstance.totalSupply();
        assert.equal(totalSupply.valueOf(), toWei(50), "should have totalSupply of 50 DVT");

        await devInstance.sendTransaction({from: accounts[2], value: toWei(4)});
        totalSupply = await devInstance.totalSupply();
        assert.equal(totalSupply.valueOf(), toWei(70), "should have totalSupply of 70 DVT");

        await devInstance.sendTransaction({from: accounts[3], value: toWei(3)});
        totalSupply = await devInstance.totalSupply();
        assert.equal(totalSupply.valueOf(), toWei(85), "should have totalSupply of 85 DVT");

        await devInstance.sendTransaction({from: accounts[4], value: toWei(3)});
        totalSupply = await devInstance.totalSupply();
        var maxSupply = await devInstance.maxSupply();
        assert.equal(totalSupply.valueOf(), maxSupply.valueOf(), "should have totalSupply of 100 DVT");

        try {
            await devInstance.sendTransaction({from: accounts[5], value: toWei(1)});
            var totalSupply = await devInstance.totalSupply.call();
            assert.fail("should have failed, totalSupply: " + web3.fromWei(totalSupply,"ether"));
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
    return x*(10**18);
}
