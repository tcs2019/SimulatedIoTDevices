import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iotdevices/class/device.dart';
import 'package:iotdevices/class/event.dart';
import 'package:iotdevices/pages/adddevice.dart';
import 'package:iotdevices/pages/detail.dart';
import 'package:iotdevices/web3/web3.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
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

  @override
  void initState() {
    _getDevicelist();
    _eventHandler();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
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
                              Text(devicelist[position].description.toString())
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(PageRouteBuilder(
              pageBuilder: (_, __, ___) => new AddDevicePage(),
              transitionDuration: Duration(milliseconds: 750),

              /// Set animation with opacity
              transitionsBuilder:
                  (_, Animation<double> animation, __, Widget child) {
                return Opacity(
                  opacity: animation.value,
                  child: child,
                );
              }));
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
