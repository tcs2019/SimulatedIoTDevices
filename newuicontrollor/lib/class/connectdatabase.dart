import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ConnectData {
  static Future<List<Block>> getblock() async {
    List<Block> list = List(3);
    final response = await http
        .get("http://www.lightningrepair.com.au/smarthomephp/readblock.php");

    list = (json.decode(response.body) as List)
        .map((data) => new Block.fromJson(data))
        .toList();
    return list;
  }

///////////////////////////////////////////////////////////////////////////////
  static Future<List<int>> getblocklog() async {
    List<Blocklog> list = List(5);
    List<int> blockstimestamp = new List(5);
    final response = await http
        .get("http://www.lightningrepair.com.au/smarthomephp/readblocklog.php");

    list = (json.decode(response.body) as List)
        .map((data) => new Blocklog.fromJson(data))
        .toList();

    for (int i = 0; i < list.length; i++) {
      String blocktimestring = list[i].blocktime;
      if (blocktimestring.length >= 2) {
        List<String> blocktimesplit = blocktimestring.split(":");
        DateTime blocktime = DateTime(
            2019,
            int.parse(blocktimesplit[0]),
            int.parse(blocktimesplit[1]),
            int.parse(blocktimesplit[2]),
            int.parse(blocktimesplit[3]),
            int.parse(blocktimesplit[4]),
            int.parse(blocktimesplit[5]));
        blockstimestamp[i] = blocktime.millisecondsSinceEpoch;
      }
    }
    return blockstimestamp;
  }

  ///////////////////////////////////////////////////////////////////////////////
  static Future<List<int>> gettransactionlog() async {
    List<Transactionlog> list = List(5);
    List<int> transactionstimestamp = new List(5);
    final response = await http.get(
        "http://www.lightningrepair.com.au/smarthomephp/readtransactionlog.php");

    list = (json.decode(response.body) as List)
        .map((data) => new Transactionlog.fromJson(data))
        .toList();

            for (int i = 0; i < list.length; i++) {
      String blocktimestring = list[i].transactiontime;
      if (blocktimestring.length >= 2) {
        List<String> blocktimesplit = blocktimestring.split(":");
        DateTime blocktime = DateTime(
            2019,
            int.parse(blocktimesplit[0]),
            int.parse(blocktimesplit[1]),
            int.parse(blocktimesplit[2]),
            int.parse(blocktimesplit[3]),
            int.parse(blocktimesplit[4]),
            int.parse(blocktimesplit[5]));
        transactionstimestamp[i] = blocktime.millisecondsSinceEpoch;
      }
    }
    return transactionstimestamp;
  }
}

///////////////////////////////////////////////////////////////////////////////
class Block {
  int blockid;
  int blocktime;

  Block({this.blockid, this.blocktime});

  Block.fromJson(Map<String, dynamic> json) {
    blockid = int.parse(json['blockid']);
    blocktime = int.parse(json['blocktime']);
    print("=====blocktime from database is $blocktime");
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['blockid'] = this.blockid;
    data['blocktime'] = this.blocktime;
    return data;
  }
}

class Blocklog {
  int blockid;
  String blocktime;

  Blocklog({this.blockid, this.blocktime});

  Blocklog.fromJson(Map<String, dynamic> json) {
    blockid = int.parse(json['blockid']);
    blocktime = json['blocktime'];
    print("=====blocktimelog from database is $blocktime");
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['blockid'] = this.blockid;
    data['blocktime'] = this.blocktime;
    return data;
  }
}

class Transactionlog {
  int transactionid;
  String transactiontime;

  Transactionlog({this.transactionid, this.transactiontime});

  Transactionlog.fromJson(Map<String, dynamic> json) {
    transactionid = int.parse(json['transactionid']);
    transactiontime = json['transactiontime'];
    print("=====transactiontimelog from database is $transactiontime");
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['transactionid'] = this.transactionid;
    data['transactiontime'] = this.transactiontime;
    return data;
  }
}
