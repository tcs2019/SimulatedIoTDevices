import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:newuicontrollor/pages/login/address.dart';
import 'package:newuicontrollor/pages/login/password.dart';
import 'package:newuicontrollor/pages/login/qrcode.dart';

class InitPage extends StatefulWidget {
  @override
  _InitPageState createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {
  final globalKey = new GlobalKey<ScaffoldState>();
  bool auth = false;
  _check() async {
    var localAuth = LocalAuthentication();
    bool didAuthenticate = await localAuth.authenticateWithBiometrics(
        localizedReason: 'Please authenticate to unlock the app');
    print(didAuthenticate);
    setState(() {
      auth = didAuthenticate;
    });
    if (auth) {
      _nextstep();
    }
  }

  _nextstep() {
    Future.delayed(new Duration(seconds: 1), () {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => new AddressPage()));
    });
  }

  _autorun() {
    Timer(Duration(milliseconds: 2000), _navigatorPage);
  }

  // QR Code Scanner
  Future<void> _scanBarcode() async {
    String _barcode;
    try {
      _barcode = await BarcodeScanner.scan();
      // TODO: check shared pref if the person back home or leave
      globalKey.currentState.showSnackBar(new SnackBar(
        content: new Text('Welcome home, ' + _barcode),
      ));
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        _barcode = 'The user did not grant the camera permission!';
      } else {
        _barcode = 'Unknown error: $e';
      }
    } on FormatException {
      _barcode =
          'null (User returned using the "back"-button before scanning anything. Result)';
    } catch (e) {
      _barcode = 'Unknown error: $e';
    }
  }

  void _navigatorPage() {
    _check();
  }

  @override
  void initState() {
    _autorun();
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
                                "Use your Fingerprint or FaceID to get started:",
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
                            Center(
                              child: auth
                                  ? Icon(
                                      Icons.check,
                                      size: 100.0,
                                      color: Colors.blue,
                                    )
                                  : Icon(
                                      Icons.close,
                                      size: 100.0,
                                      color: Colors.redAccent,
                                    ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 40.0, left: 20.0, bottom: 20.0),
                              child: auth
                                  ? Text(
                                      "You are good to go!",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 19.0,
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () {
                                        _check();
                                      },
                                      child: Text(
                                        "Click to Authenticate again",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 19.0,
                                        ),
                                      ),
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
          // if (auth) {
          //   _nextstep();
          // } else {
          //   globalKey.currentState.showSnackBar(new SnackBar(
          //     content:
          //         new Text("Use your Fingerprint or FaceID to get started."),
          //   ));
          // }
          _scanBarcode();
        },
        tooltip: 'Scan QR Code',
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}
