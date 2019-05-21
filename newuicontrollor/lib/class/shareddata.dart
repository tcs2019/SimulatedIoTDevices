import 'package:shared_preferences/shared_preferences.dart';

class SharedData {
  static Future setContractAddress(String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("ContractAddress", path);
  }

  static Future<String> getContractAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("getting ContractAddress");
    return prefs.getString("ContractAddress");
  }

  static Future setKeystoreFilePath(String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("KeystoreFilePath", path);
  }

  static Future<String> getKeystoreFilePath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("getting KeystoreFilePath");
    return prefs.getString("KeystoreFilePath");
  }

  static Future setABIFilePath(String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("ABIFilePath", path);
  }

  static Future<String> getABIFilePath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("getting ABIFilePath");
    return prefs.getString("ABIFilePath");
  }

  static Future<String> saveServerAddress(String address) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("ServerAddress", address);
    print(address);
    return "success";
  }

  static Future<String> getServerAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("getting address");
    return prefs.getString("ServerAddress");
  }

  static Future setNetwork(String net) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("Network", net);
  }

  static Future<String> getNetwork() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("getting network");
    return prefs.getString("Network");
  }

  static Future setNotFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool("isFirstTime", false);
  }

  static Future<bool> isFirstTimeUse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("checking if first time");
    return prefs.getBool("isFirstTime");
  }

  static Future saveAccountJson(String account) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString("AccountJson", account);
  }

  static Future<String> getAccountJson() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("getting AccountJson");
    return prefs.getString("AccountJson");
  }

  static Future saveAccountPassword(String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("setting password");
    return prefs.setString("AccountPassword", password);
  }

  static Future<String> getAccountPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("getting AccountPassword");
    return prefs.getString("AccountPassword");
  }
}
