import 'package:shared_preferences/shared_preferences.dart';
import 'default.dart';

Defaults defaults = Defaults();

class Globals {
  String deviceId = '';
  String measureName = '';
  int collectingCount = 0;
  int averageMeasuresCount = 0;
  int savedValue = 0;
  List<List<double>> receivedValues = [];
  List<Map<String, dynamic>> receivedSensorsJsonValues = [];
  String url = '';
  String tenantId = '';
  String deviceToken = '';
  String thingName = '';
  String featureName = '';
  String deviceName = '';
  String bleServiceId = '';
  String switchModeCharacteristicId = '';
  String sensorsCharacteristicId = '';
  late SharedPreferences prefs; // SharedPreferences instance
}
