// Tutorial 2
// Command Line: node tutorial2.js --deploy example.sol

// The require packages
const path = require('path');
const fs = require('fs');
const Web3 = require('web3');
const Tx = require('ethereumjs-tx');
const keythereum = require('keythereum');
const compileContract = require('./compile');

// Retrieve the command line arguments
// let argv = require('minimist')(process.argv.slice(2));

// const ethKeystore = '/Users/kainguyen/ethdata';
// const ethAccount = '5c2fba29b8dd90a63b2a7f450c81facbb69bdbfa';
// const ethPassword = '123';

// const ethObject= keythereum.importFromFile(ethAccount, ethKeystore);
// const ethKey = keythereum.recover(ethPassword, ethObject);


let accounts = [
  {
    // Ganache Default Accounts, do not use it for your production
    // Develop 1
    address: '0x8A6BA2553Cddb37733850438a682f8420ac0Be3f',
    key: '65153f3cb3b023cdd2619d24b1ae08fa5ea8d3ed036aecdb03899e37ec7182bb'
  },
  {
    // Develop 2
    address: '0xf17f52151EbEF6C7334FAD080c5704D77216b732',
    key: 'ae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162f'
  },
  {
    // Develop 3
    address: '0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef',
    key: '0dbbe8e4ae425a6d2687f1a7e3ba17bc98c673636790f1b8ad91193c05875ef1'
  },
];

// Ganache or Private Ethereum Blockchain
let selectedHost = 'http://127.0.0.1:8000';

let selectedAccountIndex = 0; // Using the first account in the list

web3 = new Web3(new Web3.providers.HttpProvider(selectedHost));

let contract = 'ElectricPlugs.sol';

// Compile contracts
compileContract.buildContract(contract);

// It will read the ABI & byte code contents from the JSON file in ./build/contracts/ folder
let jsonOutputName = path.parse(contract).name + '.json';
let jsonFile = './.built_contracts/' + jsonOutputName;

// Check if .built_contracts exist, if not, make 1
var webJsonDir = './.deployed_contracts';
if (!fs.existsSync(webJsonDir)) {
  fs.mkdirSync(webJsonDir);
}
// After the smart deployment, it will generate another simple json file for web frontend.
let webJsonFile = webJsonDir + '/' + jsonOutputName;

// Read the JSON file contents
let contractJsonContent = fs.readFileSync(jsonFile, 'utf8');
let jsonOutput = JSON.parse(contractJsonContent);

// Retrieve the ABI 
let abi = jsonOutput['contracts'][contract][path.parse(contract).name]['abi'];

// Retrieve the byte code
let bytecode = jsonOutput['contracts'][contract][path.parse(contract).name]['evm']['bytecode']['object'];

// let tokenContract = new web3.eth.Contract(abi);
let contractData = null;

// Prepare the smart contract deployment payload
// If the smart contract constructor has mandatory parameters, you supply the input parameters like below 
//
// contractData = tokenContract.new.getData( param1, param2, ..., {
//    data: '0x' + bytecode
// });    

contractData = `0x${bytecode}`;

// Prepare the raw transaction information
let objTx = {
  gasPrice: web3.utils.toHex(web3.eth.gasPrice),
  gasLimit: web3.utils.toHex(6000000),
  data: contractData,
  from: accounts[selectedAccountIndex].address
};

web3.eth.getTransactionCount(accounts[selectedAccountIndex].address, 'pending').then(nonce => {
  objTx.nonce = nonce;

  let rawTx = new Tx(objTx);
  // Get the account private key, need to use it to sign the transaction later.
  let privateKey = Buffer.from(accounts[selectedAccountIndex].key, 'hex')
  // Sign the transaction 
  rawTx.sign(privateKey);
  let serializedTx = rawTx.serialize();
  let signedTx = '0x' + serializedTx.toString('hex');

  // Submit the smart contract deployment transaction
  web3.eth.sendSignedTransaction(signedTx, (error, txHash) => {
    // console.log(chalk.green("sendSignedTransaction error, txHash"), error, txHash);
    if (error) {
      console.log(error);
    }
    // else 
    console.log('Successful');
    web3.eth.getTransactionReceipt(txHash, (error, receipt) => {
      if (error) {
        console.log(error);
      }
      // else
      console.log(receipt.contractAddress);
      // Update JSON
      jsonOutput['contracts'][contract]['contractAddress'] = receipt.contractAddress;
      // Web frontend only need abi & contract address
      let webJsonOutput = {
        'abi': abi,
        'contractAddress': receipt.contractAddress
      };
      let formattedJson = JSON.stringify(jsonOutput, null, 4);
      let formattedWebJson = JSON.stringify(webJsonOutput);
      fs.writeFileSync(jsonFile, formattedJson);
      fs.writeFileSync(webJsonFile, formattedWebJson);
    });
  });
});