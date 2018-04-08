var DevToken = artifacts.require("./DevToken.sol");
var devInstance;
contract("DevToken", accounts => {
    var args = require("../constructor.js")(accounts);
    before(async() => {
        devInstance = await DevToken.deployed();
    });

    it("init testing", async() => {
        var balance = await devInstance.balanceOf.call(accounts[0]);
        assert.equal(balance.valueOf(), toWei(20), "should have 20 DVT");
        var owner = await devInstance.owner.call();
        assert.equal(owner, accounts[0], "wrong owner");
    });

    
});

function assertVMError(error){
    if(error.message.search('VM Exception')==-1)console.log(error);
    assert.isAbove(error.message.search('VM Exception'), -1, 'Error should have been caused by EVM');
}
function toWei(x) {
    return x*(10**18);
}
