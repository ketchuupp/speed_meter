import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dataContainer.dart';
// import 'package:battery/battery.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Speedometer(),
            ThrottleWidget(),
            const SizedBox(height: 20),
            DetailsWidget(),
          ],
        ));
  }
}

class DetailsWidget extends StatefulWidget {
  const DetailsWidget({Key? key}) : super(key: key);

  @override
  _DetailsWidgetState createState() => _DetailsWidgetState();
}

class _DetailsWidgetState extends State<DetailsWidget> {
  @override
  void initState() {
    super.initState();
    setValues();
    checkStatus();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setValues() {
    if (_batCapacity != dataC.getMotorTemp()) {
      _motorTemp = dataC.getMotorTemp();
    }
    if (_motorCurrent != dataC.getMotorCurrent()) {
      _motorCurrent = dataC.getMotorCurrent();
    }
    if (_motorPower != dataC.getMotorPower()) {
      _motorPower = dataC.getMotorPower();
    }
    if (_batTemp != dataC.getBatteryTemp()) {
      _batTemp = dataC.getBatteryTemp();
    }
    if (_batCapacity != dataC.getBatteryCapacity()) {
      _batCapacity = dataC.getBatteryCapacity();
    }
    if (_batVoltage != dataC.getBatteryVoltage()) {
      _batVoltage = dataC.getBatteryVoltage();
    }
    if (_batCharge != dataC.getBatteryCharge()) {
      _batCharge = dataC.getBatteryCharge();
    }
    if (_speed != dataC.getSpeed()) {
      _speed = dataC.getSpeed();
    }
    if (_openThrottle != dataC.getThrottleOpening()) {
      _openThrottle = dataC.getThrottleOpening();
    }
  }

  //visable variables
  double _motorTemp = 0.0;
  double _motorCurrent = 0.0;
  double _motorPower = 0.0;
  double _batTemp = 0.0;
  double _batCapacity = 0.0;
  double _batVoltage = 0.0;
  double _batCharge = 0.0;
  double _speed = 0.0;
  double _openThrottle = 0.0;

  Future<void> checkStatus() async {
    while (true) {
      await Future.delayed(Duration(milliseconds: 10), () {
        if (mounted) {
          // if (dataC.getStatus() == true) {
          setState(() {
            setValues();
          });
          // dataC.statusActualized();
          // }
        }
      });
    }
  }

  TextStyle tStyle = const TextStyle(color: Colors.white, fontSize: 25.0);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              Expanded(
                  child: Transform.rotate(
                      angle: 90 * pi / 180,
                      child: Container(
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.battery_full,
                            size: 50,
                            color: Colors.blue,
                          )))),
              Expanded(
                  child: Container(
                      alignment: Alignment.center,
                      child: Text(_batCharge.toInt().toString() + '%',
                          style: tStyle))),
              Expanded(
                  child: Container(
                      alignment: Alignment.center,
                      child: Text(_batVoltage.toInt().toString() + 'V',
                          style: tStyle))),
              Expanded(
                  child: Container(
                      alignment: Alignment.center,
                      child: Text(_batCapacity.toInt().toString() + 'Ah',
                          style: tStyle))),
            ],
          ),
        ),
        Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Expanded(
                    child: Transform.rotate(
                        angle: 0 * pi / 180,
                        child: Container(
                            alignment: Alignment.center,
                            child: const Image(
                              color: Colors.blue,
                              height: 40,
                              width: 40,
                              image:
                                  const AssetImage('assets/electric-motor.png'),
                            )
                            // child: Icon(
                            //   Icons.electric_bike_outlined,
                            //   size: 50,
                            //   color: Colors.blue,
                            ))),
                Expanded(
                    child: Container(
                        alignment: Alignment.center,
                        child: Text(_motorTemp.toInt().toString() + '°C',
                            style: tStyle))),
                Expanded(
                    child: Container(
                        alignment: Alignment.center,
                        child: Text(_motorCurrent.toInt().toString() + 'A',
                            style: tStyle))),
                Expanded(
                    child: Container(
                        alignment: Alignment.center,
                        child: Text(_motorPower.toInt().toString() + 'W',
                            style: tStyle))),
              ],
            ))
      ],
    ));
  }
}

class ThrottleWidget extends StatefulWidget {
  const ThrottleWidget({Key? key}) : super(key: key);

  @override
  _ThrottleWidgetState createState() => _ThrottleWidgetState();
}

class _ThrottleWidgetState extends State<ThrottleWidget>
    with AutomaticKeepAliveClientMixin {
  double shapePointerValue = 0.0;
  var _maxVal = 50.0;
  var _minVal = -50.0;
  var throttleValue = 50.0;

  @override
  bool get wantKeepAlive => true;

  Future<void> checkStatus() async {
    while (true) {
      await Future.delayed(Duration(milliseconds: 10), () {
        if (mounted) {
          if (throttleValue != dataC.getThrottleOpening()) {
            setState(() {
              throttleValue = dataC.getThrottleOpening();
            });
            // dataC.statusActualized();
          }
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: SfLinearGauge(
        animationDuration: 2000,
        minimum: 0,
        maximum: 100,
        showTicks: false,
        axisTrackStyle: LinearAxisTrackStyle(
          thickness: 30,
          gradient: LinearGradient(
              colors: [Colors.blue[700]!, Colors.white, Colors.blue[700]!],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const <double>[0.0, 0.5, 1.0],
              tileMode: TileMode.clamp),
          // color: Colors.white,
        ),
        axisLabelStyle: TextStyle(
          fontSize: 0,
          color: Colors.grey[900],
        ),
        // axisTrackStyle: ,
        markerPointers: [
          LinearWidgetPointer(
            value: throttleValue,
            // value: 0,
            child: Container(
              height: 50,
              width: 3,
              decoration: const BoxDecoration(color: Colors.blueAccent),
            ),
            onValueChanged: (value) {
              setState(
                () {
                  throttleValue = value;
                },
              );
            },
          )
        ],
      ),
    );
  }
}

class Speedometer extends StatefulWidget {
  Speedometer({Key? key}) : super(key: key);

  @override
  _SpeedometerState createState() => _SpeedometerState();
}

class _SpeedometerState extends State<Speedometer> {
  var _maxVal = 100.0;
  var speedValue = 0.0;

  Future<void> checkStatus() async {
    while (true) {
      await Future.delayed(Duration(milliseconds: 10), () {
        if (mounted) {
          // if (dataC.getStatus() == true) {
          setState(() {
            speedValue = dataC.getSpeed();
          });
          // dataC.statusActualized();
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SfRadialGauge(
        animationDuration: 10,
        enableLoadingAnimation: false,
        axes: <RadialAxis>[
          RadialAxis(
              minimum: 0,
              maximum: _maxVal,
              labelOffset: 20,
              axisLineStyle: const AxisLineStyle(
                  thicknessUnit: GaugeSizeUnit.factor, thickness: 0.03),
              majorTickStyle: const MajorTickStyle(
                  length: 6, thickness: 6, color: Colors.white),
              minorTickStyle: const MinorTickStyle(
                  length: 4, thickness: 4, color: Colors.white),
              axisLabelStyle: GaugeTextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
              ranges: <GaugeRange>[
                GaugeRange(
                  startValue: 0,
                  endValue: _maxVal,
                  sizeUnit: GaugeSizeUnit.factor,
                  startWidth: 0.04,
                  endWidth: 0.04,
                  gradient: const SweepGradient(
                    colors: const <Color>[
                      Colors.green,
                      Colors.blue,
                      Colors.red
                    ],
                    stops: const <double>[0.0, 0.5, 1],
                  ),
                ),
              ],
              pointers: <GaugePointer>[
                NeedlePointer(
                  value: speedValue,
                  needleLength: 0.5,
                  enableAnimation: true,
                  animationType: AnimationType.ease,
                  needleStartWidth: 2.5,
                  needleEndWidth: 8,
                  needleColor: Colors.red,
                  knobStyle: const KnobStyle(knobRadius: 0.09),
                ),
              ],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                    widget: Container(
                        child: Column(children: <Widget>[
                      Text(
                        speedValue.toString(),
                        style: const TextStyle(
                            fontSize: 55,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 0),
                      Text(
                        'km/h',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      )
                    ])),
                    angle: 90,
                    positionFactor: 1.3)
              ])
        ],
      ),
    );
  }
}
