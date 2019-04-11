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
const parsedJson = JSON.parse(fs.readFileSync('./contracts/ElectricPlugs.json'));
const abiEP = parsedJson.abi;
const addEP = '0xCE1702d51A160C756EBc2bce64Ee7C1771b5e566';

// LightBulbs contract
// parsedJson = JSON.parse(fs.readFileSync('./contracts/LightBulbs.json'));
// const abiLB = parsedJson.abi;
// const addLB = '0x6Afd71Ac4c9cc622ccd85018671be8e05bA9454E';

// Web3js connection & contract
const web3js = new Web3(Web3.givenProvider || new Web3.providers.WebsocketProvider('ws://127.0.0.1:8546'));

let LightBulbs;
let ElectricPlugs;

// This function listenning to all ElectricPlugs events
function ElectricPlugsEvents() {
  // Assign contract for event listenning of ElectricPlugs
  ElectricPlugs = new web3js.eth.Contract(abiEP, addEP);
  console.log('EL started');

  // Listenning to all events of ElectricPlugs
  ElectricPlugs.events
    .NewElectricPlug()
    .on('data', function(event) {
      console.log('Added');
      const data = event.returnValues;
      client.hmset(data.hash_id, {
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
      client.hset(data.hash_id, 'name', data.name);
    })
    .on('error', console.error);

  ElectricPlugs.events
    .DescriptionChange()
    .on('data', function(event) {
      const data = event.returnValues;
      client.hset(data.hash_id, 'description', data.description);
    })
    .on('error', console.error);

  ElectricPlugs.events
    .StatusChange()
    .on('data', function(event) {
      const data = event.returnValues;
      client.hset(data.hash_id, 'status', data.status);
    })
    .on('error', console.error);
}

// // This function listenning to all LightBulbs events
// function LightBulbsEvents() {
//   // Assign contract for event listenning of LightBulbs
//   LightBulbs = new web3js.eth.Contract(abiLB, addLB);

//   // Listenning to all events of LightBulbs
//   LightBulbs.events
//     .NewLightBulb()
//     .on('data', function(event) {
//       const data = event.returnValues;
//       client.hmset(
//         data.hash_id,
//         'name',
//         data.name,
//         'description',
//         data.description,
//         'status',
//         data.status,
//         'red',
//         data.red,
//         'green',
//         data.green,
//         'blue',
//         data.blue,
//         'intensity',
//         data.intensity
//       );
//       // call sadd(KEY_NAME VALUE1..VALUEN) to store the set of hash_id
//       client.sadd('LightBulbs', data.hash_id);
//     })
//     .on('error', console.error);

//   LightBulbs.events
//     .NameChange()
//     .on('data', function(event) {
//       const data = event.returnValues;
//       client.hset(data.hash_id, 'name', data.name);
//     })
//     .on('error', console.error);

//   LightBulbs.events
//     .DescriptionChange()
//     .on('data', function(event) {
//       const data = event.returnValues;
//       client.hset(data.hash_id, 'description', data.description);
//     })
//     .on('error', console.error);

//   LightBulbs.events
//     .StatusChange()
//     .on('data', function(event) {
//       const data = event.returnValues;
//       client.hset(data.hash_id, 'status', data.status);
//     })
//     .on('error', console.error);
//   LightBulbs.events
//     .ColorChange()
//     .on('data', function(event) {
//       const data = event.returnValues;
//       client.hmset(
//         data.hash_id,
//         'red',
//         data.red,
//         'green',
//         data.green,
//         'blue',
//         data.blue
//       );
//     })
//     .on('error', console.error);
//   LightBulbs.events
//     .IntensityChange()
//     .on('data', function(event) {
//       const data = event.returnValues;
//       client.hset(data.hash_id, 'intensity', data.intensity);
//     })
//     .on('error', console.error);
// }

/*
 * This function initializes:
 * a web3 connection to the private ethereum network
 * a connection to redis client
 */

function startServer() {
  // Start Web3 connection
  // web3js = new Web3(new Web3.providers.HttpProvider('http://localhost:8000'));
  // web3js = new Web3.providers.HttpProvider('http://localhost:8000');
  // web3js = new Web3(new Web3.providers.HttpProvider('http://localhost:8000'));
  // web3js = new Web3(Web3.givenProvider || 'ws://localhost:8000');

  // LightBulbsEvents();
  

  console.log('>> Server Started!');
}

/*
 * ----- Start of the main server code -----
 */

// startServer();
ElectricPlugsEvents();
