import 'dart:convert';
import 'dart:async';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iotdevices/class/event.dart';
import 'package:iotdevices/class/shareddata.dart';
import 'package:iotdevices/pages/adddevice.dart';
import 'package:iotdevices/pages/changeserver.dart';
import 'package:iotdevices/pages/detail.dart';
import 'package:iotdevices/web3/web3.dart';
import 'package:iotdevices/web3/web3p.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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

  Future<void> _scanBarcode() async {
    String barcodeScanRes;
    try {
      barcodeScanRes =
          await FlutterBarcodeScanner.scanBarcode('#ff0000', 'CANCEL', false);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      _barcode = barcodeScanRes;
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
    return Scaffold(
        appBar: AppBar(
          title: Text("Simulated Light Bulb Devices"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings),
              tooltip: 'Settings',
              onPressed: () {
                print(accountjson);
                Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (_, __, ___) => new ChangeServerPage(
                          img: accountjson,
                        ),
                    transitionDuration: Duration(milliseconds: 750),
                    transitionsBuilder:
                        (_, Animation<double> animation, __, Widget child) {
                      return Opacity(
                        opacity: animation.value,
                        child: child,
                      );
                    }));
              },
            ),
          ],
        ),
        body: Padding(
            padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Card(
                    color: Colors.greenAccent,
                    child: Container(
                      height: 30,
                      width: 300,
                      child: Center(
                        child: Text(
                          curnetwork + " Network",
                        ),
                      ),
                    )),
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                ),
                Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    height: 0.5,
                    color: Color(0xffDEDEDE),
                  ),
                ),
                loaded
                    ? Container(
                        height: 500.0,
                        child: ListView.builder(
                          itemCount: devicelist.length,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context, position) {
                            return Container(
                                height: 120.0,
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Column(
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  "Device Name:",
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(devicelist[position]
                                                    .name
                                                    .toString())
                                              ],
                                            ),
                                            Column(
                                              // crossAxisAlignment: CrossAxisAlignment.center,
                                              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                Text(
                                                  "Device Description:",
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(devicelist[position]
                                                    .description
                                                    .toString())
                                              ],
                                            ),
                                            Center(
                                              child: Container(
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 8.0),
                                                height: 0.5,
                                                color: Color(0xffDEDEDE),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: <Widget>[
                                            RaisedButton(
                                              child: const Text(
                                                'Detail',
                                                style: TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              onPressed: () {
                                                Navigator.of(
                                                        context)
                                                    .push(PageRouteBuilder(
                                                        pageBuilder: (_, __,
                                                                ___) =>
                                                            new DeviceDetailPage(
                                                                curdevice:
                                                                    devicelist[
                                                                        position]),
                                                        transitionDuration:
                                                            Duration(
                                                                milliseconds:
                                                                    750),
                                                        transitionsBuilder: (_,
                                                            Animation<double>
                                                                animation,
                                                            __,
                                                            Widget child) {
                                                          return Opacity(
                                                            opacity:
                                                                animation.value,
                                                            child: child,
                                                          );
                                                        }));
                                              },
                                            ),
                                            RaisedButton(
                                              child: const Text(
                                                'Delete',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              padding:
                                                  const EdgeInsets.all(3.0),
                                              onPressed: () {
                                                // _onCalculatePressed();
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Center(
                                      child: Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 8.0),
                                        height: 0.5,
                                        color: Color(0xffDEDEDE),
                                      ),
                                    ),
                                  ],
                                ));
                          },
                        ),
                      )
                    : Container(
                        child: Column(
                          children: <Widget>[
                            SpinKitFadingCircle(
                              itemBuilder: (_, int index) {
                                return DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: index.isEven
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                );
                              },
                            ),
                            Text("Connecting"),
                          ],
                        ),
                      )
              ],
            )),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FloatingActionButton(
                  tooltip: 'Scan QR Code',
                  child: Icon(Icons.camera),
                  heroTag: null,
                  onPressed: () {
                    _scanBarcode();
                  },
                ),
                FloatingActionButton(
                  tooltip: 'Refresh',
                  child: Icon(Icons.refresh),
                  heroTag: null,
                  onPressed: () {
                    _refresh();
                  },
                ),
                FloatingActionButton(
                  tooltip: 'Add New Device',
                  child: Icon(Icons.add),
                  heroTag: null,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddDevicePage()),
                    );
                  },
                ),
              ],
            ),
          ],
        ));
  }
}
