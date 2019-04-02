#ifndef GYRO_H
#define GYRO_H

#include "Arduino.h"
#include "Wire.h"

#define MPU6050_ADDR         0x68
#define MPU6050_SMPLRT_DIV   0x19
#define MPU6050_CONFIG       0x1a
#define MPU6050_GYRO_CONFIG  0x1b
#define MPU6050_WHO_AM_I     0x75
#define MPU6050_PWR_MGMT_1   0x6b

class MPU6050{
  public:

  MPU6050(TwoWire &w);

  void begin();

  void zero();

  void writeMPU6050(byte reg, byte data);
  byte readMPU6050(byte reg);

  int16_t getRawGyroZ(){ return rawGyroZ; };

  float getGyroZ(){ return gyroZ; };

  void calcGyroOffsets(bool console = false);

  float getGyroZoffset(){ return gyroZoffset; };

  void update();

  float getGyroAngleZ(){ return angleGyroZ; };
  
  float getAngleZ();

  void getDirection();

  private:

  TwoWire *wire;

  int16_t rawGyroZ;

  float gyroZoffset;

  float gyroZ;

  float angleGyroZ,angleAccZ;

  float angleZ;

  float interval;
  long preInterval;
};

#endif
