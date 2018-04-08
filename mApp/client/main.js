import { Template } from 'meteor/templating';
import { ReactiveVar } from 'meteor/reactive-var';


import './main.html';
import './js/web3.min.js';

var self = this;
var selfT = Template;
Template.hello.onCreated(function helloOnCreated() {
  // counter starts at 0
  this.counter = new ReactiveVar(0);
});

Template.info.onCreated(function infoOnCreated() {
  this.issues = new ReactiveVar("");
  var iss = this.issues;
  function httpAnswer() {
    var responseObj = JSON.parse(this.responseText);
  	iss.set(responseObj);
  }

  var request = new XMLHttpRequest();
  request.onload = httpAnswer;
  request.open('get', 'https://api.github.com/repos/empea-careercriminal/seedICO', true)
  request.send();
});


Template.hello.helpers({
  counter() {
    return Template.instance().counter.get();
  },
});

Template.info.helpers({
  issues() {
    return Template.instance().issues.get();
  },
});
Template.hello.events({
  'click button'(event, instance) {

    selfT.instance().counter.set(instance.counter.get() + 1);
  },
});

//Ether Stuff
var web3_provider = 'http://localhost:8545';
var web3 = new Web3(new Web3.providers.HttpProvider(web3_provider));
web3.eth.defaultAccount = web3.eth.accounts[0];
//alert(web3.fromWei(web3.eth.getBalance("0xb90b504f4c6bd7535a0bcd200b1a7c17d1cd4f64")), "ether");

//Github API
