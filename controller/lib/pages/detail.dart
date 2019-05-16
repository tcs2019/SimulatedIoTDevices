import 'dart:async';
import 'dart:convert';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_colorpicker/material_picker.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:flutter_colorpicker/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:iotdevices/class/color.dart';
import 'package:iotdevices/class/device.dart';
import 'package:iotdevices/class/event.dart';
import 'package:iotdevices/class/shareddata.dart';
import 'package:iotdevices/pages/adddevice.dart';
import 'package:iotdevices/web3/web3.dart';
import 'package:iotdevices/web3/web3p.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:math';
import 'dart:ui';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

class DeviceDetailPage extends StatefulWidget {
  DeviceStatus curdevice;
  DeviceDetailPage({Key key, @required this.curdevice}) : super(key: key);
  @override
  _DeviceDetailPageState createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  final globalKey = new GlobalKey<ScaffoldState>();
  DeviceStatus curdevices;
  StreamSubscription<FilterEvent> subscription;
  Web3Client client;
  String network;

  Color currentColor = const Color(0xff443a49);
  double _value = 0.0;
  double percentage;
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

  _listenevent() async {
    network = await SharedData.getNetwork();
    DeployedContract contract;
    var apiUrl = Web3P.apiUrl;
    if (network == "Private") {
      contract = await Web3P.deployedcontract();
      String serveraddress = await SharedData.getServerAddress();
      if (serveraddress.length > 5) {
        apiUrl = serveraddress;
      }
      client = Web3Client(apiUrl, Client());
      final colorChangeEvent = contract.event('ColorChange');
      subscription = client
          .events(
              FilterOptions.events(contract: contract, event: colorChangeEvent))
          .take(1)
          .listen((event) {
        final decoded =
            colorChangeEvent.decodeResults(event.topics, event.data);

        final deviceid = decoded[0] as String;
        final red = decoded[1] as BigInt;
        final green = decoded[2] as BigInt;
        final blue = decoded[3] as BigInt;
        print("event:ID:$deviceid");
        print("event:red:${red.toInt()}");
        print("event:green:${green.toInt()}");
        print("event:blue:${blue.toInt()}");
        var curid = widget.curdevice.bid.toInt().toString();
        if (deviceid.contains(curid)) {
          print("this device changed!");
          var devcolor =
              TransColor.trancolor(red.toInt(), green.toInt(), blue.toInt());
          // print(widget.curdevice.green);
          if (mounted) {
            setState(() {
              currentColor = Color(devcolor);
            });
          }
          Event.eventBus.fire(new DeviceAdd(curdevices.name));
        }
      });
      await subscription.asFuture();
    } else if (network == "Public") {
      print("Listening to public");
      var channel = IOWebSocketChannel.connect("wss://ropsten.infura.io/ws/v3/4164c4424c7d465daab94864544fa622");

      channel.stream.listen((message) {
        print(message);
        channel.sink.add("received!");
        channel.sink.close(status.goingAway);
      });
    }
  }

  _webchangecolor() async {
    RGB color = TransColor.trancolortorgb(currentColor.toString());
    String res;
    if (network == "Private") {
      res = await Web3P.web3changedevicecolor(curdevices.bid, color);
    } else {
      res = await Web3.web3changedevicecolor(curdevices.bid, color);
    }

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
    var devcolor = TransColor.trancolor(widget.curdevice.red.toInt(),
        widget.curdevice.green.toInt(), widget.curdevice.blue.toInt());
    if (mounted) {
      setState(() {
        curdevices = widget.curdevice;
        currentColor = Color(devcolor);
      });
    }
    print("ID is ${widget.curdevice.bid}");
  }

  @override
  void initState() {
    _fetchdevicestatus();
    _listenevent();
    super.initState();
  }

  @override
  void dispose() {
    subscription.cancel();
    client.dispose();
    super.dispose();
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
                // Container(
                //   height: 200,
                //   width: 200,
                //   child: RaisedButton(
                //     elevation: 3.0,
                //     onPressed: () {
                //       showDialog(
                //         context: context,
                //         builder: (BuildContext context) {
                //           return AlertDialog(
                //             title: Text('Select a color'),
                //             content: SingleChildScrollView(
                //               child: BlockPicker(
                //                 pickerColor: currentColor,
                //                 onColorChanged: changeColorAndPopout,
                //               ),
                //             ),
                //           );
                //         },
                //       );
                //     },
                //     child: const Text('Change me'),
                //     color: currentColor,
                //     textColor: useWhiteForeground(currentColor)
                //         ? const Color(0xffffffff)
                //         : const Color(0xff000000),
                //   ),
                // ),
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                ),
                // Row(
                //   children: <Widget>[
                //     Text("Intensity"),
                //     Column(
                //       children: <Widget>[
                //         Text('Value: ${(_value * 100).round()}'),
                //         Slider(value: _value, onChanged: _setvalue),
                //       ],
                //     )
                //   ],
                // )
                // Center(
                //     child: new Container(
                //         height: 200.0,
                //         width: 200.0,
                //         child: new CustomPaint(
                //             foregroundPainter: new MyPainter(
                //                 lineColor: Colors.amber,
                //                 completeColor: Colors.blueAccent,
                //                 completePercent: percentage,
                //                 width: 8.0),
                //             child: new Padding(
                //               padding: const EdgeInsets.all(8.0),
                //               child: new RaisedButton(
                //                   color: currentColor,
                //                   splashColor: Colors.blueAccent,
                //                   shape: new CircleBorder(),
                //                   child: new Text("Light"),
                //                   onPressed: () {
                //                     // setState(() {
                //                     //   percentage += 10.0;
                //                     //   if (percentage > 100.0) {
                //                     //     percentage = 0.0;
                //                     //   }
                //                     // }
                //                     // );
                //                   }),
                //             )))),
                Center(
                  child: InkWell(
                    onTap: () {
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
                          });
                    },
                    child: Container(
                      width: 250.0,
                      height: 250.0,
                      // padding: const EdgeInsets.all(
                      //     20.0), //I used some padding without fixed width and height
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentColor,
                      ),
                      child: new Text("",
                          style: new TextStyle(
                              color: Colors.white, fontSize: 50.0)),
                    ),
                  ),
                ), //
              ],
            )),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  Color lineColor;
  Color completeColor;
  double completePercent;
  double width;
  MyPainter(
      {this.lineColor, this.completeColor, this.completePercent, this.width});
  @override
  void paint(Canvas canvas, Size size) {
    Paint line = new Paint()
      ..color = lineColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    Paint complete = new Paint()
      ..color = completeColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    Offset center = new Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius, line);
    double arcAngle = 2 * pi * (completePercent / 100);
    canvas.drawArc(new Rect.fromCircle(center: center, radius: radius), -pi / 2,
        arcAngle, false, complete);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
