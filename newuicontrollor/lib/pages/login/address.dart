import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:newuicontrollor/class/serverapi.dart';
import 'package:newuicontrollor/class/shareddata.dart';
import 'package:newuicontrollor/pages/login/password.dart';
import 'package:http/http.dart' as http;

class AddressPage extends StatefulWidget {
  @override
  _AddressPageState createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final globalKey = new GlobalKey<ScaffoldState>();
  bool loaded = true;
  bool success = false;
  TextEditingController addresscontroller =
      new TextEditingController(text: "http://");
  _fetchdata() async {
    print("Fetching data from server");
    setState(() {
      loaded = false;
    });
    String res;
    int ippos = addresscontroller.text.indexOf("://");
    int iplast = addresscontroller.text.lastIndexOf(":");
    String ip = addresscontroller.text.substring(ippos + 3, iplast);
    print(ip);
    List<ServerAPI> list = List();
    ServerAPI serverdata = new ServerAPI();
    try {
      final response = await http
          .get("http://$ip:3000/LightBulbs.json")
          .timeout(Duration(seconds: 5));
      res = response.body.toString();
      print(res.length);
      int firstk = res.indexOf("[");
      int lastk = res.lastIndexOf("]");
      print(lastk);
      String abi = res.substring(firstk,lastk+1);
      print(abi.length);
      print(abi);

    } on SocketException {
      print("error");
    } on TimeoutException {
      print("timeout");
    }
    // print(serverdata);
    success = true;
    if (res != null) {
      success = true;
    }
    //TODO: delete that
    else {
      success = true;
    }
  }

  _fetchserver() async {
    String address = await SharedData.getServerAddress();
    if (address.length > 10) {
      setState(() {
        addresscontroller.text = address;
      });
    }
  }

  @override
  void initState() {
    _fetchserver();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/img/0.jpg'), fit: BoxFit.cover)),
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                Color.fromRGBO(0, 0, 0, 0.3),
                Color.fromRGBO(0, 0, 0, 0.4)
              ],
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter)),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 30.0),
                    ),

                    /// Text header "Welcome To" (Click to open code)
                    Text(
                      "Welcome to",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w200,
                        fontSize: 19.0,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                    ),
                    Text(
                      "Smart Home",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 35.0,
                        letterSpacing: 0.4,
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 30.0),
                    ),
                    Container(
                      height: 300.0,
                      width: 300.0,
                      child: Card(
                        elevation: 5.0,
                        color: Colors.white24,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(top: 20.0),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.0),
                              child: Text(
                                "Input the Home server address:",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 19.0,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 30.0),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 30.0),
                              child: TextFormField(
                                controller: addresscontroller,
                                enabled: true,
                                obscureText: false,
                                decoration: InputDecoration(
                                  labelText: "Home server Address",
                                  labelStyle: TextStyle(
                                      fontSize: 18.0,
                                      letterSpacing: 0.3,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600),
                                ),
                                keyboardType: TextInputType.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (addresscontroller.text.length > 10) {
            SharedData.saveServerAddress(addresscontroller.text);
            _fetchdata();
            Future.delayed(new Duration(seconds: 5), () {
              if (success) {
                globalKey.currentState.showSnackBar(new SnackBar(
                  content: new Text("Download data successfully"),
                ));
                Future.delayed(new Duration(seconds: 1), () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => new PasswordPage()));
                });
              }
            });
          } else {
            globalKey.currentState.showSnackBar(new SnackBar(
              content: new Text("Please input the correct address"),
            ));
          }
        },
        tooltip: 'Next Step',
        child: Icon(Icons.keyboard_arrow_right),
      ),
    );
  }
}
