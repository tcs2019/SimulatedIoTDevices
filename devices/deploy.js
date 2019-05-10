/* CREDIT:
 * Deploy Smart Contract with Web3js & Account Private Key, No Truffle:
 * https://medium.com/coinmonks/deploy-smart-contract-with-web3js-account-private-key-no-truffle-solidity-tutorial-2-5926fface340
*/

const path = require('path');
const fs = require('fs');
const Tx = require('ethereumjs-tx');
const keythereum = require('keythereum');
const Web3 = require('web3');
const compile = require('./compile');

var Deploy = {
  // Ethereum Blockchain
  host: null,
  // Deploy Account
  // FIXME: use argument passed from gateway.js
  ethKeystore: '/Users/kainguyen/ethdata',
  ethAccount: '93f278c2e4dab0525c759388f1ed56268301d8b8',
  ethPassword: '123',
  deployContracts: function(contract) {
    const ethObject= keythereum.importFromFile(this.ethAccount, this.ethKeystore);
    const ethKey = keythereum.recover(this.ethPassword, ethObject);
    // Account address & key used for deploying contracts
    const account = {
      address: this.ethAccount,
      key: ethKey.toString('hex')
    };

    // Objects to hold contracts abi & address after deployment
    let contractOutput= {
      abi: null,
      contractAddress: null
    };

    // Web3js connection & contract
    const web3js = new Web3(Web3.givenProvider || new Web3.providers.WebsocketProvider(this.host));

    const gasPriceHex = web3js.utils.toHex(web3js.eth.gasPrice);
    const gasLimitHex = web3js.utils.toHex(6000000);
    const nonceHex = web3js.utils.toHex(web3js.eth.getTransactionCount(account.address, 'pending'));

    // Compile contracts
    compile.buildContract(contract);

    // It will read the ABI & byte code contents from the JSON file in ./.built_contracts/ folder
    const jsonOutputName = `${path.parse(contract).name}.json`;
    const jsonFile = `./.built_contracts/${jsonOutputName}`;

    // After the smart deployment, it will generate another simple json file for web frontend.
    let result = false;

    try {
      result = fs.statSync(jsonFile);
    } catch (error) {
      console.log(error.message);
      return false;
    }

    // Read the JSON file contents
    const jsonOutput = JSON.parse(fs.readFileSync(jsonFile, 'utf8'));

    // Retrieve the ABI 
    const abi = jsonOutput['contracts'][contract][path.parse(contract).name]['abi'];

    // Retrieve the byte code
    const bytecode = jsonOutput['contracts'][contract][path.parse(contract).name]['evm']['bytecode']['object'];
    const tokenContract = new web3js.eth.Contract(abi);
    let contractData = null;
    contractData = `0x${bytecode}`;

    // Prepare the raw transaction information
    const rawTx = {
      nonce: nonceHex,
      gasPrice: gasPriceHex,
      gasLimit: gasLimitHex,
      data: contractData,
      from: account.address
    };

    // Get the account private key, need to use it to sign the transaction later.
    const privateKey = Buffer.from(account.key, 'hex');

    const tx = new Tx(rawTx);

    // Sign the transaction 
    tx.sign(privateKey);
    const serializedTx = tx.serialize();
    let receipt = null;

    // Submit the smart contract deployment transaction
    web3js.eth.sendSignedTransaction(`0x${serializedTx.toString('hex')}`, (err, hash) => {
      if (err) {
        console.log(err); return;
      }

      // Log the tx, you can explore status manually with eth.getTransaction()
      console.log(`Contract creation tx: ${hash}`);

      // Wait for the transaction to be mined
      while (status != '0x1') {

        receipt = web3js.eth.getTransactionReceipt(hash);

        // Simulate the sleep function
        // eslint-disable-next-line no-undef
        Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, 1000);
      }

      console.log(`Contract address: ${receipt.contractAddress}`);
      console.log(`Contract File: ${contract}`);

      // Update JSON
      jsonOutput['contracts'][contract]['contractAddress'] = receipt.contractAddress;

      contractOutput.abi = abi;
      contractOutput.contractAddress = receipt.contractAddress;

      const formattedJson = JSON.stringify(jsonOutput, null, 4);

      fs.writeFileSync(jsonFile, formattedJson);

      console.log(`=== Contract ${contract} deployed ===`);

    });

    return contractOutput;
  }
}

module.exports = Deploy;