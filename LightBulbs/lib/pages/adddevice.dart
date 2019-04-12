import 'package:flutter/material.dart';
import 'package:iotdevices/class/event.dart';
import 'package:iotdevices/web3/web3.dart';

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

  void _adddevice() async {
    int devicenumber = await Web3.web3getnumberofdevice();
    print(devicenumber);
    // var now = new DateTime.now();
    // String timenow = now.toString();

    await Web3.web3adddevice(namecontroller.text, descontroller.text);
    int devicenumber2 = await Web3.web3getnumberofdevice();
    print(devicenumber2);

    if (devicenumber2 > devicenumber) {
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
      Event.eventBus.fire(new DeviceAdd(namecontroller.text));
      Future.delayed(new Duration(seconds: 1), () {
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
      ),
      body: Center(
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
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adddevice,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class DeviceAdd {
  String device;
  DeviceAdd(this.device);
}
