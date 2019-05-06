import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iotdevices/class/event.dart';
import 'package:iotdevices/pages/adddevice.dart';
import 'package:iotdevices/pages/detail.dart';
import 'package:iotdevices/web3/web3.dart';
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
  int devicenumber = 0;
  String _barcode = 'Unknown';
  List<DeviceStatus> devicelist = new List();

  _getDevicelist() async {
    devicelist = new List();
    int number = await Web3.web3getnumberofdevice();
    if (number != 0) {
      if (mounted) {
        setState(() {
          devicenumber = number;
        });
      }
      for (int i = 0; i < number; i++) {
        DeviceStatus curdevice = await Web3.web3fetchdevicestatus(i.toString());
        if (mounted) {
          setState(() {
            devicelist.add(curdevice);
          });
        }
      }
    }
  }

  _eventHandler() {
    Event.eventBus.on<DeviceAdd>().listen((event) {
      _getDevicelist();
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
    _getDevicelist();
    _eventHandler();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Light Bulb Devices"),
        ),
        body: Padding(
          padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0),
          child: Container(
            // height: 400.0,
            child: ListView.builder(
              itemCount: devicelist.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, position) {
                return Container(
                    height: 100.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Device Name:",
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(devicelist[position].name.toString())
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
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                    devicelist[position].description.toString())
                              ],
                            ),
                            Center(
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 8.0),
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
                                    fontWeight: FontWeight.bold),
                              ),
                              color: Theme.of(context).primaryColor,
                              padding: const EdgeInsets.all(8.0),
                              onPressed: () {
                                Navigator.of(context).push(PageRouteBuilder(
                                    pageBuilder: (_, __, ___) =>
                                        new DeviceDetailPage(
                                            curdevice: devicelist[position]),
                                    transitionDuration:
                                        Duration(milliseconds: 750),
                                    transitionsBuilder: (_,
                                        Animation<double> animation,
                                        __,
                                        Widget child) {
                                      return Opacity(
                                        opacity: animation.value,
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
                                    fontWeight: FontWeight.bold),
                              ),
                              color: Theme.of(context).primaryColor,
                              padding: const EdgeInsets.all(3.0),
                              onPressed: () {
                                // _onCalculatePressed();
                              },
                            ),
                          ],
                        ),
                      ],
                    ));
              },
            ),
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 8.0),
              child: FloatingActionButton(
                tooltip: 'Scan QR Code',
                child: Icon(Icons.camera),
                heroTag: null,
                onPressed: () {
                  _scanBarcode();
                },
              ),
            ),
            FloatingActionButton(
              tooltip: 'Add New Device',
              child: Icon(Icons.add),
              heroTag: null,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddDevicePage()),
                  // PageRouteBuilder(
                  //   pageBuilder: (_, __, ___) => new AddDevicePage(),
                  //   transitionDuration: Duration(milliseconds: 750),

                  //   /// Set animation with opacity
                  //   transitionsBuilder:
                  //       (_, Animation<double> animation, __, Widget child) {
                  //     return Opacity(
                  //       opacity: animation.value,
                  //       child: child,
                  //     );
                  //   })
                );
              },
            ), // This trailing comma makes auto-formatting nicer for build methods.
          ],
        ));
  }
}
