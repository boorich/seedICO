var Web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:7545"));

//Dummys to test
//DevToken
abiDev = '[{"constant":true,"inputs":[],"name":"maxInvestment","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"_ID","type":"uint256"}],"name":"getProposalStart","outputs":[{"name":"start","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_ID","type":"uint256"}],"name":"end","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"_ID","type":"uint256"}],"name":"getProposalDescription","outputs":[{"name":"description","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"_ID","type":"uint256"}],"name":"getProposalName","outputs":[{"name":"name","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"RevTokenAddress","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"allowanceTimeCounter","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"getTokenPrice","outputs":[{"name":"_tokensPerEther","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_contractAddress","type":"address"}],"name":"setRevContract","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"_ID","type":"uint256"}],"name":"getProposalYes","outputs":[{"name":"yes","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"getProposalLength","outputs":[{"name":"length","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"allowanceBalance","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"_ID","type":"uint256"}],"name":"getProposalRewarded","outputs":[{"name":"rewarded","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_tokenAmount","type":"uint256"}],"name":"swap","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"allowanceInterval","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_name","type":"string"},{"name":"_description","type":"string"},{"name":"_value","type":"uint256"}],"name":"propose","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"_ID","type":"uint256"}],"name":"getProposalActive","outputs":[{"name":"active","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"_ID","type":"uint256"}],"name":"getProposalAccepted","outputs":[{"name":"accepted","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"_ID","type":"uint256"}],"name":"getProposalValue","outputs":[{"name":"value","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_value","type":"uint256"}],"name":"allowanceWithdrawal","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"proposals_Task","outputs":[{"name":"ID","type":"uint256"},{"name":"name","type":"string"},{"name":"description","type":"string"},{"name":"value","type":"uint256"},{"name":"start","type":"uint256"},{"name":"yes","type":"uint256"},{"name":"no","type":"uint256"},{"name":"active","type":"bool"},{"name":"accepted","type":"bool"},{"name":"rewarded","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_ID","type":"uint256"},{"name":"_vote","type":"bool"}],"name":"vote","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"_ID","type":"uint256"}],"name":"getProposalNo","outputs":[{"name":"no","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"maxSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"allowanceValue","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"maxStake","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"tokensPerEther","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"payable":true,"stateMutability":"payable","type":"fallback"},{"anonymous":false,"inputs":[{"indexed":true,"name":"ID","type":"uint256"},{"indexed":true,"name":"description","type":"string"}],"name":"ProposalCreation_Task","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"ID","type":"uint256"},{"indexed":true,"name":"user","type":"address"},{"indexed":true,"name":"value","type":"bool"}],"name":"UserVote_Task","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"ID","type":"uint256"},{"indexed":true,"name":"description","type":"string"},{"indexed":true,"name":"value","type":"uint256"}],"name":"SuccessfulProposal_Task","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"ID","type":"uint256"},{"indexed":true,"name":"description","type":"string"},{"indexed":true,"name":"reason","type":"string"}],"name":"RejectedProposal_Task","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"from","type":"address"},{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Transfer","type":"event"}]';
adressDev = "0x57544ce2893a3aa4bb5d8d29532dfafbd23a39ef";

//RevToken
//abiRev = 0;
//adressRev = 0;

//web3.toWei(1,"ether") // 1000000000000000000 wei
//web3.fromWei(1000000000000000000, "ether") // 1 ether



if(Web3.isConnected()) {
    //test all functions
    var contractDev = getContractDev(abiDev,adressDev);
    console.log("nameDev: " + getNameDev(contractDev));
    console.log("maxSupplyDev: " + getMaxSupplyDev(contractDev));
    var dummy_address = "0xcbDa343da6A8909e38a62146877E448Ccc9c0872";
    console.log("balanceDev: " + getBalanceDev(contractDev,dummy_address));
    console.log("totalSupplyDev: " + getTotalSupplyDev(contractDev));
    console.log("tokenPerEtherDev: " + getTokenPriceDev(contractDev));
  } else {
    console.log("Web3 not connected");
}

////////////////////////////
// - DEVToken Functions - //
////////////////////////////

//returns contract as JSON Object to call all functions
function getContractDev(_abiDev, _adressDev){
    return Web3.eth.contract(JSON.parse(_abiDev)).at(_adressDev);
}

//returns Token name as a String
function getNameDev(_contractDev){
    return _contractDev.name();
}

//returns amount of existing DevTokens as integer
function getTotalSupplyDev(_contractDev){
    return Web3.fromWei(_contractDev.totalSupply(), "ether");
}

//returns maximum of acquirable DevTokens as integer
function getMaxSupplyDev(_contractDev){
    return Web3.fromWei(_contractDev.maxSupply(), "ether");
}

//returns the users balance of DevTokens
function getBalanceDev(_contractDev, _dummy_address){
    return Web3.fromWei(_contractDev.balanceOf(_dummy_address), "ether");
}

//return current eth price of choosed token as integer
function getTokenPriceDev(_contractDev){
    return Web3.fromWei(_contractDev.getTokenPrice(), "ether");
}

////////////////////////////
// - REVToken Functions - //
////////////////////////////

//returns contract as JSON Object to call all functions
function getContractRev(_abiRev, _adressRev){
    return Web3.eth.contract(JSON.parse(_abiRev)).at(_adressRev);
}

//returns Token name as a String
function getNameRev(_contractRev){
    return _contractRev.name();
}

//returns amount of existing RevTokens as integer
function getTotalSupplyRev(_contractRev){
    return Web3.fromWei(_contractRev.totalSupply(), "ether");
}

//returns maximum of acquirable RevTokens as integer
function getMaxSupplyRev(_contractRev){
    return Web3.fromWei(_contractRev.maxSupply(), "ether");
}

//returns the users balance of RevTokens
function getBalanceRev(_contractRev, _dummy_address){
    return Web3.fromWei(_contractRev.balanceOf(_dummy_address), "ether");
}

//return current eth price of choosed token as integer
function getTokenPriceRev(_contractRev){
    return Web3.fromWei(_contractRev.getTokenPrice(), "ether");
}