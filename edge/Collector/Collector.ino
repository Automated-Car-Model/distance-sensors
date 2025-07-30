#define triggerPin 2
#define echoPinStart 3
#define echoPinCount 8
#define triggerDelay 100000

// In the air, at 20° C, in m/s
#define soundSpeed 343.1

// Duration is in ms, distance is in centimeters
long durations[echoPinCount], distances[echoPinCount];

// Sound speed in cm/μs. It's divided by 2 because we only need the return distance
const double soundSpeedCmPerUs = (soundSpeed / 10000) / 2;

// In milliseconds
const int delayBetweenMeasures = 100, zeroDistanceValue = 200, maxDistanceValue = 200;

void setup() 
{
  // Initialize with baud rate of 9600
  SerialUSB.begin(9600);
  Serial1.begin(57600);
       
  // Set the built in LED pin as output
  pinMode(LED_BUILTIN, OUTPUT); 
  pinMode(triggerPin, OUTPUT);

  // Switch off LED pin
  digitalWrite(LED_BUILTIN, LOW);

  // Sets all echopins
  for (int i = echoPinStart; i < echoPinStart + echoPinCount; i++)
    pinMode(i, INPUT);
}

void loop() 
{
  String sensorDistances = "";

  for (int i = echoPinStart; i < echoPinStart + echoPinCount; i++) 
  {
    int index = i - echoPinStart;
    
    sendTrigger(10, triggerPin);    

    durations[index] = pulseIn(i, HIGH, 100000);

    int distance = min(soundSpeedCmPerUs * durations[index], maxDistanceValue); // Could be approximated with this formula: duration / 58

    distances[index] = distance == 0 ? zeroDistanceValue : distance;

    sensorDistances += (String)distances[index];
    
    if (i < echoPinStart + echoPinCount - 1)
       sensorDistances += ",";

    delayMicroseconds(triggerDelay);    
  }

  Serial1.println(sensorDistances);
  SerialUSB.println("Sent data: " + sensorDistances);

  delay(delayBetweenMeasures);
}

void sendTrigger(int duration, int pinToWrite) 
{
  digitalWrite(pinToWrite, LOW);
  delayMicroseconds(2);

  digitalWrite(pinToWrite, HIGH);
  delayMicroseconds(duration);
  digitalWrite(pinToWrite, LOW);
}
