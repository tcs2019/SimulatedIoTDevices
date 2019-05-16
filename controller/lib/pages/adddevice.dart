import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iotdevices/class/event.dart';
import 'package:iotdevices/class/shareddata.dart';
import 'package:iotdevices/web3/web3.dart';
import 'package:iotdevices/web3/web3p.dart';

class AddDevicePage extends StatefulWidget {
  @override
  _AddDevicePageState createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  final globalKey = new GlobalKey<ScaffoldState>();
  TextEditingController namecontroller = new TextEditingController(text: "");
  TextEditingController descontroller = new TextEditingController(text: "");
  TextEditingController deviceidcontroller =
      new TextEditingController(text: "");
  bool light = false;
  bool added = true;

  void _adddevice() async {
    setState(() {
      added = false;
    });
    // int devicenumber = await Web3.web3getnumberofdevice();
    // print(devicenumber);
    // var now = new DateTime.now();
    // String timenow = now.toString();
    String network = await SharedData.getNetwork();
    String res;
    String res2;
    if (network == "Private") {
      res = await Web3P.web3adddevice(namecontroller.text, descontroller.text);
      res2 = await Web3.web3adddevice(namecontroller.text, descontroller.text);
    } else if (network == "Public") {
      res2 = await Web3.web3adddevice(namecontroller.text, descontroller.text);
    }

    if (res == "success" || res2 == "success") {
      globalKey.currentState.showSnackBar(new SnackBar(
        content: new Text("Added successfully!"),
      ));
      // var newdevice = new Device(
      //     name: namecontroller.text,
      //     description: descontroller.text,
      //     deviceid: deviceidcontroller.text,
      //     classnum: bigclass.toString(),
      //     switchon: 100.toString());

      // String jsonString = json.encode(newdevice);
      // print(jsonString);
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // List<String> devices = new List();

      // devices.addAll(prefs.getStringList('devices'));
      // devices.add(jsonString);

      // prefs.setStringList('devices', devices);
      setState(() {
        added = true;
      });

      Event.eventBus.fire(new DeviceAdd(namecontroller.text));

      Future.delayed(new Duration(seconds: 3), () {
        Navigator.pop(context);
      });
    } else {
      globalKey.currentState.showSnackBar(new SnackBar(
        content: new Text("Something wrong!"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppBar(
        title: Text("Add new device"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            tooltip: 'Settings',
            onPressed: () {
              _adddevice();
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(left: 20.0, right: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: namecontroller,
                enabled: true,
                obscureText: false,
                decoration: InputDecoration(
                  labelText: "Device Name",
                  labelStyle: TextStyle(
                      fontSize: 18.0,
                      letterSpacing: 0.3,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
                keyboardType: TextInputType.text,
              ),
              TextFormField(
                controller: descontroller,
                enabled: true,
                obscureText: false,
                decoration: InputDecoration(
                  labelText: "Device Description",
                  labelStyle: TextStyle(
                      fontSize: 18.0,
                      letterSpacing: 0.3,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
                keyboardType: TextInputType.text,
              ),
              TextFormField(
                controller: deviceidcontroller,
                enabled: true,
                obscureText: false,
                decoration: InputDecoration(
                  labelText: "Device ID",
                  labelStyle: TextStyle(
                      fontSize: 18.0,
                      letterSpacing: 0.3,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
                keyboardType: TextInputType.text,
              ),
              Row(
                children: <Widget>[
                  Text("Light"),
                  Switch(
                    value: light,
                    activeColor: Colors.white,
                    onChanged: (bool val) {
                      this.setState(() {
                        this.light = !this.light;
                      });
                    },
                  ),
                  Text("Plugs"),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 50),
              ),
              added
                  ? Container(
                      height: 70.0,
                    )
                  : Container(
                      height: 70.0,
                      child: Column(
                        children: <Widget>[
                          SpinKitFadingCircle(
                            itemBuilder: (_, int index) {
                              return DecoratedBox(
                                decoration: BoxDecoration(
                                  color:
                                      index.isEven ? Colors.red : Colors.green,
                                ),
                              );
                            },
                          ),
                          Text("Adding new device"),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _adddevice,
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ),
    );
  }
}

class DeviceAdd {
  String device;
  DeviceAdd(this.device);
}
