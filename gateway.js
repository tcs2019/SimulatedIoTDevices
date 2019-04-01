/* eslint-disable import/no-unresolved */
/* eslint-disable import/no-extraneous-dependencies */
const fs = require('fs');
const express = require('express');
const Web3 = require('web3');
const solc = require('solc');
const util = require('util');

let abiLB;
let abiEP;
let binLB;
let binEP;
let web3js;

let LightBulbs;
let ElectricPlugs;

// FIXME: for now, using global variable to store full state
// FIXME: this variable shoulc only store changed value, not the full state
// let stateLB;
let stateEP;

// This function listenning to all LightBulbs events
function LightBulbsEvents() {
  // Assign contract for event listenning of LightBulbs
  LightBulbs = new web3js.eth.Contract(abiEP, binEP);

  // Listenning to all events of LightBulbs
  LightBulbs.events
    .NameChange()
    .on('data', function(event) {
      // do something on event.returnValues
    })
    .on('error', console.error);

  LightBulbs.events
    .DescriptionChange()
    .on('data', function(event) {
      // do something on event.returnValues
    })
    .on('error', console.error);

  LightBulbs.events
    .StatusChange()
    .on('data', function(event) {
      // do something on event.returnValues
    })
    .on('error', console.error);
  LightBulbs.events
    .ColorChange()
    .on('data', function(event) {
      // do something on event.returnValues
    })
    .on('error', console.error);
  LightBulbs.events
    .IntensityChange()
    .on('data', function(event) {
      // do something on event.returnValues
    })
    .on('error', console.error);
}

// This function listenning to all ElectricPlugs events
function ElectricPlugsEvents() {
  // Assign contract for event listenning of ElectricPlugs
  ElectricPlugs = new web3js.eth.Contract(abiLB, binLB);

  // Listenning to all events of ElectricPlugs
  ElectricPlugs.events
    .NameChange()
    .on('data', function(event) {
      // do something on event.returnValues
    })
    .on('error', console.error);
  ElectricPlugs.events
    .DescriptionChange()
    .on('data', function(event) {
      // do something on event.returnValues
    })
    .on('error', console.error);
  ElectricPlugs.events
    .StatusChange()
    .on('data', function(event) {
      stateEP = event.returnValues;
    })
    .on('error', console.error);
}
/*
 * This function prepares the server by compiling the solidity contracts
 * source code using the solc npm module. On successful compile, extracts the
 * ABI definition and the bytecode. In addition, initializes a web3 connection
 * to the private ethereum network.
 */

function setUp() {
  // Compile ElectricPlugs contract
  let source = fs.readFileSync('./contracts/LightBulbs.sol', 'UTF-8');
  let compiled = solc.compile(source);

  binLB = compiled.contracts[':LightBulbs'].bytecode;

  util.log(`>> setup - Bytecode: ${binLB}`);
  util.log(`>> setup - ABI: ${compiled.contracts[':LightBulbs'].interface}`);

  abiLB = JSON.parse(compiled.contracts[':LightBulbs'].interface);

  // Compile ElectricPlugs contract
  source = fs.readFileSync('./contracts/ElectricPlugs.sol', 'UTF-8');
  compiled = solc.compile(source);

  binEP = compiled.contracts[':ElectricPlugs'].bytecode;

  util.log(`>> setup - Bytecode: ${binEP}`);
  util.log(`>> setup - ABI: ${compiled.contracts[':ElectricPlugs'].interface}`);

  abiEP = JSON.parse(compiled.contracts[':ElectricPlugs'].interface);

  // Start Web3 connection
  // web3js = new Web3(new Web3.providers.HttpProvider('http://localhost:8081'));
  web3js = new Web3(Web3.givenProvider || 'ws://localhost:8546');

  LightBulbsEvents();
  ElectricPlugsEvents();

  util.log('>> setup - Completed !!!');
}

/*
 * ----- Start of The main server code -----
 */

setUp();

const app = express();

app.get('/electric-plug', function(req, res) {
  res.json(stateEP);
});
