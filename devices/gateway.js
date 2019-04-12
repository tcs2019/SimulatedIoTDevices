/* eslint-disable prettier/prettier */
/* eslint-disable import/no-unresolved */
/* eslint-disable import/no-extraneous-dependencies */
const fs = require('fs');
const Web3 = require('web3');
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
const addEP = '0x8EDE8A2944f08898d90BF8963DcC65e836351288';

// LightBulbs contract
parsedJson = JSON.parse(fs.readFileSync('./contracts/LightBulbs.json'));
const abiLB = parsedJson.abi;
const addLB = '0x545742ACD9EcB0016c678113a405af641d5B1949';

// Web3js connection & contract
const web3js = new Web3(Web3.givenProvider || new Web3.providers.WebsocketProvider('ws://127.0.0.1:8546'));

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
  LightBulbs = new web3js.eth.Contract(abiLB, addLB);

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
