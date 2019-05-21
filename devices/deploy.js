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

// TODO: change to structure where gateway.js is inside ethdata
const ethKeystore = '/Users/mac/ChainSkills/private';
const ethAccount = '8acd17e6f4fef86fdf75078d179ec2612fb354ae';
const ethPassword = 'aa';

const ethObject = keythereum.importFromFile(ethAccount, ethKeystore);
const ethKey = keythereum.recover(ethPassword, ethObject);
// const ethKey = '91fd0bb9c0735d750279cfc92728e53fcd70116e6e69f8299c3e33c6d6cb5bb5'; // TODO: hardcode for testing purpose

// Ganache or Private Ethereum Blockchain
const selectedHost = 'http://127.0.0.1:8545';

const web3 = new Web3(new Web3.providers.HttpProvider(selectedHost));

const contract = 'LightBulbs.sol';

// Compile contracts
compileContract.buildContract(contract);

// It will read the ABI & byte code contents from the JSON file in ./build/contracts/ folder
const jsonOutputName = `${path.parse(contract).name}.json`;
const jsonFile = `./.built_contracts/${jsonOutputName}`;

// Check if .built_contracts exist, if not, make 1
const webJsonDir = './public';
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
    from: ethAccount,
};

web3.eth.getTransactionCount(ethAccount, 'pending').then(nonce => {
    objTx.nonce = nonce;

    const rawTx = new Tx(objTx);
    // Get the account private key, need to use it to sign the transaction later.
    const privateKey = Buffer.from(ethKey, 'hex');
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
        console.log(`Successful: ${txHash}`);
        console.log('waiting for Transaction Receipt');

        // wait 3s before moving foward
        setTimeout(function() {
            web3.eth
                .getTransactionReceipt(txHash)
                .then(receipt => {
                    console.log(receipt.contractAddress);
                    // Update JSON
                    jsonOutput.contracts[contract].contractAddress =
                        receipt.contractAddress;
                    // Web frontend only need abi & contract address
                    const webJsonOutput = {
                        abi,
                        contractAddress: receipt.contractAddress,
                        keyObject: ethObject,
                    };
                    const formattedJson = JSON.stringify(jsonOutput, null, 4);
                    const formattedWebJson = JSON.stringify(webJsonOutput);
                    fs.writeFileSync(jsonFile, formattedJson);
                    fs.writeFileSync(webJsonFile, formattedWebJson);
                })
                .catch(error => {
                    console.log(error);
                });
        }, 30000);
    });
});