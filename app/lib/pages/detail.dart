import 'dart:async';
import 'dart:convert';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_colorpicker/material_picker.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:flutter_colorpicker/utils.dart';
import 'package:flutter/material.dart';
import 'package:iotdevices/class/color.dart';
import 'package:iotdevices/class/device.dart';
import 'package:iotdevices/class/event.dart';
import 'package:iotdevices/pages/adddevice.dart';
import 'package:iotdevices/web3/web3.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceDetailPage extends StatefulWidget {
  DeviceStatus curdevice;
  DeviceDetailPage({Key key, @required this.curdevice}) : super(key: key);
  @override
  _DeviceDetailPageState createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  final globalKey = new GlobalKey<ScaffoldState>();
  DeviceStatus curdevices;

  Color currentColor = const Color(0xff443a49);
  double _value = 0.0;
  void _setvalue(double value) => setState(() => _value = value);

  void changeColorAndPopout(Color color) async {
    setState(() {
      currentColor = color;
    });
    // print(color.toString());

    Timer(const Duration(milliseconds: 500), () => Navigator.of(context).pop());
    Future.delayed(new Duration(seconds: 1), () {
      _webchangecolor();
    });
  }

  _webchangecolor() async {
    RGB color = TransColor.trancolortorgb(currentColor.toString());

    String res = await Web3.web3changedevicecolor(curdevices.bid, color);
    if (res == "success") {
      globalKey.currentState.showSnackBar(new SnackBar(
        content: new Text("Change the color successfully!"),
      ));
      Event.eventBus.fire(new DeviceAdd(curdevices.name));
    } else {
      globalKey.currentState.showSnackBar(new SnackBar(
        content: new Text("Something wrong!"),
      ));
    }
  }

  _fetchdevicestatus() {
    // int color = TransColor.trancolor(widget.curdevice.red);
    // var red = widget.curdevice.red;
    // print(red);
    var devcolor = TransColor.trancolor(widget.curdevice.red.toInt(),
        widget.curdevice.green.toInt(), widget.curdevice.blue.toInt());
    // print(widget.curdevice.green);
    if (mounted) {
      setState(() {
        curdevices = widget.curdevice;
        currentColor = Color(devcolor);
      });
    }
    // print(currentColor.toString());

    print("ID is ${widget.curdevice.bid}");
  }

  @override
  void initState() {
    _fetchdevicestatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppBar(
        title: Text("Device Detail"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {},
          )
        ],
      ),
      body: Center(
        child: Container(
            height: 800,
            width: 600,
            child: Column(
              children: <Widget>[
                Container(
                  height: 200,
                  width: 200,
                  child: RaisedButton(
                    elevation: 3.0,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Select a color'),
                            content: SingleChildScrollView(
                              child: BlockPicker(
                                pickerColor: currentColor,
                                onColorChanged: changeColorAndPopout,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: const Text('Change me'),
                    color: currentColor,
                    textColor: useWhiteForeground(currentColor)
                        ? const Color(0xffffffff)
                        : const Color(0xff000000),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                ),
                Row(
                  children: <Widget>[
                    Text("Intensity"),
                    Column(
                      children: <Widget>[
                        Text('Value: ${(_value * 100).round()}'),
                        Slider(value: _value, onChanged: _setvalue),
                      ],
                    )
                  ],
                )
              ],
            )),
      ),
    );
  }
}
