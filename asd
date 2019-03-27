#include <NewPing.h>
#include <Servo.h>
#include "Gyro.h"
#include <Wire.h>

//#define DEBUG_ANGLE

MPU6050 mpu6050(Wire);

const int ci_Trigger_Left = 2;                                                                             //Ultrasonic Constants
const int ci_Echo_Left = 3 ;
const int ci_Trigger_Right = 4;
const int ci_Echo_Right = 5;
const int ci_Ultrasonics = 8;
const int ci_Max_Distance = 400;
const int ci_Starting_Angle = 80;
const int ci_Ping_Interval = 200;

NewPing Sonar_Left(ci_Trigger_Left, ci_Echo_Left, ci_Max_Distance);
NewPing Sonar_Right(ci_Trigger_Right, ci_Echo_Right, ci_Max_Distance);
Servo servo_Ultrasonic;
Servo servo_Dump;

unsigned int ui_Pos;                                                                                       //angle of servo motors

unsigned int ui_Left_1, ui_Left_2, ui_Left_3;                                                              //Ultrasonic Readings
unsigned int ui_Right_1, ui_Right_2, ui_Right_3;


Servo servo_Right_Motor;                                                                                   //Motor Constants
Servo servo_Left_Motor;
Servo servo_Funnel_Motor;

unsigned int ui_Left_Motor_Speed, ui_Right_Motor_Speed;
const int ci_Motors_Speed = 1600;
const int ci_Turn_Speed_Backwards = 1400;
const int ci_Turn_Speed_Forwards = 1600;
const int ci_Right_Motor = 6;
const int ci_Left_Motor = 7;
const int ci_Funnel_Motor = 9;

unsigned long ul_Delay_Time;                                                                               //Time for Ping()

unsigned long ul_Current_Angle;   //testing
unsigned long ul_Angle_Delay;

volatile bool init_Straight;
unsigned long ul_Straight_Angle;
unsigned long ul_Striaght_Delay;
bool object_Right;
bool object_Left;
bool object_Middle;

void setup() {
  Serial.begin(9600);

  Wire.begin();                                                                         //Gyroscope setup
  mpu6050.begin();
  mpu6050.calcGyroOffsets(true);
  mpu6050.update();
  mpu6050.zero();

  servo_Ultrasonic.attach(ci_Ultrasonics);                                              //Ultrasonice setup
  ul_Delay_Time = millis();
  ui_Pos = ci_Starting_Angle;

  pinMode(ci_Right_Motor, OUTPUT);                                                      //Motor setup
  servo_Right_Motor.attach(ci_Right_Motor);
  pinMode(ci_Left_Motor, OUTPUT);
  servo_Left_Motor.attach(ci_Left_Motor);
  pinMode(ci_Funnel_Motor, OUTPUT);
  servo_Funnel_Motor.attach(ci_Funnel_Motor);

  pinMode(10, OUTPUT);                                                                   //Dump motor setup
  servo_Dump.attach(10);

  ui_Left_Motor_Speed = 1602;
  ui_Right_Motor_Speed = 1620;
  ul_Current_Angle = mpu6050.getAngleZ();
  servo_Ultrasonic.write(ci_Starting_Angle);

  //testing
  ul_Angle_Delay = millis();
  init_Straight = true;
  ul_Striaght_Delay = millis();
  object_Right = false;
  object_Left = false;
  object_Middle = false;

}

void loop() {
  mpu6050.update();                                                                     //Update Gyro
  //  Serial.print("\tangleZ : ");
  //  ul_Current_Angle = mpu6050.getAngleZ();
  //  Serial.println(ul_Current_Angle);
  //mpu6050.getDirection();

  Ping();                                                                               //Update Ultrasonic


  //GoStraight();

}

void GoLeft() {

}

void GoStraight() {
  if (init_Straight) {
    ul_Straight_Angle = mpu6050.getAngleZ();
    init_Straight = false;
  }
  if (millis() -  ul_Striaght_Delay >= 200) {
    ul_Striaght_Delay = millis();
    if (mpu6050.getAngleZ() > ul_Straight_Angle + 1) {
      ui_Right_Motor_Speed -= 1;
    }
    if (mpu6050.getAngleZ() < ul_Straight_Angle - 1) {
      ui_Right_Motor_Speed += 1;
    }
    servo_Left_Motor.writeMicroseconds(ui_Left_Motor_Speed);
    servo_Right_Motor.writeMicroseconds(ui_Right_Motor_Speed);
  }
}



void Interpret() {                                                                                          //runs every cycle of ultrasonic sensors
  if ((ui_Right_1 <= 25 && ui_Right_1 >= 3) || (ui_Right_2 <= 25 && ui_Right_2 >= 3)) {
    object_Right = true;
  }
  if ((ui_Left_2 <= 25 && ui_Left_2 >= 3) || (ui_Left_3 <= 25 && ui_Left_3 >= 3)) {
    object_Left = true;
  }
  if ((ui_Left_1 <= 25 && ui_Left_1 >= 3) || (ui_Right_3 <= 25 && ui_Right_3 >= 3)) {          //supercedes other two
    object_Middle = true;
  }
  Serial.println();

  if (object_Right && !object_Left) {
    servo_Right_Motor.writeMicroseconds(ci_Turn_Speed_Forwards);
    servo_Left_Motor.writeMicroseconds(ci_Turn_Speed_Backwards);
  }
  if (!object_Right && object_Left) {
    servo_Right_Motor.writeMicroseconds(ci_Turn_Speed_Backwards);
    servo_Left_Motor.writeMicroseconds(ci_Turn_Speed_Forwards);
  }
  if (!object_Right && !object_Left && !object_Middle) {
    init_Straight = true;
    GoStraight();
  }




}

void Ping() {                                                               //Pings and updates ultrasonic readings

  if (millis() - ul_Delay_Time >= ci_Ping_Interval) {
    ul_Delay_Time = millis();
    switch (ui_Pos) {
      case ci_Starting_Angle: {
          ui_Left_1 = Sonar_Left.ping_cm();
          ui_Right_1 = Sonar_Right.ping_cm();
          break;
        }
      case (ci_Starting_Angle+30): {
          ui_Left_2 = Sonar_Left.ping_cm();
          ui_Right_2 = Sonar_Right.ping_cm();
          break;
        }
      case (ci_Starting_Angle+60): {
          ui_Left_3 = Sonar_Left.ping_cm();
          ui_Right_3 = Sonar_Right.ping_cm();
          break;
        }
    }
    ui_Pos += 30;

    if (ui_Pos >= ci_Starting_Angle + 90) {

      Interpret();                                                                          //Interpret Ping

      ui_Pos = ci_Starting_Angle;

#ifdef DEBUG_ANGLE
      Serial.print("Angle :");
      for (int i = ci_Starting_Angle ; i < ci_Starting_Angle + 90; i += 30) {
        Serial.print(i);
        Serial.print("  ");
      }
      Serial.println();
      Serial.print("Left:  ");
      Serial.print(ui_Left_1);
      Serial.print("  ");
      Serial.print(ui_Left_2);
      Serial.print("  ");
      Serial.print(ui_Left_3);
      Serial.println(" cm");

      Serial.print("Right:  ");
      Serial.print(ui_Right_1);
      Serial.print("  ");
      Serial.print(ui_Right_2);
      Serial.print("  ");
      Serial.print(ui_Right_3);
      Serial.println(" cm");
#endif DEBUG_ANGLE
    }
    servo_Ultrasonic.write(ui_Pos);
  }
}
