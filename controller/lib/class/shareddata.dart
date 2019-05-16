import 'package:shared_preferences/shared_preferences.dart';

class SharedData {
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
}
