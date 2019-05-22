import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:newuicontrollor/class/color.dart';
import 'package:newuicontrollor/class/shareddata.dart';
import 'package:newuicontrollor/web3/web3.dart';
import 'package:web3dart/web3dart.dart';

// const abi = './assets/abi/contracts_IoTdevices.abi';
// const account = './assets/abi/account.json';

// var privatekey =
//     "91fd0bb9c0735d750279cfc92728e53fcd70116e6e69f8299c3e33c6d6cb5bb5"; //Ganache

// var privatekey =
//     "9F1A7E0B0220589436824383080ABB1A1CDCAAA7DEEE79B877818D51C45EEAEE";//Ropsten
// final EthereumAddress contractAddr =
//     EthereumAddress.fromHex('0x5ae2f4c118c7c125325df35c369f3fb9715f9b11');//Ropsten

// var apiUrl =
//     "https://ropsten.infura.io/v3/4164c4424c7d465daab94864544fa622"; //Ropsten

// final File abiFile = File(abi);

class Web3P {
  static final EthereumAddress contractAddr =
      EthereumAddress.fromHex('0x791a8291982DA8E3aac8618c76dd3Cb61d778227');
  static var apiUrl = "http://10.0.0.50:7545"; //Ganache
  // static var privatekey =
  //     '91fd0bb9c0735d750279cfc92728e53fcd70116e6e69f8299c3e33c6d6cb5bb5';
  // static var credentials = EthPrivateKey.fromHex(privatekey);

  static Future<String> web3adddevice(String name, String description) async {
    // String accountjson = await rootBundle.loadString(account);
    // Wallet wallet = Wallet.fromJson(accountjson, "aa");
    // credentials = wallet.privateKey;
    String privatekey = await SharedData.getPrivateKey();
    var credentials = EthPrivateKey.fromHex(privatekey);
    int chainid = await SharedData.getChainID();
    String contractaddress = await SharedData.getContractAddress();
    print(contractaddress);
    EthereumAddress contractAddress = EthereumAddress.fromHex(contractaddress);
    String serveraddress = await SharedData.getServerAddress();
    if (serveraddress.length > 5) {
      apiUrl = serveraddress;
    }
    final client = Web3Client(apiUrl, Client());
    String jsonContent = await rootBundle.loadString(abi);
    // final ownAddress = await credentials.extractAddress();
    // final abiCode = await abiFile.readAsString();
    final contract = DeployedContract(
        ContractAbi.fromJson(jsonContent, 'LightBulbs'), contractAddress);
    final addnewlightbulb = contract.function('_addNewLightBulb');
    String res;
    try {
      res = await client
          .sendTransaction(
              credentials,
              Transaction.callContract(
                  contract: contract,
                  function: addnewlightbulb,
                  maxGas: 6521975,
                  parameters: [name, description]),
              chainId: chainid)
          .timeout(Duration(seconds: 4));
      print(res);
    } on SocketException {
      print("Private is Wrong");
      res = "wrong";
    } on TimeoutException {
      print("Timeout");
      res = "wrong";
    }

    if (res.toString().contains("0x")) {
      return "success";
    } else {
      return "fail";
    }
  }

  static Future<DeployedContract> deployedcontract() async {
    String contractaddress = await SharedData.getContractAddress();
    print(contractaddress);
    EthereumAddress contractAddress = EthereumAddress.fromHex(contractaddress);
    String jsonContent = await rootBundle.loadString(abi);
    final contract = DeployedContract(
        ContractAbi.fromJson(jsonContent, 'LightBulbs'), contractAddress);
    return contract;
  }

  static Future<DeviceStatus> web3fetchdevicestatus(String id) async {
    String contractaddress = await SharedData.getContractAddress();
    print(contractaddress);
    EthereumAddress contractAddress = EthereumAddress.fromHex(contractaddress);
    String serveraddress = await SharedData.getServerAddress();
    if (serveraddress.length > 5) {
      apiUrl = serveraddress;
    }
    final client = Web3Client(apiUrl, Client());
    String jsonContent = await rootBundle.loadString(abi);
    // final abiCode = await abiFile.readAsString();
    int ininum = int.parse(id);
    BigInt bid = BigInt.from(ininum);
    final contract = DeployedContract(
        ContractAbi.fromJson(jsonContent, 'LightBulbs'), contractAddress);
    final fetchDeviceStatus = contract.function('fetchDeviceStatus');
    final response = await client
        .call(contract: contract, function: fetchDeviceStatus, params: [bid]);
    var curdevice = new DeviceStatus.fromResponse(bid, response);
    print("red${curdevice.red.toInt()}");
    print("green${curdevice.green.toInt()}");
    print("blue${curdevice.blue.toInt()}");
    return curdevice;
  }

  static Future<bool> web3changedevicecolor(BigInt bid, RGB color) async {
    String privatekey = await SharedData.getPrivateKey();
    var credentials = EthPrivateKey.fromHex(privatekey);
    int chainid = await SharedData.getChainID();
    String contractaddress = await SharedData.getContractAddress();
    print(contractaddress);
    EthereumAddress contractAddress = EthereumAddress.fromHex(contractaddress);
    String serveraddress = await SharedData.getServerAddress();
    if (serveraddress.length > 5) {
      apiUrl = serveraddress;
    }
    final client = Web3Client(apiUrl, Client());
    String jsonContent = await rootBundle.loadString(abi);
    final ownAddress = await credentials.extractAddress();
    // final abiCode = await abiFile.readAsString();
    final contract = DeployedContract(
        ContractAbi.fromJson(jsonContent, 'LightBulbs'), contractAddress);
    final changeColor = contract.function('_changeColor');
    print('changedevicecolorred${color.red}');
    print('changedevicecologreen${color.green}');
    print('changedevicecoloblue${color.blue}');
    var res = await client.sendTransaction(
        credentials,
        Transaction.callContract(
            contract: contract,
            function: changeColor,
            maxGas: 6521975,
            parameters: [
              bid,
              BigInt.from(color.red),
              BigInt.from(color.green),
              BigInt.from(color.blue)
            ]),
        chainId: chainid);
    print(res);

    if (res.toString().contains("0x")) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> web3changedevicestatus(BigInt bid) async {
    String privatekey = await SharedData.getPrivateKey();
    var credentials = EthPrivateKey.fromHex(privatekey);
    int chainid = await SharedData.getChainID();
    String contractaddress = await SharedData.getContractAddress();
    print(contractaddress);
    EthereumAddress contractAddress = EthereumAddress.fromHex(contractaddress);
    String serveraddress = await SharedData.getServerAddress();
    if (serveraddress.length > 5) {
      apiUrl = serveraddress;
    }
    final client = Web3Client(apiUrl, Client());
    String jsonContent = await rootBundle.loadString(abi);
    final ownAddress = await credentials.extractAddress();
    // final abiCode = await abiFile.readAsString();
    final contract = DeployedContract(
        ContractAbi.fromJson(jsonContent, 'LightBulbs'), contractAddr);
    final changeStatus = contract.function('_changeStatus');

    var res = await client.sendTransaction(
        credentials,
        Transaction.callContract(
            contract: contract,
            function: changeStatus,
            maxGas: 6521975,
            parameters: [bid]),
        chainId: chainid);
    print(res);

    if (res.toString().contains("0x")) {
      return true;
    } else {
      return false;
    }
  }

  static Future<int> web3getnumberofdevice() async {
    String contractaddress = await SharedData.getContractAddress();
    print(contractaddress);
    EthereumAddress contractAddress = EthereumAddress.fromHex(contractaddress);

    String abifilepath = await SharedData.getABIFilePath();
    File abiFile = new File(abifilepath);
    final abiCode = await abiFile.readAsString();

    String serveraddress = await SharedData.getServerAddress();
    if (serveraddress.length > 5) {
      apiUrl = serveraddress;
    }
    final client = Web3Client(apiUrl, Client());
    // String jsonContent = await rootBundle.loadString(abi);

    final contract = DeployedContract(
        ContractAbi.fromJson(abiCode, 'LightBulbs'), contractAddress);
    final getNumberOfdevices = contract.function('getNumberOfdevices');
    int number;

    try {
      final response = await client.call(
          contract: contract,
          function: getNumberOfdevices,
          params: []).timeout(Duration(seconds: 4));

      print(response);
      number = response[0].toInt();
    } on SocketException {
      print("Private is Wrong");
    } on TimeoutException {
      print("Timeout");
    }

    return number;
  }
}
