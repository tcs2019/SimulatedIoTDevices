/* eslint-disable dot-notation */
/* eslint-disable prefer-destructuring */
/* eslint-disable prettier/prettier */
/* eslint-disable import/no-unresolved */
/* eslint-disable import/no-extraneous-dependencies */

/* CREDIT:
 * Deploy Smart Contract with Web3js & Account Private Key, No Truffle:
 * https://medium.com/coinmonks/deploy-smart-contract-with-web3js-account-private-key-no-truffle-solidity-tutorial-2-5926fface340
*/

// TODO: command to read add & key from keystore file
// TODO: clean up require after testing
const path = require('path');
const fs = require('fs');
const md5File = require('md5-file');
const Web3 = require('web3');
const solc = require('solc');
const Tx = require('ethereumjs-tx');
const SolidityFunction = require('web3/lib/web3/function');
const redis = require('redis');

// Ethereum Blockchain
const host = 'ws://127.0.0.1:8546';

// Contract name
const contractEP = 'ElectricPlugs.sol';
const contractLB = 'LightBulbs.sol';

// Account address & key used for deploying contracts
const account = [
  {
    address:'',
    key:''
  }
];

// Web3js connection & contract
const web3js = new Web3(Web3.givenProvider || new Web3.providers.WebsocketProvider(host));

const gasPriceHex = web3js.toHex(web3js.eth.gasPrice);
const gasLimitHex = web3js.toHex(6000000);
const block = web3js.eth.getBlock('latest');
const nonceHex = web3js.toHex(web3js.eth.getTransactionCount(account.address, 'pending'));

// Objects to hold contracts abi & address after deployment
const contractOutputEP = {
  abi: null,
  contractAddress: null
};

const contractOutputLB = {
  abi: null,
  contractAddress: null
};

// This function deploy contracts
function deployContracts() {
  // It will read the ABI & byte code contents from the JSON file in ./build/contracts/ folder
  const jsonOutputNameEP = `${path.parse(contractEP).name  }.json`;
  const jsonFileEP = `./build/contracts/${jsonOutputNameEP}`;

  const jsonOutputNameLB = `${path.parse(contractLB).name}.json`;
  const jsonFileLB = `./build/contracts/${  jsonOutputNameLB}`;


  // After the smart deployment, it will generate another simple json file for web frontend.
  const webJsonFileEP = `./www/assets/contracts/${  jsonOutputNameEP}`;
  let resultEP = false;

  try {
    resultEP = fs.statSync(jsonFileEP);
  } catch (error) {
    console.log(error.message);
    return false;
  }

  const webJsonFileLB = `./www/assets/contracts/${jsonOutputNameLB}`;
  let resultLB = false;

  try {
    resultLB = fs.statSync(jsonFileEP);
  } catch (error) {
    console.log(error.message);
    return false;
  }

  // Read the JSON file contents
  const jsonOutputEP = JSON.parse(fs.readFileSync(jsonFileEP, 'utf8'));
  const jsonOutputLB = JSON.parse(fs.readFileSync(jsonFileLB, 'utf8'));

  // Retrieve the ABI 
  const abiEP = jsonOutputEP['contracts'][contractEP][path.parse(contractEP).name]['abi'];
  const abiLB = jsonOutputLB['contracts'][contractLB][path.parse(contractLB).name]['abi'];

  // Retrieve the byte code
  const bytecodeEP = jsonOutputEP['contracts'][contractEP][path.parse(contractEP).name]['evm']['bytecode']['object'];
  const tokenContractEP = web3js.eth.contract(abiEP);
  let contractDataEP = null;
  contractDataEP = tokenContractEP.new.getData({
    data: `0x${  bytecodeEP}`
  });

  const bytecodeLB = jsonOutputLB['contracts'][contractLB][path.parse(contractLB).name]['evm']['bytecode']['object'];
  const tokenContractLB = web3js.eth.contract(abiLB);
  let contractDataLB = null;
  contractDataLB = tokenContractLB.new.getData({
    data: `0x${bytecodeLB}`
  });

  // Prepare the raw transaction information
  const rawTxEP = {
    nonce: nonceHex,
    gasPrice: gasPriceHex,
    gasLimit: gasLimitHex,
    data: contractDataEP,
    from: account.address
  };

  const rawTxLB = {
    nonce: nonceHex,
    gasPrice: gasPriceHex,
    gasLimit: gasLimitHex,
    data: contractDataLB,
    from: account.address
  };

  // Get the account private key, need to use it to sign the transaction later.
  // const privateKey = new Buffer(account.key, 'hex');
  const privateKey = Buffer.alloc(account.key, 'hex');

  const txEP = new Tx(rawTxEP);
  const txLB = new Tx(rawTxLB);

  // Sign the transaction 
  txEP.sign(privateKey);
  const serializedTxEP = txEP.serialize();
  let receiptEP = null;

  txLB.sign(privateKey);
  const serializedTxLB = txLB.serialize();
  let receiptLB = null;

  // Submit the smart contract deployment transaction for ElectricPlugs.sol
  web3js.eth.sendRawTransaction(`0x${  serializedTxEP.toString('hex')}`, (err, hash) => {
    if (err) {
      console.log(err); return;
    }

    // Log the tx, you can explore status manually with eth.getTransaction()
    console.log(`Contract creation tx: ${  hash}`);

    // Wait for the transaction to be mined
    while (receiptEP === null) {

      receiptEP = web3js.eth.getTransactionReceipt(hash);

      // Simulate the sleep function
      // eslint-disable-next-line no-undef
      Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, 1000);
    }

    console.log(`Contract address: ${  receiptEP.contractAddress}`);
    console.log(`Contract File: ${  contractEP}`);

    // Update JSON
    jsonOutputEP['contracts'][contractEP]['contractAddress'] = receiptEP.contractAddress;

    // Web services just need to have abi & contract address
    // TODO: clean up after testing
    // const webJsonOutputEP = {
    //   'abi': abiEP,
    //   'contractAddress': receiptEP.contractAddress
    // };
    contractOutputEP.abi = abiEP;
    contractOutputEP.contractAddress = receiptEP.contractAddress;


    const formattedJsonEP = JSON.stringify(jsonOutputEP, null, 4);
    const formattedWebJsonEP = JSON.stringify(contractOutputEP);

    fs.writeFileSync(jsonFileEP, formattedJsonEP);
    fs.writeFileSync(webJsonFileEP, formattedWebJsonEP);

    console.log('=== Electric Plugs deployed ===');

  });

  // Submit the smart contract deployment transaction for LightBulbs.sol
  web3js.eth.sendRawTransaction(`0x${serializedTxLB.toString('hex')}`, (err, hash) => {
    if (err) {
      console.log(err); return;
    }

    // Log the tx, you can explore status manually with eth.getTransaction()
    console.log(`Contract creation tx: ${hash}`);

    // Wait for the transaction to be mined
    while (receiptLB === null) {

      receiptLB = web3js.eth.getTransactionReceipt(hash);

      // Simulate the sleep function
      // eslint-disable-next-line no-undef
      Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, 1000);
    }

    console.log(`Contract address: ${receiptLB.contractAddress}`);
    console.log(`Contract File: ${contractLB}`);

    // Update JSON
    jsonOutputLB['contracts'][contractLB]['contractAddress'] = receiptLB.contractAddress;

    // Web services just need to have abi & contract address
    contractOutputLB.abi = abiLB;
    contractOutputLB.contractAddress = receiptLB.contractAddress;

    const formattedJsonLB = JSON.stringify(jsonOutputLB, null, 4);
    const formattedWebJsonLB = JSON.stringify(contractOutputLB);

    fs.writeFileSync(jsonFileEP, formattedJsonLB);
    fs.writeFileSync(webJsonFileEP, formattedWebJsonLB);

    console.log('=== Light Bulbs deployed ===');

  });

  return true;
}

// create new Redis client
const client = redis.createClient(); // using default connection (127.0.0.1 : 6379)
client.on('connect', function() {
  console.log('Redis client connected');
});
client.on('error', function(err) {
  console.log(`Something went wrong ${err}`);
});

// ElectricPlugs contract
// let parsedJson = JSON.parse(fs.readFileSync('./contracts/ElectricPlugs.json'));
// const abiEP = parsedJson.abi;
// const addEP = '0x8EDE8A2944f08898d90BF8963DcC65e836351288';

// // LightBulbs contract
// parsedJson = JSON.parse(fs.readFileSync('./contracts/LightBulbs.json'));
// const abiLB = parsedJson.abi;
// const addLB = '0x545742ACD9EcB0016c678113a405af641d5B1949';

let LightBulbs;
let ElectricPlugs;

// This function listenning to all ElectricPlugs events
function ElectricPlugsEvents() {
  // Assign contract for event listenning of ElectricPlugs
  ElectricPlugs = new web3js.eth.Contract(contractOutputEP.abi, contractOutputEP.contractAddress);

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
  LightBulbs = new web3js.eth.Contract(contractOutputLB.abi, contractOutputLB.contractAddress);

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

deployContracts();

ElectricPlugsEvents();
LightBulbsEvents();
