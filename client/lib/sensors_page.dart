import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:quick_blue/quick_blue.dart';
import 'package:http/http.dart' as http;
import 'config_page.dart';
import 'globals.dart';
import 'default.dart';

class SensorsPage extends StatefulWidget {
  final Globals globals;

  const SensorsPage({required this.globals, Key? key})
      : super(key: key); //required Global variables

  @override
  State<SensorsPage> createState() => _StartPageState();
}

class SensorData {
  final int distance;
  final int duration;

  SensorData(this.distance, this.duration);
}

class _StartPageState extends State<SensorsPage> {
  // Create an object of type Defaults that contains default configuration values
  Defaults defaults = Defaults();

  final int sensorsCount = 8;
  final List<int> distances = [10, 30, 60, 600];
  final List<Widget> sensorBars = [];
  final List<Image> progressBars = [];
  final List<List<Widget>> sensorBarsData = [];

  void populateAssets() {
    for (int i = 1; i <= 4; i++) {
      progressBars.add(Image.asset('assets/images/bars/bar_$i-4.png'));
    }
  }

  AlwaysStoppedAnimation<double> getRotator(double angle) {
    return AlwaysStoppedAnimation(angle / 360);
  }

  Positioned getProgressBar(
      double width, double top, double left, double angle, Image asset) {
    return Positioned(
      width: width,
      top: top,
      left: left,
      child: RotationTransition(turns: getRotator(angle), child: asset),
    );
  }

  void populateSensorBarsData() {
    sensorBarsData.addAll([
      [
        getProgressBar(20, 328, 87, 270, progressBars[0]),
        getProgressBar(30, 312, 67, 270, progressBars[1]),
        getProgressBar(43, 302, 51, 270, progressBars[2]),
        getProgressBar(68, 288, 25, 270, progressBars[3])
      ],
      [
        getProgressBar(30, 155, 95, 330, progressBars[0]),
        getProgressBar(42, 115, 80, 330, progressBars[1]),
        getProgressBar(70, 72, 54, 330, progressBars[2]),
        getProgressBar(95, 55, 37, 330, progressBars[3])
      ],
      [
        getProgressBar(30, 121, 171, 0, progressBars[0]),
        getProgressBar(42, 79, 166, 0, progressBars[1]),
        getProgressBar(70, 33, 152, 0, progressBars[2]),
        getProgressBar(95, 16, 141, 0, progressBars[3])
      ],
      [
        getProgressBar(30, 155, 251, 30, progressBars[0]),
        getProgressBar(42, 115, 255, 30, progressBars[1]),
        getProgressBar(70, 72, 255, 30, progressBars[2]),
        getProgressBar(95, 55, 246, 30, progressBars[3])
      ],
      [
        getProgressBar(20, 328, 267, 90, progressBars[0]),
        getProgressBar(30, 312, 278, 90, progressBars[1]),
        getProgressBar(43, 302, 281, 90, progressBars[2]),
        getProgressBar(68, 289, 282, 90, progressBars[3])
      ],
      [
        getProgressBar(30, 525, 241, 150, progressBars[0]),
        getProgressBar(42, 519, 245, 150, progressBars[1]),
        getProgressBar(70, 516, 243, 150, progressBars[2]),
        getProgressBar(95, 515, 235, 150, progressBars[3])
      ],
      [
        getProgressBar(30, 530, 172, 180, progressBars[0]),
        getProgressBar(42, 530, 166, 180, progressBars[1]),
        getProgressBar(70, 530, 152, 180, progressBars[2]),
        getProgressBar(105, 530, 134, 180, progressBars[3])
      ],
      [
        getProgressBar(30, 520, 105, 210, progressBars[0]),
        getProgressBar(42, 517, 89, 210, progressBars[1]),
        getProgressBar(70, 513, 63, 210, progressBars[2]),
        getProgressBar(95, 513, 46, 210, progressBars[3])
      ]
    ]);
  }

  void populateSensorBars() {
    for (int i = 0; i < sensorsCount; i++) {
      setState(() {
        sensorBars.add(sensorBarsData[i][sensorBarsData[i].length - 1]);
      });
    }
  }

  void changeProgressBar(int sensorId, int progressBarId) {
    setState(() {
      sensorBars[sensorId] = sensorBarsData[sensorId][progressBarId];
    });
  }

  late Map<int, List<SensorData>> sensorsDataMap = {};

  IconData centerButtonIcon = Icons.start;

  //Input controller for Name of the measurement
  final TextEditingController _measureNameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    sensorsDataMap = {};

    // Load configuration variables from SharedPreferences
    loadConfigVariables();

    // Populate all of the lists
    populateAssets();
    populateSensorBarsData();
    populateSensorBars();

    // Initialize QuickBlue value handler to handle value changes for the characteristic
    QuickBlue.setValueHandler(_handleValueChange);
  }

  @override
  void dispose() {
    super.dispose();
    // Clear QuickBlue value handler
    QuickBlue.setValueHandler(null);
  }

  // Retrieve configuration variables from SharedPreferences
  Future<void> loadConfigVariables() async {
    widget.globals.measureName =
        widget.globals.prefs.getString('measureName') ?? defaults.measureName;
    widget.globals.collectingCount =
        widget.globals.prefs.getInt('collectingCount') ??
            defaults.collectingCount;
    widget.globals.averageMeasuresCount =
        widget.globals.prefs.getInt('averageMeasuresCount') ??
            defaults.averageMeasuresCount;
    widget.globals.savedValue =
        widget.globals.prefs.getInt('savedValue') ?? defaults.savedValue;
    widget.globals.url = widget.globals.prefs.getString('url') ?? defaults.url;
    widget.globals.tenantId =
        widget.globals.prefs.getString('tenantId') ?? defaults.tenantId;
    widget.globals.deviceToken =
        widget.globals.prefs.getString('deviceToken') ?? defaults.deviceToken;
    widget.globals.bleServiceId =
        widget.globals.prefs.getString('bleServiceId') ?? defaults.bleServiceId;
    widget.globals.thingName =
        widget.globals.prefs.getString('thingName') ?? defaults.thingName;
    widget.globals.featureName =
        widget.globals.prefs.getString('featureName') ?? defaults.featureName;
    widget.globals.deviceName =
        widget.globals.prefs.getString('deviceName') ?? defaults.deviceName;
    widget.globals.switchModeCharacteristicId =
        widget.globals.prefs.getString('switchModeCharacteristicId') ??
            defaults.switchModeCharacteristicId;
    widget.globals.sensorsCharacteristicId =
        widget.globals.prefs.getString('sensorsCharacteristicId') ??
            defaults.sensorsCharacteristicId;

    widget.globals.receivedSensorsJsonValues = [];

    // Inizialize the input name as that saved from shared preferences
    _measureNameController.text = widget.globals.measureName;
  }

  // Save configuration variables to SharedPreferences (Not used for now)
  Future<void> saveConfigVariables() async {
    await widget.globals.prefs
        .setString('measureName', widget.globals.measureName);
    await widget.globals.prefs
        .setInt('collectingCount', widget.globals.collectingCount);
    await widget.globals.prefs
        .setInt('averageMeasuresCount', widget.globals.averageMeasuresCount);
    await widget.globals.prefs.setInt('savedValue', widget.globals.savedValue);
    await widget.globals.prefs.setString('receivedSensorsJsonValues',
        jsonEncode(widget.globals.receivedSensorsJsonValues));
  }

  // When a characteristic change he read the value and decode it and save into different variables
  void _handleValueChange(
      String deviceId, String characteristicId, Uint8List value) {
    // Check if the characteristicId is the correct one and if the data count equals to twice the number of sensors
    if (characteristicId == widget.globals.sensorsCharacteristicId &&
        value.length == sensorsCount * 2) {
      final byteData = ByteData.view(value.buffer);
      int timestamp = DateTime.now().millisecondsSinceEpoch;

      for (int i = 0; i < sensorsCount; i++) {
        if (i < value.lengthInBytes ~/ 2) {
          int distance = byteData.getInt16(i * 2, Endian.little);
          SensorData sensorData = SensorData(distance, 0);

          sensorsDataMap.update(
              timestamp, (sensors) => [...sensors, sensorData],
              ifAbsent: () => [sensorData]);
        }
      }

      if (sensorsDataMap.length % widget.globals.averageMeasuresCount == 0) {
        Map<int, int> sensorsDataSum = {};
        List<SensorData> sensorsDataAverage = [];

        sensorsDataMap.forEach((key, value) {
          for (int i = 0; i < value.length; i++) {
            int distance = value[i].distance;

            sensorsDataSum.update(i, (value) => value + distance,
                ifAbsent: () => distance);
          }
        });

        for (int i = 0; i < sensorsDataSum.length; i++) {
          SensorData sensorData = SensorData(
              (sensorsDataSum[i]! / widget.globals.averageMeasuresCount)
                  .toInt(),
              0);

          sensorsDataAverage.add(sensorData);

          for (int j = 0; j < distances.length; j++) {
            if (sensorData.distance <= distances[j]) {
              changeProgressBar(i, j);
              break;
            }
          }
        }

        if (widget.globals.collectingCount > 0) {
          widget.globals.receivedSensorsJsonValues
              .add(parseSensorsData(sensorsDataAverage));

          widget.globals.savedValue += sensorsDataMap.length;

          if (widget.globals.receivedSensorsJsonValues.length %
                  widget.globals.collectingCount ==
              0) {
            sendData();
          }
        }

        sensorsDataMap = {};
      }
    }
  }

  // Create the json object of the sensors and return it
  Map<String, dynamic> parseSensorsData(List<SensorData> sensorData) {
    Map<String, dynamic> jsonObj = {
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "values": sensorData.map((data) => data.distance).toList(),
    };

    return jsonObj;
  }

  // Send data to server using measureName
  Future<void> sendData() async {
    String jsonDataString =
        jsonEncode(widget.globals.receivedSensorsJsonValues);

    if (kDebugMode) {
      print(
          'Sending data to "${widget.globals.measureName}":\n $jsonDataString');
    }

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': widget.globals.deviceToken
    };

    var request = http.Request(
        'POST',
        Uri.parse(
            '${widget.globals.url}measurements/${widget.globals.measureName}/timeserie'));

    request.body = jsonDataString;
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print(await response.stream.bytesToString());
      }

      widget.globals.receivedSensorsJsonValues.clear(); //reset

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Values sent correctly!")),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.reasonPhrase!)),
        );
      }

      if (kDebugMode) {
        print(response.reasonPhrase);
      }
    }
  }

  Future<void> checkMeasureExist() async {
    if (widget.globals.measureName == '') {
      await postMeasure();
    } else {
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': widget.globals.deviceToken
      };
      var request = http.Request(
          'GET',
          Uri.parse(
              "${widget.globals.url}measurements/${widget.globals.measureName}"));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print(await response.stream.bytesToString());
        }
      } else {
        if (kDebugMode) {
          print(response.reasonPhrase);
        }
        await postMeasure();
      }
    }
  }

  Future<void> postMeasure() async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': widget.globals.deviceToken
    };
    var request =
        http.Request('POST', Uri.parse("${widget.globals.url}measurements"));
    // Prepare the data to be sent in the request body as a Map
    Map<String, dynamic> requestBody = {
      "thing": widget.globals.thingName,
      "feature": widget.globals.featureName,
      "device": widget.globals.deviceName,
      "tags": [],
      "visibility": "public"
    };

    if (widget.globals.measureName != '' &&
        widget.globals.measureName.isNotEmpty) {
      // If the measureName is available, include it in the request body
      requestBody["_id"] = widget.globals.measureName;
    }

    // JSON encode the data in the request body
    String requestBodyJson = json.encode(requestBody);
    request.body = requestBodyJson;
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      String jsonResponse = await response.stream.bytesToString();

      if (kDebugMode) {
        print(jsonResponse);
      }

      Map<String, dynamic> measure = jsonDecode(jsonResponse);

      widget.globals.measureName = measure["_id"].toString();
    } else {
      if (kDebugMode) {
        print(request);
        print(response.toString());
      }

      if (mounted) {
        final snackBar = SnackBar(
          content: Text(response.reasonPhrase!),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  bool isSending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensors Page'),
        actions: [
          // Add the gear icon button to access a new page
          IconButton(
            onPressed: () {
              // Navigate to the new page when the gear icon is pressed
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ConfigPage(globals: widget.globals)),
              );
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[],
          ),
          buildCarImage(),
        ]),
      ),
    );
  }

  Widget buildCarImage() {
    return Expanded(
      child: Stack(children: [
        Center(child: Image.asset('assets/images/RCCarConeLess.png')),
        ...sensorBars,
        Center(
            child: CircleAvatar(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          radius: 30,
          child: IconButton(
            onPressed: isSending
                ? () async {
                    setState(() {
                      isSending = !isSending;
                      centerButtonIcon = Icons.play_arrow;
                    });

                    QuickBlue.writeValue(
                        widget.globals.deviceId,
                        widget.globals.bleServiceId,
                        widget.globals.switchModeCharacteristicId,
                        Uint8List.fromList([0]),
                        BleOutputProperty.withoutResponse);

                    QuickBlue.setNotifiable(
                      widget.globals.deviceId,
                      widget.globals.bleServiceId,
                      widget.globals.sensorsCharacteristicId,
                      BleInputProperty.disabled,
                    );
                  }
                : () async {
                    await checkMeasureExist();

                    setState(() {
                      isSending = !isSending;
                      centerButtonIcon = Icons.stop;
                    });

                    // Write command value on bluetooth to start capturing data from sensors
                    QuickBlue.setNotifiable(
                      widget.globals.deviceId,
                      widget.globals.bleServiceId,
                      widget.globals.sensorsCharacteristicId,
                      BleInputProperty.notification,
                    );

                    // Write command value on bluetooth to enable data capturing
                    Future.delayed(Duration(seconds: 1), () {
                      QuickBlue.writeValue(
                          widget.globals.deviceId,
                          widget.globals.bleServiceId,
                          widget.globals.switchModeCharacteristicId,
                          Uint8List.fromList([1]),
                          BleOutputProperty.withoutResponse);
                    });
                  },
            icon: Icon(centerButtonIcon),
            iconSize: 40,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        )),
      ]),
    );
  }
}
