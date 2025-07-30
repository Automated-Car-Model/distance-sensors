import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart';
import 'package:quick_blue/quick_blue.dart';

import 'peripheral_detail_page.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<BlueScanResult>? _subscription;

  Map<int, Icon> rssiIcons = {
    -90: Icon(
      Icons.signal_cellular_alt_1_bar,
      color: const Color.fromARGB(255, 255, 17, 0),
    ),
    -80: Icon(
      Icons.signal_cellular_alt_2_bar,
      color: const Color.fromARGB(255, 255, 230, 0),
    ),
    -70: Icon(
      Icons.signal_cellular_alt,
      color: const Color.fromARGB(255, 26, 255, 33),
    ),
  };
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    // Force orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    if (kDebugMode) {
      QuickBlue.setLogger(Logger('proximity_sensors'));
    }

    //search for devices and choice only the device with a name
    _subscription = QuickBlue.scanResultStream.listen((result) {
      int i = 0;
      if (!_scanResults.any((r) {
        bool isActualDevice = r.deviceId == result.deviceId;

        if (isActualDevice) {
          setState(() => _scanResults[i].rssi = result.rssi);
        }

        return isActualDevice;
      })) {
        if (result.name != "") {
          setState(() => _scanResults.add(result));
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }

  Widget getSignalWidget(int rssi) {
    for (MapEntry<int, Icon> rssiIcon in rssiIcons.entries) {
      if (rssiIcon.key >= rssi) return rssiIcon.value;
    }

    return rssiIcons.values.last;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Discover Devices'),
        ),
        body: Column(
          children: [
            FutureBuilder(
              future: QuickBlue.isBluetoothAvailable(),
              builder: (context, snapshot) {
                String available = snapshot.data?.toString() ?? '...';
                return Text(
                    'Bluetooth status: ${available == 'true' ? 'Enabled' : 'Disabled'}');
              },
            ),
            _buildButtons(),
            Divider(
              color: Colors.blue,
            ),
            _buildListView(),
            _buildPermissionWarning(),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        ElevatedButton(
          child: isScanning ? Text('Stop scan') : Text('Start scan'),
          onPressed: () async {
            if (!isScanning && !await Geolocator.isLocationServiceEnabled()) {
              if (mounted) {
                Fluttertoast.showToast(
                    msg: "GPS is not enabled",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                    textColor: Colors.white,
                    fontSize: 16.0);
              }
              return;
            }

            setState(() {
              isScanning = !isScanning;
            });

            if (isScanning) {
              QuickBlue.startScan();
            } else {
              QuickBlue.stopScan();
            }
          },
        ),
      ],
    );
  }

  final _scanResults = <BlueScanResult>[];

  Widget _buildListView() {
    return Expanded(
      child: ListView.separated(
        itemBuilder: (context, index) => ListTile(
          leading: getSignalWidget(_scanResults[index].rssi),
          title:
              Text('${_scanResults[index].name}(${_scanResults[index].rssi})'),
          subtitle: Text(_scanResults[index].deviceId),
          onTap: () {
            setState(() {
              isScanning = !isScanning;
            });

            QuickBlue.stopScan(); // Stop scan when you click on the device
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PeripheralDetailPage(
                      _scanResults[index].deviceId, _scanResults[index].name),
                ));
          },
        ),
        separatorBuilder: (context, index) => Divider(),
        itemCount: _scanResults.length,
      ),
    );
  }

  // Button to set permission
  Widget _buildPermissionWarning() {
    return FutureBuilder<bool>(
      future: _hasBluetoothPermission(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          bool hasNoPermission = !(snapshot.data!);

          if (hasNoPermission) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  ElevatedButton(
                    child: Text('Request Permissions'),
                    onPressed: () {
                      _requestBluetoothPermissions();
                    },
                  ),
                ],
              ),
            );
          }
        }
        return Container();
      },
    );
  }

  void _requestBluetoothPermissions() async {
    if (Platform.isAndroid) {
      List<Permission> permissions = [
        Permission.bluetooth,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.location,
      ];

      Map<Permission, PermissionStatus> permissionStatuses =
          await permissions.request();

      setState(() {
        // Check if permissions were granted
        bool permissionsGranted = permissionStatuses.values
            .every((status) => status == PermissionStatus.granted);

        if (permissionsGranted) {
          // Permissions were granted, perform necessary actions
          // For example, start scanning for Bluetooth devices
          QuickBlue.startScan();

          setState(() {
            isScanning = !isScanning;
          });
        } else {
          // Permissions were not granted, handle accordingly
          // For example, show an error message
          if (kDebugMode) {
            print('Permissions not granted.');
          }
        }
      });
    }
  }

  Future<bool> _hasBluetoothPermission() async {
    bool isAndroid = Platform.isAndroid;
    bool bluetoothPermission = await hasPermission(Permission.bluetooth);
    bool bluetoothConnectPermission =
        await hasPermission(Permission.bluetoothConnect);
    bool bluetoothScanPermission =
        await hasPermission(Permission.bluetoothScan);
    bool locationPermission = await hasPermission(Permission.location);

    return isAndroid &&
        bluetoothPermission &&
        bluetoothConnectPermission &&
        bluetoothScanPermission &&
        locationPermission;
  }

  Future<bool> hasPermission(Permission permission) async {
    PermissionStatus status = await permission.status;
    return status.isGranted;
  }
}
