
#include <Servo.h>
#include <math.h>
#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BNO055.h>
#include <utility/imumaths.h>

Servo servo1;  // create servo object to control a servo
// twelve servo objects can be created on most boards

int pos = 0;    // variable to store the servo position
int B_c = 11;
int A_b = 8;
int C_y = 9.5;
double a = 0;
double s = 0;
double stroke = 26.454;
//s is the travel a is the desired angle
/* Set the delay between fresh samples */
uint16_t BNO055_SAMPLERATE_DELAY_MS = 100;

// Check I2C device address and correct line below (by default address is 0x29 or 0x28)
//                                   id, address
Adafruit_BNO055 bno = Adafruit_BNO055(55, 0x28, &Wire);

void setup() {
  Serial.begin(115200);

  while (!Serial) delay(10);  // wait for serial port to open!

  Serial.println("Orientation Sensor Test"); Serial.println("");

  /* Initialise the sensor */
  if (!bno.begin())
  {
    /* There was a problem detecting the BNO055 ... check your connections */
    Serial.print("Ooops, no BNO055 detected ... Check your wiring or I2C ADDR!");
    while (1);
  }

  delay(1000);
  servo1.attach(5);  // attaches the servo on pin 3 to the servo object, 0 for the vision
}

void loop() {
  // for (a = -1.43; a <= 1.43; a += .01) { // goes from 0 degrees to 180 degrees
  //   // in steps of 1 degree
  //   servo1.write(final_p(a));              // tell servo to go to position in variable 'pos'
  //   // Serial.println("angle in degrees ");
  //   // Serial.println(a * 57.2958);
  //   // Serial.println("final position ");
  //   // Serial.println(final_p(a));
  //   Serial.print("degrees:");
  //   Serial.print(a * 57.2958);
  //   Serial.print(",");
  //   Serial.print("position:");
  //   Serial.println(final_p(a));
  //   delay(15);                       // waits 15 ms for the servo to reach the position
  // }
  double IMU_radian = y_degrees() * M_PI / 180;
  servo1.write(final_p(IMU_radian));              // tell servo to go to position in variable 'pos'
  // Serial.println("angle in degrees ");
  // Serial.println(a * 57.2958);
  // Serial.println("final position ");
  // Serial.println(final_p(a));
  Serial.print("degrees:");
  Serial.print(y_degrees());
  Serial.print(",");
  Serial.print("position:");
  Serial.println(final_p(IMU_radian));
  delay(15);   

  

  // for (a = 1.43; a >= -1.43; a -= .01) { // goes from 0 degrees to 180 degrees
  //   // in steps of 1 degree
  //   servo1.write(final_p(a));              // tell servo to go to position in variable 'pos'
  //   // Serial.println("angle in degrees ");
  //   // Serial.println(a * 57.2958);
  //   // Serial.println("final position ");
  //   // Serial.println(final_p(a));
  //   Serial.print("degrees:");
  //   Serial.print(a * 57.2958);
  //   Serial.print(",");
  //   Serial.print("position:");
  //   Serial.println(final_p(a));
  //   delay(15);                       // waits 15 ms for the servo to reach the position
  // }
}

int final_p(double angle) {
  s = (B_c * sin(angle)) + A_b * cos(asin((B_c * cos(angle) - C_y) / A_b));
  if (s <= 16.454 && s >= -10) //26.454
    return (s + 10) * (180/stroke);
  else
    return 0;
}

double y_degrees() {
  //could add VECTOR_ACCELEROMETER, VECTOR_MAGNETOMETER,VECTOR_GRAVITY...
  sensors_event_t orientationData , angVelocityData , linearAccelData, magnetometerData, accelerometerData, gravityData;
  bno.getEvent(&orientationData, Adafruit_BNO055::VECTOR_EULER);

  

  int8_t boardTemp = bno.getTemp();
  Serial.println();
  Serial.print(F("temperature: "));
  Serial.println(boardTemp);

  uint8_t system, gyro, accel, mag = 0;
  bno.getCalibration(&system, &gyro, &accel, &mag);
  Serial.println();
  Serial.print("Calibration: Sys=");
  Serial.print(system);
  Serial.print(" Gyro=");
  Serial.print(gyro);
  Serial.print(" Accel=");
  Serial.print(accel);
  Serial.print(" Mag=");
  Serial.println(mag);

  Serial.println("--");
  delay(BNO055_SAMPLERATE_DELAY_MS);

  return printEvent(&orientationData);
}

double printEvent(sensors_event_t* event) {
  double x = -1000000, y = -1000000 , z = -1000000; //dumb values, easy to spot problem
  if (event->type == SENSOR_TYPE_ORIENTATION) {
    Serial.print("Orient:");
    x = event->orientation.x;
    y = event->orientation.y;
    z = event->orientation.z;
  }
  else {
    Serial.print("Unk:");
  }

  Serial.print("\tx= ");
  Serial.print(x);
  Serial.print(" |\ty= ");
  Serial.print(y);
  Serial.print(" |\tz= ");
  Serial.println(z);
  return y;
}
