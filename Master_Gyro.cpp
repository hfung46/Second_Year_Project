#include "Gyro.h"
#include "Arduino.h"

MPU6050::MPU6050(TwoWire &w) {
  wire = &w;
}

float MPU6050::getAngleZ() {
  return angleZ;
}

void MPU6050::begin() {
  writeMPU6050(MPU6050_SMPLRT_DIV, 0x00);
  writeMPU6050(MPU6050_CONFIG, 0x00);
  writeMPU6050(MPU6050_GYRO_CONFIG, 0x08);
  writeMPU6050(MPU6050_PWR_MGMT_1, 0x01);
  this->update();
  preInterval = millis();
}

void MPU6050::writeMPU6050(byte reg, byte data) {
  wire->beginTransmission(MPU6050_ADDR);
  wire->write(reg);
  wire->write(data);
  wire->endTransmission();
}

byte MPU6050::readMPU6050(byte reg) {
  wire->beginTransmission(MPU6050_ADDR);
  wire->write(reg);
  wire->endTransmission(true);
  wire->requestFrom((uint8_t)MPU6050_ADDR, (size_t)2/*length*/);
  byte data =  wire->read();
  wire->read();
  return data;
}

void MPU6050::calcGyroOffsets(bool console) {
  float z = 0;
  int16_t rz;

  delay(1000);
  if (console) {
    Serial.println();
    Serial.println("========================================");
    Serial.println("calculate gyro offsets");
    Serial.print("DO NOT MOVE A MPU6050");
  }
  for (int i = 0; i < 3000; i++) {
    if (console && i % 1000 == 0) {
      Serial.print(".");
    }
    wire->beginTransmission(MPU6050_ADDR);
    wire->write(0x47);
    wire->endTransmission(false);
    wire->requestFrom((int)MPU6050_ADDR, 2, (int)true);

    rz = wire->read() << 8 | wire->read();

    z += ((float)rz) / 65;
  }
  gyroZoffset = z / 3000;

  if (console) {
    Serial.println();
    Serial.println("Done!!!");
    Serial.print("Z : "); Serial.println(gyroZoffset);
    Serial.println("Program will start after 3 seconds");
    Serial.print("========================================");
    Serial.println();
    delay(3000);

  }
}

void MPU6050::update() {
  wire->beginTransmission(MPU6050_ADDR);
  wire->write(0x47);
  wire->endTransmission(false);
  wire->requestFrom((int)MPU6050_ADDR, 2, (int)true);

  rawGyroZ = wire->read() << 8 | wire->read();

  gyroZ = ((float)rawGyroZ) / 65.5;

  gyroZ -= gyroZoffset;

  interval = (millis() - preInterval) * 0.001;

  angleGyroZ += gyroZ * interval;

  if (angleGyroZ >= 360) {
    angleGyroZ -= 360;
  }
  if (angleGyroZ < 0) {
    angleGyroZ += 360;
  }

  angleZ = angleGyroZ;

  preInterval = millis();

}

void MPU6050::zero() {
  angleGyroZ = 0;
}

//void MPU6050::getDirection(){
//  if(angleZ < 0){
//    angleZ += 360;
//  }
//  if(angleZ >= 360){
//    angleZ -= 360;
//  }
//  Serial.print("Robot is facing: ");
//
//  if (angleZ > 337.5 && angleZ<=359.9 ||angleZ >=0 && angleZ <= 22.5){
//    Serial.println ("E");
//  }
//  if (angleZ> 22.5 && angleZ <= 67.5){
//    Serial.println("NE");
//  }
//  if (angleZ> 67.5 && angleZ <= 112.5){
//    Serial.println("N");
//  }
//  if (angleZ> 112.5 && angleZ <= 157.5){
//    Serial.println("NW");
//  }
//  if (angleZ> 157.5 && angleZ <= 202.5){
//    Serial.println("W");
//  }
//  if (angleZ> 202.5 && angleZ <= 247.5){
//    Serial.println("SW");
//  }
//  if (angleZ> 247.5 && angleZ <= 292.5){
//    Serial.println("S");
//  }
//  if (angleZ> 292.5 && angleZ <= 337.5){
//    Serial.println("SE");
//  }
//}
