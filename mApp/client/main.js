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
  // counter starts at 0

  this.issues = new ReactiveVar("asd");
  var iss = this.issues;
  function printRepoCount() {
    var responseObj = JSON.parse(this.responseText);
  	iss.set(responseObj);
  	// alert(self.issues.get());
  }


  var request = new XMLHttpRequest();
  request.onload = printRepoCount;
  request.open('get', 'https://api.github.com/repos/empea-careercriminal/seedICO', true)
  request.send();

  //selfT.instance().issues.set(self.issues.get());;
  this.issues.set(this.issues.get());
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
      // increment the counter when button is clicked
      selfT.instance().counter.set(instance.counter.get() + 1);
    },
  });




//Ether Stuff
var web3_provider = 'http://localhost:8545';
var web3 = new Web3(new Web3.providers.HttpProvider(web3_provider));
web3.eth.defaultAccount = web3.eth.accounts[0];
//alert(web3.fromWei(web3.eth.getBalance("0xb90b504f4c6bd7535a0bcd200b1a7c17d1cd4f64")), "ether");

//Github API
