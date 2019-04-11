/* eslint-disable no-unused-vars */
const fs = require('fs');
const Web3 = require('web3');

// ElectricPlugs contract
const parsedJson = JSON.parse(fs.readFileSync('./contracts/Hello.json'));
const abiHello = parsedJson.abi;
const addHello = '0x0B896E7D4bE9B0232D5C2fD2Aa4E32397D052679';

let HelloContract;

// Web3js connection & contract
const web3js = new Web3(
  Web3.givenProvider ||
    new Web3.providers.WebsocketProvider('ws://127.0.0.1:8546')
);

function HelloEvent() {
  console.log('function started');
  HelloContract = new web3js.eth.Contract(abiHello, addHello);

  HelloContract.events
    .SayHello()
    .on('data', function(event) {
      console.log('event triggered');
    })
    .on('error', console.error);
}

HelloEvent();
