import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:newuicontrollor/class/event.dart';
import 'package:newuicontrollor/class/shareddata.dart';
import 'package:newuicontrollor/pages/setting/changeserver.dart';
import 'package:newuicontrollor/web3/web3.dart';
import 'package:newuicontrollor/web3/web3p.dart';

import 'addlight.dart';

var images = ["assets/img/light.png", "assets/img/light.png"];
var title = ["Lights", "Smart Tv"];

class LightsHomePage extends StatefulWidget {
  @override
  _LightsHomePageState createState() => _LightsHomePageState();
}

class _LightsHomePageState extends State<LightsHomePage> {
  bool loaded = false;
  bool private = true;
  String accountjson;
  var account = './assets/abi/account.json';
  int devicenumber = 0;
  int number;
  String _barcode = 'Unknown';
  String curnetwork = 'Getting';
  List<DeviceStatus> devicelist = new List();

  _getDevicelist() async {
    devicelist.clear();
    setState(() {
      loaded = false;
    });
    String readaccountjson = await rootBundle.loadString(account);
    String network = await SharedData.getNetwork();
    setState(() {
      curnetwork = network;
    });
    print(network);
    print(devicenumber);
    if (devicenumber != 0) {
      for (int i = 0; i < number; i++) {
        if (network == "Private") {
          DeviceStatus curdevice =
              await Web3P.web3fetchdevicestatus(i.toString());
          if (mounted) {
            setState(() {
              devicelist.add(curdevice);
            });
          }
        } else {
          DeviceStatus curdevice =
              await Web3.web3fetchdevicestatus(i.toString());
          if (mounted) {
            setState(() {
              devicelist.add(curdevice);
            });
          }
        }
      }
    }
    if (devicelist != null) {
      setState(() {
        loaded = true;
      });
    }
    if (readaccountjson != null) {
      if (mounted) {
        setState(() {
          accountjson = "http://qr.topscan.com/api.php?text=" + readaccountjson;
        });
      }
    }
  }

  _getNetwork() async {
    SharedData.setNetwork("null");
    var address = await SharedData.getServerAddress();
    if (address == null) {
      SharedData.saveServerAddress("");
    }
    devicelist = new List();
    try {
      number = await Web3P.web3getnumberofdevice();
    } on PlatformException {
      print("Wrong");
    }

    print("......$number");
    if (number == null) {
      setState(() {
        private = false;
      });
      number = await Web3.web3getnumberofdevice();
      if (number == null) {
      } else {
        setState(() {
          devicenumber = number;
        });
        SharedData.setNetwork("Public");
      }
    } else {
      setState(() {
        devicenumber = number;
      });
      SharedData.setNetwork("Private");
    }
    _getDevicelist();
  }

  _refresh() {
    _getNetwork();
  }

  _eventHandler() async {
    Event.eventBus.on<DeviceAdd>().listen((event) {
      Future.delayed(new Duration(seconds: 5), () {
        _getDevicelist();
      });
    });
    Event.eventBus.on<ServerChanged>().listen((event) {
      Future.delayed(new Duration(seconds: 5), () {
        _getNetwork();
      });
    });
  }

  @override
  void initState() {
    _getNetwork();
    _eventHandler();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.lightGreen[200], //Color(0xFFA4B4A9)
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Positioned(
              bottom: 0,
              right: 0,
              child: Image.asset("assets/img/lamp.png"),
            ),
            Positioned(
              top: 80,
              left: 25,
              right: 25,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.home, color: Colors.white, size: 30),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon:
                            Icon(Icons.settings, color: Colors.white, size: 30),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new ChangeServerPage(
                                    img: accountjson,
                                  )));
                        },
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Smart Home Lights",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 50,
                    ),
                  ),
                  Text("$devicenumber Lights Deployed",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      )),
                  SizedBox(
                    height: 80,
                  ),
                  Container(
                    width: 140,
                    height: 35,
                    decoration: BoxDecoration(
                        color: Color(0xFFFF9B52),
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.network_wifi,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(curnetwork + " Network",
                            style: TextStyle(
                              color: Colors.white,
                            ))
                      ],
                    ),
                  )
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(left: 30, bottom: 50),
                child: SizedBox(
                  height: 270,
                  child: ListView.builder(
                    itemCount: devicelist.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding:
                            EdgeInsets.only(left: 16, right: 8, bottom: 40),
                        child: Container(
                          width: 180,
                          height: 250,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black12,
                                    offset: Offset(0, 10),
                                    blurRadius: 10)
                              ]),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                    color: Color(0xFFECECEC),
                                    shape: BoxShape.circle),
                                child: Image.asset(images[0]),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(devicelist[index].name,
                                  style: TextStyle(
                                    fontSize: 22,
                                  ))
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              left: 140,
              bottom: 10,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => new AddLightPage()));
                },
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Container(
                    width: 170,
                    height: 35,
                    decoration: BoxDecoration(
                        color: Color(0xFFFF9B52),
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          "Add new Light",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}