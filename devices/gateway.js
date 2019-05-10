/* eslint-disable dot-notation */
/* eslint-disable prefer-destructuring */
/* eslint-disable prettier/prettier */
/* eslint-disable import/no-unresolved */
/* eslint-disable import/no-extraneous-dependencies */

// TODO: do not need fs
const fs = require('fs');
const Web3 = require('web3');
const redis = require('redis');
const deploy = require('./deploy');

// TODO: command to read address & password
// Retrieve the command line arguments
// var argv = require('minimist')(process.argv.slice(2), { string: ['checkminter'] });

// Ethereum Blockchain
const host = 'ws://127.0.0.1:8546';
deploy.host = host;
const web3js = new Web3(Web3.givenProvider || new Web3.providers.WebsocketProvider(host));

// create new Redis client
const client = redis.createClient(); // using default connection (127.0.0.1 : 6379)
client.on('connect', function() {
  console.log('Redis client connected');
});
client.on('error', function(err) {
  console.log(`Something went wrong ${err}`);
});

/*
 * Deploy contracts
*/
const contractElecTricPlugs = deploy.deployContracts('ElectricPlugs.sol');
const contractLightBulbs = deploy.deployContracts('LightBulbs.sol');

let LightBulbs;
let ElectricPlugs;

// This function listenning to all ElectricPlugs events
function ElectricPlugsEvents() {
  // Assign contract for event listenning of ElectricPlugs
  ElectricPlugs = new web3js.eth.Contract(contractElecTricPlugs.abi, contractElecTricPlugs.contractAddress);

  // Listenning to all events of ElectricPlugs
  ElectricPlugs.events
    .NewElectricPlug()
    .on('data', function(event) {
      const data = event.returnValues;
      client.hmset(data.hash_id, {
        'id': data.hash_id,
        'name': data.name,
        'description': data.description,
        'status': data.status,
      });
      // call sadd(KEY_NAME VALUE1..VALUEN) to store the set of hash_id
      console.log(`${data.hash_id  } ${  data.name  } ${  data.description  } ${  data.status}`);
      client.sadd('ElectricPlugs', data.hash_id);
    })
    .on('error', console.error);

  ElectricPlugs.events
    .NameChange()
    .on('data', function(event) {
      const data = event.returnValues;
      client.hmset(data.hash_id, {'name': data.name});
    })
    .on('error', console.error);

  ElectricPlugs.events
    .DescriptionChange()
    .on('data', function(event) {
      const data = event.returnValues;
      client.hmset(data.hash_id, {'description': data.description});
    })
    .on('error', console.error);

  ElectricPlugs.events
    .StatusChange()
    .on('data', function(event) {
      const data = event.returnValues;
      client.hmset(data.hash_id, {'status': data.status});
    })
    .on('error', console.error);
}

// // This function listenning to all LightBulbs events
function LightBulbsEvents() {
  // Assign contract for event listenning of LightBulbs
  LightBulbs = new web3js.eth.Contract(contractLightBulbs.abi, contractLightBulbs.contractAddress);

  // Listenning to all events of LightBulbs
  LightBulbs.events
    .NewLightBulb()
    .on('data', function(event) {
      const data = event.returnValues;
      client.hmset(
        data.hash_id, {
          'id': data.hash_id,
          'name': data.name,
          'description': data.description,
          'status': data.status,
          'red': data.red,
          'green': data.green,
          'blue': data.blue,
          'intensity': data.intensity
        }
        
      );
      // call sadd(KEY_NAME VALUE1..VALUEN) to store the set of hash_id
      client.sadd('LightBulbs', data.hash_id);
    })
    .on('error', console.error);

  LightBulbs.events
    .NameChange()
    .on('data', function(event) {
      const data = event.returnValues;
      client.hmset(data.hash_id, {'name': data.name});
    })
    .on('error', console.error);

  LightBulbs.events
    .DescriptionChange()
    .on('data', function(event) {
      const data = event.returnValues;
      client.hmset(data.hash_id, {'description': data.description});
    })
    .on('error', console.error);

  LightBulbs.events
    .StatusChange()
    .on('data', function(event) {
      const data = event.returnValues;
      client.hmset(data.hash_id, {'status': data.status});
    })
    .on('error', console.error);
  LightBulbs.events
    .ColorChange()
    .on('data', function(event) {
      const data = event.returnValues;
      client.hmset(
        data.hash_id,
        {'red': data.red,
        'green': data.green,
        'blue': data.blue}
      );
    })
    .on('error', console.error);
  LightBulbs.events
    .IntensityChange()
    .on('data', function(event) {
      const data = event.returnValues;
      client.hmset(data.hash_id, {'intensity': data.intensity});
    })
    .on('error', console.error);
}

/*
 * ----- Start of the main server code -----
*/

ElectricPlugsEvents();
LightBulbsEvents();
