import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'globals.dart';

class ConfigPage extends StatefulWidget {
  final Globals globals;

  const ConfigPage({required this.globals, Key? key}) : super(key: key);

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  //input controllers
  final TextEditingController _urlEditingController = TextEditingController();
  final TextEditingController _tenantIdEditingController =
      TextEditingController();
  final TextEditingController _deviceTokenEditingController =
      TextEditingController();
  final TextEditingController _bleServiceIdEditingController =
      TextEditingController();
  final TextEditingController _collectingCountEditingController =
      TextEditingController();
  final TextEditingController _averageMeasuresCountEditingController =
      TextEditingController();
  final TextEditingController _thingNameEditingController =
      TextEditingController();
  final TextEditingController _featureNameEditingController =
      TextEditingController();
  final TextEditingController _deviceNameEditingController =
      TextEditingController();
  final TextEditingController _switchModeCharacteristicIdEditingController =
      TextEditingController();
  final TextEditingController _sensorsCharacteristicIdEditingController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeTextControllers();
  }

  //initialize Text controllers
  Future<void> initializeTextControllers() async {
    _urlEditingController.text = widget.globals.url;
    _tenantIdEditingController.text = widget.globals.tenantId;
    _deviceTokenEditingController.text = widget.globals.deviceToken;
    _bleServiceIdEditingController.text = widget.globals.bleServiceId;
    _collectingCountEditingController.text =
        widget.globals.collectingCount.toString();
    _averageMeasuresCountEditingController.text =
        widget.globals.averageMeasuresCount.toString();
    _thingNameEditingController.text = widget.globals.thingName;
    _featureNameEditingController.text = widget.globals.featureName;
    _deviceNameEditingController.text = widget.globals.deviceName;
    _switchModeCharacteristicIdEditingController.text =
        widget.globals.switchModeCharacteristicId;
    _sensorsCharacteristicIdEditingController.text =
        widget.globals.sensorsCharacteristicId;
  }

  //for save button update the shared preferences
  Future<void> saveSharedPreferences() async {
    await widget.globals.prefs.setString('url', widget.globals.url);
    await widget.globals.prefs.setString('tenantId', widget.globals.tenantId);
    await widget.globals.prefs
        .setString('deviceToken', widget.globals.deviceToken);
    await widget.globals.prefs
        .setString('bleServiceId', widget.globals.bleServiceId);
    await widget.globals.prefs.setString('thingName', widget.globals.thingName);
    await widget.globals.prefs
        .setString('featureName', widget.globals.featureName);
    await widget.globals.prefs
        .setString('deviceName', widget.globals.deviceName);
    await widget.globals.prefs.setString('switchModeCharacteristicId',
        widget.globals.switchModeCharacteristicId);
    await widget.globals.prefs.setString(
        'sensorsCharacteristicId', widget.globals.sensorsCharacteristicId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Config Page'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('URL Measurify'),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        widget.globals.url = value;
                      });
                    },
                    controller: _urlEditingController,
                  ),
                  SizedBox(height: 16.0),
                  Text('ID Tenant'),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        widget.globals.tenantId = value;
                      });
                    },
                    controller: _tenantIdEditingController,
                  ),
                  SizedBox(height: 16.0),
                  Text('Token Device'),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        widget.globals.deviceToken = value;
                      });
                    },
                    controller: _deviceTokenEditingController,
                  ),
                  SizedBox(height: 16.0),
                  Text('ID BLE service'),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        widget.globals.bleServiceId = value;
                      });
                    },
                    controller: _bleServiceIdEditingController,
                  ),
                  SizedBox(height: 16.0),
                  Text('Collecting Count'),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        widget.globals.collectingCount = math.max(
                            0, int.tryParse(value) ?? defaults.collectingCount);
                      });
                    },
                    controller: _collectingCountEditingController,
                  ),
                  SizedBox(height: 16.0),
                  Text('Average Measures Count'),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        widget.globals.averageMeasuresCount = math.max(
                            1,
                            int.tryParse(value) ??
                                defaults.averageMeasuresCount);
                      });
                    },
                    controller: _averageMeasuresCountEditingController,
                  ),
                  SizedBox(height: 16.0),
                  Text('Thing Name'),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        widget.globals.thingName = value;
                      });
                    },
                    controller: _thingNameEditingController,
                  ),
                  SizedBox(height: 16.0),
                  Text('Feature Name'),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        widget.globals.featureName = value;
                      });
                    },
                    controller: _featureNameEditingController,
                  ),
                  SizedBox(height: 16.0),
                  Text('Device Name'),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        widget.globals.deviceName = value;
                      });
                    },
                    controller: _deviceNameEditingController,
                  ),
                  SizedBox(height: 16.0),
                  Text('IDs Characteristics'),
                  SizedBox(height: 8.0),
                  Text('Switch Mode'),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        widget.globals.switchModeCharacteristicId = value;
                      });
                    },
                    controller: _switchModeCharacteristicIdEditingController,
                  ),
                  SizedBox(height: 8.0),
                  Text('Sensors'),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        widget.globals.sensorsCharacteristicId = value;
                      });
                    },
                    controller: _sensorsCharacteristicIdEditingController,
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      saveSharedPreferences();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Configurations saved')),
                      );
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 16.0,
            right: 16.0,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: () {
                  resetConfigVariables();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Settings reset')),
                  );
                },
                child: Text('Reset Settings'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //reset all the values to default. [CHECK FOR MISSING]
  Future<void> resetConfigVariables() async {
    await widget.globals.prefs.setString('measureName', defaults.measureName);
    await widget.globals.prefs
        .setInt('collectingCount', defaults.collectingCount);
    await widget.globals.prefs
        .setInt('averageMeasuresCount', defaults.averageMeasuresCount);
    await widget.globals.prefs.setInt('savedValue', defaults.savedValue);
    await widget.globals.prefs.setString('url', defaults.url);
    await widget.globals.prefs.setString('tenantId', defaults.tenantId);
    await widget.globals.prefs.setString('deviceToken', defaults.deviceToken);
    await widget.globals.prefs.setString('bleServiceId', defaults.bleServiceId);
    await widget.globals.prefs.setString('thingName', defaults.thingName);
    await widget.globals.prefs.setString('featureName', defaults.featureName);
    await widget.globals.prefs.setString('deviceName', defaults.deviceName);
    await widget.globals.prefs
        .setString('imuCharacteristicId', defaults.switchModeCharacteristicId);
    await widget.globals.prefs
        .setString('envCharacteristicId', defaults.sensorsCharacteristicId);

    //update the globals variables
    loadConfigVariables();
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
  }
}
