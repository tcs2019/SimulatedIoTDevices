/* eslint-disable import/no-unresolved */
/* eslint-disable import/no-extraneous-dependencies */
const fs = require('fs');
const express = require('express');
const bodyparser = require('body-parser');
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

/*
 * This function prepares the server by compiling the solidity contracts
 * source code using the solc npm module. On successful compile, extracts the
 * ABI definition and the bytecode. In addition, initializes a web3 connection
 * to the private ethereum network.
 */

function setUp() {
  // Compile ElectricPlugs contract
  let source = fs.readFileSync('../contracts/LightBulbs.sol', 'UTF-8');
  let compiled = solc.compile(source);

  binLB = compiled.contracts[':LightBulbs'].bytecode;

  util.log(`>> setup - Bytecode: ${binLB}`);
  util.log(`>> setup - ABI: ${compiled.contracts[':LightBulbs'].interface}`);

  abiLB = JSON.parse(compiled.contracts[':LightBulbs'].interface);

  // Compile ElectricPlugs contract
  source = fs.readFileSync('../contracts/ElectricPlugs.sol', 'UTF-8');
  compiled = solc.compile(source);

  binEP = compiled.contracts[':ElectricPlugs'].bytecode;

  util.log(`>> setup - Bytecode: ${binEP}`);
  util.log(`>> setup - ABI: ${compiled.contracts[':ElectricPlugs'].interface}`);

  abiEP = JSON.parse(compiled.contracts[':ElectricPlugs'].interface);

  // Start Web3 connection
  // web3js = new Web3(new Web3.providers.HttpProvider('http://localhost:8081'));

  // TODO: split to LightBulbsEvents function
  // Assign contract for event listenning of LightBulbs
  LightBulbs = new web3js.eth.Contract(abiEP, binEP);

  // Listenning to all events of LightBulbs
  LightBulbs.events
    .NameChange()
    .on('data', function(event) {
      // do something on event.returnValues
    })
    .on('error', console.error);

  // TODO: split to ElectricPlugsEvents function
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
      // do something on event.returnValues
    })
    .on('error', console.error);

  util.log('>> setup - Completed !!!');
}

window.addEventListener('load', function() {
  // Checking if Web3 has been injected by the browser (Mist/MetaMask)
  if (typeof web3 !== 'undefined') {
    // Use Mist/MetaMask's provider
    // eslint-disable-next-line no-undef
    web3js = new Web3(web3.currentProvider);
  } else {
    // Handle the case where the user doesn't have Metamask installed
    web3js = new Web3(new Web3.providers.HttpProvider('http://localhost:8081'));
  }
  // Now you can start your app & access web3 freely:
  setUp();
});
