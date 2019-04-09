/* eslint-disable import/no-unresolved */
/* eslint-disable import/no-extraneous-dependencies */
const fs = require('fs');
const Web3 = require('web3');
const util = require('util');
const redis = require('redis');

// create new Redis client
const client = redis.createClient(); // using default connection (127.0.0.1 : 6379)
client.on('connect', function() {
  console.log('Redis client connected');
});
client.on('error', function(err) {
  console.log(`Something went wrong ${err}`);
});

// ElectricPlugs contract
let parsedJson = JSON.parse(fs.readFileSync('./contracts/ElectricPlugs.json'));
const abiEP = parsedJson.abi;
const addEP = '0x3a4730A7DfE8817A657824F45F3E6B46a3429B6a';

// LightBulbs contract
parsedJson = JSON.parse(fs.readFileSync('./contracts/LightBulbs.json'));
const abiLB = parsedJson.abi;
const addLB = '0x5E8d78dDB087B59c7Cb2bdC691f5c01E5b4e5D1b';

// Web3js connection & contract
let web3js;
let LightBulbs;
let ElectricPlugs;

// This function listenning to all ElectricPlugs events
function ElectricPlugsEvents() {
  // Assign contract for event listenning of ElectricPlugs
  ElectricPlugs = new web3js.eth.Contract(abiEP, addEP);

  // Listenning to all events of ElectricPlugs
  ElectricPlugs.events
    .NewElectricPlug()
    .on('data', function(event) {
      const data = event.returnValues;
      client.hmset(
        data.electricPlugId,
        'id',
        data.electricPlugId,
        'name',
        data.name,
        'description',
        data.description,
        'status',
        data.status
      );
      // TODO: call sadd() to store the set of hashes
    })
    .on('error', console.error);

  ElectricPlugs.events
    .NameChange()
    .on('data', function(event) {
      const data = event.returnValues;
      client.hset(data.electricPlugId, 'name', data.name);
    })
    .on('error', console.error);

  ElectricPlugs.events
    .DescriptionChange()
    .on('data', function(event) {
      const data = event.returnValues;
      client.hset(data.electricPlugId, 'description', data.description);
    })
    .on('error', console.error);

  ElectricPlugs.events
    .StatusChange()
    .on('data', function(event) {
      const data = event.returnValues;
      client.hset(data.electricPlugId, 'status', data.status);
    })
    .on('error', console.error);
}

// This function listenning to all LightBulbs events
function LightBulbsEvents() {
  // Assign contract for event listenning of LightBulbs
  LightBulbs = new web3js.eth.Contract(abiLB, addLB);

  // Listenning to all events of LightBulbs
  LightBulbs.events
    .NewLightBulb()
    .on('data', function(event) {
      const data = event.returnValues;
      client.hmset(
        data.lightBulbId,
        'id',
        data.lightBulbId,
        'name',
        data.name,
        'description',
        data.description,
        'status',
        data.status,
        'red',
        data.red,
        'green',
        data.green,
        'blue',
        data.blue,
        'intensity',
        data.intensity
      );
    })
    .on('error', console.error);

  LightBulbs.events
    .NameChange()
    .on('data', function(event) {
      const data = event.returnValues;
      client.hset(data.lightBulbId, 'name', data.name);
    })
    .on('error', console.error);

  LightBulbs.events
    .DescriptionChange()
    .on('data', function(event) {
      const data = event.returnValues;
      client.hset(data.lightBulbId, 'description', data.description);
    })
    .on('error', console.error);

  LightBulbs.events
    .StatusChange()
    .on('data', function(event) {
      const data = event.returnValues;
      client.hset(data.lightBulbId, 'status', data.status);
    })
    .on('error', console.error);
  LightBulbs.events
    .ColorChange()
    .on('data', function(event) {
      const data = event.returnValues;
      client.hmset(
        data.lightBulbId,
        'red',
        data.red,
        'green',
        data.green,
        'blue',
        data.blue
      );
    })
    .on('error', console.error);
  LightBulbs.events
    .IntensityChange()
    .on('data', function(event) {
      const data = event.returnValues;
      client.hset(data.lightBulbId, 'intensity', data.intensity);
    })
    .on('error', console.error);
}

/*
 * This function initializes:
 * a web3 connection to the private ethereum network
 * a connection to redis client
 */

function startServer() {
  // Start Web3 connection
  // web3js = new Web3(new Web3.providers.HttpProvider('http://localhost:8000'));
  // web3js = new Web3(Web3.givenProvider || new Web3.providers.HttpProvider('http://localhost:8000'))
  web3js = new Web3(Web3.givenProvider || 'ws://localhost:8546');

  LightBulbsEvents();
  ElectricPlugsEvents();

  util.log('>> Server Started!');
}

/*
 * ----- Start of the main server code -----
 */

startServer();
