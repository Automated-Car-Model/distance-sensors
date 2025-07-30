class Defaults {
  String deviceId = 'B1:89:BD:21:36:F6';
  String measureName = 'seriesensoritest';
  int collectingCount = 10;
  int averageMeasuresCount = 5;
  int savedValue = 0;
  List<List<double>> receivedValues = [];
  List<Map<String, dynamic>> receivedSensorsJsonValues = [];
  String url = 'https://tracker.elioslab.net/v1/';
  String tenantId = 'distance-sensors';
  String deviceToken = '';
  String thingName = 'car1';
  String featureName = 'distance';
  String deviceName = 'sensors';
  String bleServiceId = '8e7c2dae-0000-4b0d-b516-f525649c49ca';
  String switchModeCharacteristicId = '8e7c2dae-0001-4b0d-b516-f525649c49ca';
  String sensorsCharacteristicId = '8e7c2dae-0002-4b0d-b516-f525649c49ca';
}
