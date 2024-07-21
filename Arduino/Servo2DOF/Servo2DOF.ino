/*
  */

// the setup function runs once when you press reset or power the board
int t = 0;
float v0;
float v1;
float v2;
float voltage;
int _delay = 80;
#include <Servo.h>

int width = 640;
int height  = 480;

int minAngleX = 55;
int maxAngleX = 120;

int minAngleY = 40;
int maxAngleY = 90;
Servo myservo;  // create servo object to control a servo
Servo myservo2;  // create servo object to control a servo

float x;
// the loop function runs over and over again forever
int current_angle = 90;
int current_angle2 = 70;
bool led = LOW;

int xD = 0;

void setup()
{
    Serial.setTimeout(1);
    myservo.attach(2);  // attaches the servo on pin 9 to the servo object
    myservo2.attach(3);
    myservo.write(current_angle);
    myservo2.write(current_angle2);
    Serial.begin(115200);
    pinMode(12,OUTPUT);
    digitalWrite(12, led);
}
void loop() {
  
  //int oldAngleX =  myservo.write(current_angle);
  voltage =analogRead(A1); 
  //cos =  cos + 0.1;
  if(voltage > 600){ current_angle--; delay(_delay);}
  else if(400 > voltage){current_angle++; delay(_delay);}
  current_angle = constrain(current_angle, minAngleX, maxAngleX);
  //
  //
  int voltage2 =analogRead(A0); 
  if(voltage2 > 600) {current_angle2++; delay(_delay);}
  else if(400 > voltage2) {current_angle2--; delay(_delay);}
  current_angle2 = constrain(current_angle2, minAngleY, maxAngleY);

  xD++;

  xD = xD % width;
  //mapCoordinatesToAngles(xD, height/2, 1);
  //delay(10);
  myservo.write(current_angle);
  myservo2.write(current_angle2);

  //delay(50);



  // send data only when you receive data:
  if (Serial.available() > 0) {

      //el mensaje va a tener el formato "+{codigo};{angulo}-" "{1;30;}"

      String command =  Serial.readStringUntil(';');
      if(command.begin()[0] != '{') return;
      int x = command.substring(1).toInt();
      command =  Serial.readStringUntil(';');
      int y = command.toInt();
      command =  Serial.readStringUntil('}');
      int z = command.toInt();
      if(z != 1) return;
      //Serial.println(String(x) + " : " + String(y) + " : " + String(z));
      mapCoordinatesToAngles(x,y,z);
  }
}

void mapCoordinatesToAngles(int x, int y, int z)
{
  int newAngle = map(x, 0, width, maxAngleX, minAngleX) ;
  int newAngle2 = map(y, 0, height, maxAngleY, minAngleY);
  
  current_angle =  newAngle*0.8 + current_angle *0.2;
  //Serial.println(current_angle);
  current_angle2 = newAngle2*0.8 + current_angle2 *0.2;
  //Serial.println(current_angle2);
}
