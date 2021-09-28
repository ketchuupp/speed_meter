import 'package:battery/battery.dart';

DataCluster dataC = new DataCluster();

class DataCluster {
  double _motorTemp = 0.0;
  double _motorCurrent = 0.0;
  double _motorPower = 0.0;
  double _batteryTemp = 0.0;
  double _batteryCapacity = 0.0;
  double _batteryVoltage = 0.0;
  double _batteryCharge = 0.0;
  double _speed = 0.0;
  double _openThrottle = 50.0;

  bool _isChangedMotorTemp = true;
  bool _isChangedMotorCurrent = true;
  bool _isChangedMotorPower = true;
  bool _isChangedBatteryCapacity = true;
  bool _isChangedBatteryTemp = true;
  bool _isChangedBatteryVoltage = true;
  bool _isChangedBateryCharge = true;
  bool _isChangedSpeed = true;
  bool _isChangedOpenThrottle = true;

  // getters
  double getMotorTemp() {
    _isChangedMotorTemp = false;
    return _motorTemp;
  }

  double getMotorCurrent() {
    _isChangedMotorCurrent = false;
    return _motorCurrent;
  }

  double getMotorPower() {
    _isChangedMotorPower = false;
    return _motorPower;
  }

  double getBatteryTemp() {
    _isChangedBatteryTemp = false;
    return _batteryTemp;
  }

  double getBatteryCapacity() {
    _isChangedBatteryCapacity = false;
    return _batteryCapacity;
  }

  double getBatteryCharge() {
    _isChangedBateryCharge = false;
    return _batteryCharge;
  }

  double getBatteryVoltage() {
    _isChangedBatteryVoltage = false;
    return _batteryVoltage;
  }

  double getSpeed() {
    _isChangedSpeed = false;
    return _speed;
  }

  double getThrottleOpening() {
    _isChangedOpenThrottle = false;
    return _openThrottle;
  }

  // setters
  void setMotorTemp(double v) {
    _motorTemp = v;
    _isChangedMotorTemp = true;
  }

  void setMotorCurrent(double v) {
    _motorCurrent = v;
    _isChangedMotorCurrent = true;
  }

  void setMotorPower(double v) {
    _motorPower = v;
    _isChangedMotorPower = true;
  }

  void setBatteryTemp(double v) {
    _batteryTemp = v;
    _isChangedBatteryTemp = true;
  }

  void setBatteryCapacity(double v) {
    _batteryCapacity = v;
    _isChangedBatteryCapacity = true;
  }

  void setBatteryCharge(double v) {
    _batteryCharge = v;
    _isChangedBateryCharge = true;
  }

  void setBatteryVoltage(double v) {
    _batteryVoltage = v;
    _isChangedBatteryVoltage = true;
  }

  void setSpeed(double v) {
    _speed = v;
    _isChangedSpeed = true;
  }

  void setThrottleOpening(double v) {
    _openThrottle = v;
    _isChangedOpenThrottle = true;
  }
}
