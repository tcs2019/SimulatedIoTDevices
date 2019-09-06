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
