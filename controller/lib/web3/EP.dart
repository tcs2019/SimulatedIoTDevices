import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

const abi = './assets/abi/contracts_IoTdevices.abi';
var privatekey =
    '8bf0407d71b7d641df9cc132eb36828a1dc79912c9d0aa2d03b3bb43fac00990';
String contractaddress = '0x01D7dff89d383871D8d294C2CcFD056091226108';
var apiUrl = "http://10.201.21.135:7545"; //Replace with your API

var httpClient = new Client();
// await httpClient.get('$apiUrl/');
var ethClient = new Web3Client(apiUrl, httpClient);
var credentials = Credentials.fromPrivateKeyHex(privatekey);

class EP {
  static Future web3adddevice(String name, String description) async {
    String jsonContent = await rootBundle.loadString(abi);
    var contractABI = ContractABI.parseFromJSON(jsonContent, "LightBulbs");

    var contract = new DeployedContract(contractABI,
        new EthereumAddress(contractaddress), ethClient, credentials);

    var fnaddDevice = contract.findFunctionsByName("_addNewLightBulb").first;

    var res = await new Transaction(keys: credentials, maximumGas: 6521975)
        .prepareForCall(
            contract, fnaddDevice, [name, description]).send(ethClient);
    print(res.toString());
  }

  static Future<DeviceStatus> web3fetchdevicestatus(String id) async {
    String jsonContent = await rootBundle.loadString(abi);
    int ininum = int.parse(id);
    BigInt bid = BigInt.from(ininum);
    var contractABI = ContractABI.parseFromJSON(jsonContent, "LightBulbs");

    var contract = new DeployedContract(contractABI,
        new EthereumAddress(contractaddress), ethClient, credentials);

    var fnfetchdevicestatus =
        contract.findFunctionsByName('fetchDeviceStatus').first;

    var response = await Transaction(keys: credentials, maximumGas: 0)
        .prepareForCall(contract, fnfetchdevicestatus, [bid]).call(ethClient);
    var curdevice = new DeviceStatus.fromResponse(bid,response);
    return curdevice;
  }

  static Future<String> web3changedevicecolor(String id, String color) async {
    String jsonContent = await rootBundle.loadString(abi);
    int ininum = int.parse(id) + 1;
    BigInt bid = BigInt.from(ininum);
    var contractABI = ContractABI.parseFromJSON(jsonContent, "LightBulbs");

    var contract = new DeployedContract(contractABI,
        new EthereumAddress(contractaddress), ethClient, credentials);

    var fnchangedevicecolor =
        contract.findFunctionsByName("changeDeviceColor").first;

    var res = await new Transaction(keys: credentials, maximumGas: 6521975)
        .prepareForCall(
            contract, fnchangedevicecolor, [bid, color]).send(ethClient);
    if (res.toString().contains("[") && res.toString().contains("]")) {
      return "success";
    } else {
      return "fail";
    }
  }

  static Future<int> web3getnumberofdevice() async {
    String jsonContent = await rootBundle.loadString(abi);
    var contractABI = ContractABI.parseFromJSON(jsonContent, "LightBulbs");
    var contract = new DeployedContract(contractABI,
        new EthereumAddress(contractaddress), ethClient, credentials);

    var fngetnumberofdevice =
        contract.findFunctionsByName("getNumberOfdevices").first;

    var response = await Transaction(keys: credentials, maximumGas: 0)
        .prepareForCall(contract, fngetnumberofdevice, []).call(ethClient);

    print(response);
    int number = response[0].toInt();
    return number;
  }
}

class DeviceStatus {
  final BigInt bid;
  String  hash_id;
  String name; // front door
  String description; // for plug -> what to, where
  bool status; // true/false = on/off
  BigInt red; // 0-255
  BigInt green;
  BigInt blue;
  BigInt intensity; // 0-100

  DeviceStatus.fromResponse(this.bid, dynamic data) {
    hash_id = data[0] as String;
    name = data[1] as String;
    description = data[2] as String;
    status = data[3] as bool;
    red = data[4] as BigInt;
    green = data[5] as BigInt;
    blue = data[6] as BigInt;
    intensity = data[7] as BigInt;
  }

  @override
  String toString() {
    return name;
  }
}
