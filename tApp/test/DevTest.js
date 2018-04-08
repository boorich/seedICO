var DevToken = artifacts.require("./DevToken.sol");

contract("DevToken", function(accounts) {
    it("should give first account 20 DVT", function() {
        return DevToken.deployed().then(function(instance) {
            return instance.balanceOf.call(accounts[0]);
        }).then(function(balance) {
            assert.equal(balance.valueOf(), 20000000000000000000, "20000000000000000000 wasn't in the first account");
        });
    }
)});