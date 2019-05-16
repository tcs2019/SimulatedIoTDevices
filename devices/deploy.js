/* CREDIT:
 * Deploy Smart Contract with Web3js & Account Private Key, No Truffle:
 * https://medium.com/coinmonks/deploy-smart-contract-with-web3js-account-private-key-no-truffle-solidity-tutorial-2-5926fface340
 */

const path = require('path');
const fs = require('fs');
const Web3 = require('web3');
const Tx = require('ethereumjs-tx');
const keythereum = require('keythereum');
const compileContract = require('./compile');

// TODO: Retrieve the command line arguments
// let argv = require('minimist')(process.argv.slice(2));

// const ethKeystore = '/Users/kainguyen/ethdata';
// const ethAccount = '5c2fba29b8dd90a63b2a7f450c81facbb69bdbfa';
// const ethPassword = '123';

// const ethObject= keythereum.importFromFile(ethAccount, ethKeystore);
// const ethKey = keythereum.recover(ethPassword, ethObject);

// TODO: change this to only 1 account
const accounts = [
  {
    // Ganache Default Accounts, do not use it for your production
    // Develop 1
    address: '0x2a28ac204dc195e7fa8aa09fea65465758bc0578',
    key: '613259f6674cb62cb3050cb7d6aeca062793372481f3117bb7a4acafeb9f00c0',
  },
  {
    // Develop 2
    address: '0xf17f52151EbEF6C7334FAD080c5704D77216b732',
    key: 'ae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162f',
  },
  {
    // Develop 3
    address: '0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef',
    key: '0dbbe8e4ae425a6d2687f1a7e3ba17bc98c673636790f1b8ad91193c05875ef1',
  },
];

// Ganache or Private Ethereum Blockchain
const selectedHost = 'http://127.0.0.1:8545';

const selectedAccountIndex = 0; // Using the first account in the list

const web3 = new Web3(new Web3.providers.HttpProvider(selectedHost));

const contract = 'LightBulbs.sol';

// Compile contracts
compileContract.buildContract(contract);

// It will read the ABI & byte code contents from the JSON file in ./build/contracts/ folder
const jsonOutputName = `${path.parse(contract).name}.json`;
const jsonFile = `./.built_contracts/${jsonOutputName}`;

// Check if .built_contracts exist, if not, make 1
const webJsonDir = './.deployed_contracts';
if (!fs.existsSync(webJsonDir)) {
  fs.mkdirSync(webJsonDir);
}
// After the smart deployment, it will generate another simple json file for web frontend.
const webJsonFile = `${webJsonDir}/${jsonOutputName}`;

// Read the JSON file contents
const contractJsonContent = fs.readFileSync(jsonFile, 'utf8');
const jsonOutput = JSON.parse(contractJsonContent);

// Retrieve the ABI
const { abi } = jsonOutput.contracts[contract][path.parse(contract).name];

// Retrieve the byte code
const bytecode =
  jsonOutput.contracts[contract][path.parse(contract).name].evm.bytecode.object;

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
const objTx = {
  gasPrice: web3.utils.toHex(web3.eth.gasPrice),
  gasLimit: web3.utils.toHex(6000000),
  data: contractData,
  from: accounts[selectedAccountIndex].address,
};

web3.eth
  .getTransactionCount(accounts[selectedAccountIndex].address, 'pending')
  .then(nonce => {
    objTx.nonce = nonce;

    const rawTx = new Tx(objTx);
    // Get the account private key, need to use it to sign the transaction later.
    const privateKey = Buffer.from(accounts[selectedAccountIndex].key, 'hex');
    // Sign the transaction
    rawTx.sign(privateKey);
    const serializedTx = rawTx.serialize();
    const signedTx = `0x${serializedTx.toString('hex')}`;

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
        jsonOutput.contracts[contract].contractAddress =
          receipt.contractAddress;
        // Web frontend only need abi & contract address
        const webJsonOutput = {
          abi,
          contractAddress: receipt.contractAddress,
        };
        const formattedJson = JSON.stringify(jsonOutput, null, 4);
        const formattedWebJson = JSON.stringify(webJsonOutput);
        fs.writeFileSync(jsonFile, formattedJson);
        fs.writeFileSync(webJsonFile, formattedWebJson);
      });
    });
  });
