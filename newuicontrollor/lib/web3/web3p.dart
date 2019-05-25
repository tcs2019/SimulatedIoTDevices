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
  static EthereumAddress contractAddress;
  static String serverAddress;
  static Credentials credentials;
  static int chainID;
  static String jsonContent;

  static Future<void> init() async {
    serverAddress = await SharedData.getServerAddress();
    contractAddress =
        EthereumAddress.fromHex(await SharedData.getContractAddress());
    chainID = await SharedData.getChainID();
    jsonContent =
        await rootBundle.loadString(await SharedData.getABIFilePath());
    credentials = EthPrivateKey.fromHex(await SharedData.getPrivateKey());
  }

  static Future<String> web3adddevice(String name, String description) async {
    final client = Web3Client(serverAddress, Client());
    final contract = DeployedContract(
        ContractAbi.fromJson(jsonContent, 'LightBulbs'), contractAddress);
    final addnewlightbulb = contract.function('_addNewLightBulb');
    var res = await client.sendTransaction(
        credentials,
        Transaction.callContract(
            contract: contract, function: addnewlightbulb, maxGas: 6521975,
            // gasPrice: EtherAmount.inWei(BigInt.from(0)),
            parameters: [name, description]),
        chainId: chainID);
    print(res);
    if (res.toString().contains("0x")) {
      return "success";
    } else {
      return "fail";
    }
  }

  static Future<DeployedContract> deployedcontract() async {
    final contract = DeployedContract(
        ContractAbi.fromJson(jsonContent, 'LightBulbs'), contractAddress);
    return contract;
  }

  static Future<DeviceStatus> web3fetchdevicestatus(String id) async {
    final client = Web3Client(serverAddress, Client());
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
    final client = Web3Client(serverAddress, Client());
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
            // gasPrice: EtherAmount.inWei(BigInt.from(0)),
            parameters: [
              bid,
              BigInt.from(color.red),
              BigInt.from(color.green),
              BigInt.from(color.blue)
            ]),
        chainId: chainID);
    print(res);

    if (res.toString().contains("0x")) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> web3changedevicestatus(BigInt bid, bool status) async {
    final client = Web3Client(serverAddress, Client());
    final contract = DeployedContract(
        ContractAbi.fromJson(jsonContent, 'LightBulbs'), contractAddress);
    final changeStatus = contract.function('_changeStatus');

    var res = await client.sendTransaction(
        credentials,
        Transaction.callContract(
            contract: contract,
            function: changeStatus,
            maxGas: 6521975,
            parameters: [bid, status]),
        chainId: chainID);
    print(res);

    if (res.toString().contains("0x")) {
      return true;
    } else {
      return false;
    }
  }

  static Future<int> web3getnumberofdevice() async {
    final client = Web3Client(serverAddress, Client());
    final contract = DeployedContract(
        ContractAbi.fromJson(jsonContent, 'LightBulbs'), contractAddress);
    final getNumberOfdevices = contract.function('getNumberOfdevices');
    int number = 10000;

    final response = await client
        .call(contract: contract, function: getNumberOfdevices, params: []);
    print(response);
    number = response[0].toInt();

    return number;
  }

  // Orchestration
  static Future<bool> web3orchestration(String _func) async {
    final client = Web3Client(serverAddress, Client());
    final contract = DeployedContract(
        ContractAbi.fromJson(jsonContent, 'LightBulbs'), contractAddress);
    final function = contract.function(_func);

    var res = await client.sendTransaction(
        credentials,
        Transaction.callContract(
            contract: contract,
            function: function,
            maxGas: 6521975,
            parameters: []),
        chainId: chainID);
    print(res);

    if (res.toString().contains("0x")) {
      return true;
    } else {
      return false;
    }
  }
}
