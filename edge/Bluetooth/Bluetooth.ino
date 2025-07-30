#include <ArduinoBLE.h>
#include <time.h>
#include <stdlib.h>

int sensorsCount = 8;
int canTransmitData = 0;
int maxRandomValue = 100;

const char* localName = "Arduino 33 IoT";
const char* serviceUUID = "8e7c2dae-0000-4b0d-b516-f525649c49ca";
const char* switchModeUUID = "8e7c2dae-0001-4b0d-b516-f525649c49ca";
const char* sensorUUID = "8e7c2dae-0002-4b0d-b516-f525649c49ca";

bool isDebugEnabled = false;
bool isFirstString = true;

BLEByteCharacteristic switchModeCharacteristic(switchModeUUID, BLEWrite | BLERead );
BLECharacteristic sensorsCharacteristic(sensorUUID, BLENotify, sensorsCount * 2);

BLEService sensorsService(serviceUUID);

void setup() 
{
  randomSeed(analogRead(0));

  Serial.begin(9600);
  Serial1.begin(57600);

  // Set LED pin to output mode
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, LOW);

  // If debug is enabled, wait for the serial connection
  if (isDebugEnabled)
    while (!Serial);

  // begin initialization
  if (!BLE.begin()) 
  {
    Serial.println("starting BLE module failed!");

    while (1);
  }

  // Set advertised local name and service UUID:
  BLE.setLocalName(localName);
  BLE.setAdvertisedService(sensorsService);

  // Add the characteristics to the service
  sensorsService.addCharacteristic(switchModeCharacteristic);
  sensorsService.addCharacteristic(sensorsCharacteristic);

  // Add the service
  BLE.addService(sensorsService);

  // Set the initial value for the characeristics
  switchModeCharacteristic.writeValue(0);
  sensorsCharacteristic.writeValue((uint8_t)0, false);

  // Start advertising
  BLE.advertise();

  Serial.println("BLE Started successfully");
}

void loop() 
{
  // Listen for BLE peripherals to connect
  BLEDevice central = BLE.central();

  // If a central is connected to peripheral
  if (central) 
  {
    Serial.print("Connected to central: ");

    // Print the central's MAC address
    Serial.println(central.address());

    // While the central is still connected to peripheral
    while (central.connected()) 
    {
      // If the remote device wrote to the characteristic,
      // use the value to control the LED and data transmission
      if (switchModeCharacteristic.written()) 
      {
        canTransmitData = switchModeCharacteristic.value();
  
        if (canTransmitData == 1) 
        {
            Serial.println("Data transmission Enabled");
            isFirstString = true;

            // Turn the LED on
            digitalWrite(LED_BUILTIN, HIGH);
        }
        else
        {
            Serial.println("Data transmission Disabled");

            // Turn the LED off
            digitalWrite(LED_BUILTIN, LOW);
        }
      }

      // Serial communication
      while (Serial1.available() >= 0 && canTransmitData == 1) 
      {
        // Read the data in the RX pin
        String receivedString = isDebugEnabled ? getRandomSensorsValueAsString(maxRandomValue, sensorsCount) : Serial1.readString();

        // Discard the first received string since it might be corrupted or invalid
        if (isFirstString)
        {
          isFirstString = false;
          break;
        }

        // Check if there's valid data available
        if (receivedString == "")
          break;

        Serial.println("Received data: " + receivedString);

        int16_t* values = splitStringToInt16Array(receivedString, ',', sensorsCount);
        byte* valuesInBytes = convertFromInt16ArrayToByteArray(values, sensorsCount);

        // Write the array of bytes of the sensor values
        sensorsCharacteristic.writeValue(valuesInBytes, sensorsCount * 2);

        // Free the allocated memory
        delete[] values, valuesInBytes;

        if (isDebugEnabled)
          delay(500);
      }
    }

    // When the central disconnects, print it out
    Serial.print(F("Disconnected from central: "));
    Serial.println(central.address());

    digitalWrite(LED_BUILTIN, LOW);  // Turn the LED off
  }
}

String getRandomSensorsValueAsString(int maxValue, int length)
{
  String randomSensorsValue = "";

  for (int i = 0; i < length; i++)
  {
    randomSensorsValue += random(0, maxValue + 1);

    if (i != length - 1)
        randomSensorsValue += ",";
  }

  return randomSensorsValue;
}

byte* convertFromInt16ArrayToByteArray(int16_t* values, int length)
{
  int j = 0;
  byte* bytesArray = new byte[length * 2];

  for (int i = 0; i < length; i++)
  {
    bytesArray[j++]= values[i] & 0xff;
    bytesArray[j++]= (values[i] >> 8);
  }

  return bytesArray;
}

int16_t* splitStringToInt16Array(String stringToConvert, char separator, int length)
{
  int16_t* splittedArray = new int16_t[length];
  String subString = "";
  int j = 0;

  for (int i = 0; i < stringToConvert.length(); i++)
  {
    if (stringToConvert[i] == NULL || stringToConvert[i] == '\n')
      break;
  
    if (stringToConvert[i] != separator)
    {
      subString += stringToConvert[i];
    }
    else
    {
      splittedArray[j++] = subString.toInt();
      subString = "";
    }
  }

  if (subString != "")
    splittedArray[j] = subString.toInt();

  return splittedArray;
}
