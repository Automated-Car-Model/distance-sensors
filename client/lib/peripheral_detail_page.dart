import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_blue/quick_blue.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sensors_page.dart';
import 'globals.dart';

class PeripheralDetailPage extends StatefulWidget {
  final String deviceId;
  final String deviceName;

  const PeripheralDetailPage(this.deviceId, this.deviceName, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PeripheralDetailPageState();
}

class _PeripheralDetailPageState extends State<PeripheralDetailPage> {
  //create here an object of type globals that contains all the variables and need to be exchanged between pages
  Globals globals = Globals();
  bool isConnected = false;
  bool isConnecting = false;

  @override
  void initState() {
    super.initState();

    globals.deviceId = widget.deviceId;

    QuickBlue.setConnectionHandler(_handleConnectionChange);
    QuickBlue.setServiceHandler(_handleServiceDiscovery);
    QuickBlue.setValueHandler(_handleValueChange);

    //inizialize shared preferences used also when you close the app and open it again
    createSharedPreferences();
  }

  @override
  void dispose() {
    super.dispose();

    QuickBlue.setValueHandler(null);
    QuickBlue.setServiceHandler(null);
    QuickBlue.setConnectionHandler(null);
  }

  // Retrieve configuration variables from SharedPreferences
  Future<void> createSharedPreferences() async {
    globals.prefs = await SharedPreferences.getInstance();
  }

  void _handleConnectionChange(String deviceId, BlueConnectionState state) {
    if (kDebugMode) {
      print('_handleConnectionChange $deviceId, $state');
    }
  }

  List<String> services = [];
  Map<String, List<String>> characteristics = {};

  void _handleServiceDiscovery(
      String deviceId, String serviceId, List<String> characteristicIds) {
    if (kDebugMode) {
      print(
          '_handleServiceDiscovery $deviceId, $serviceId, $characteristicIds');
    }

    // Update the list of services
    setState(() {
      services = [...services, serviceId];
      characteristics[serviceId] = characteristicIds;
    });
  }

  void _handleValueChange(
      String deviceId, String characteristicId, Uint8List value) {
    if (kDebugMode) {
      print(
          '_handleValueChange $deviceId, $characteristicId, ${hex.encode(value)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deviceName),
      ),
      body: Column(
        children: [
          Row(
            //connect and disconnect buttons
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: isConnecting
                    ? null
                    : () {
                        if (!isConnected) {
                          QuickBlue.connect(widget.deviceId);

                          setState(() {
                            isConnecting = true;
                          });

                          Future.delayed(Duration(seconds: 1), () {
                            setState(() {
                              isConnected = true;
                              isConnecting = false;
                            });
                          });
                        } else {
                          QuickBlue.disconnect(widget.deviceId);

                          setState(() {
                            isConnected = false;
                          });
                        }
                      },
                child: isConnecting
                    ? Text('Connecting...')
                    : (isConnected ? Text('Disconnect') : Text('Connect')),
              ),
            ],
          ),
          SizedBox(height: 25),
          Row(
            //go to the startPage page trasmitting globals.
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: isConnected
                    ? () {
                        QuickBlue.discoverServices(globals.deviceId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SensorsPage(globals: globals),
                          ),
                        );
                      }
                    : null,
                child: Text('Go to sensors page'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
