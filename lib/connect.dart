// For performing some operations asynchronously
import 'dart:async';
import 'dart:convert';
// import 'dart:ffi';
import 'dart:typed_data';
import 'dataContainer.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothApp extends StatefulWidget {
  const BluetoothApp({Key? key}) : super(key: key);

  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp>
    with AutomaticKeepAliveClientMixin {
  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // Get the instance of the Bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  // Track the Bluetooth connection with the remote device
  BluetoothConnection? connection;
  // To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection!.isConnected;

  // This member variable will be used for tracking
  // the Bluetooth device connection state
  int? _deviceState;

  @override
  bool get wantKeepAlive => true;

  Map<String, Color> colors = {
    'onBorderColor': Colors.green,
    'offBorderColor': Colors.red,
    'neutralBorderColor': Colors.transparent,
    'onTextColor': Colors.green,
    'offTextColor': Colors.red,
    'neutralTextColor': Colors.blue,
  };

  Future<bool> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the bluettoth is off, then turn it on girst
    // and then retrieve the devices that are paired.

    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }

  // Define o new class member variable
  // for storing the device list
  List<BluetoothDevice> _devicesList = [];

  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _devicesList = devices;
    });
  }

  // Define a member variable to track
  // when the disconnection is in progress
  bool isDisconnecting = false;

  @override
  void dispose() {
    // if (isConnected) {
    //   isDisconnecting = true;
    //   // An error may occur here
    //   if (connection != null) {
    //     connection!.dispose();
    //   }
    //   connection = null;
    // }

    super.dispose();
  }

  // Define this member variable for string
  // the current device connectivity status
  BluetoothDevice? _device;
  bool _connected = false;
  bool _isButtonUnavailable = false;

  @override
  void initState() {
    super.initState();

    //get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    // _deviceState = 0; //neutral

    // If the bluetooth of the device is not enabled,
    // then request permission to turn on Bluetooth
    // as the app starts up
    enableBluetooth();

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }

        //for retrieving the paired device list
        getPairedDevices();
      });
    });
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];

    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devicesList.forEach((device) {
        String? _name = device.name;
        items.add(DropdownMenuItem(
          child: Text(_name!),
          value: device,
        ));
      });
    }
    return items;
  }

  Future listenmess() async {
    connection!.input!.listen((Uint8List data) {
      print('Data incoming: ${ascii.decode(data)}');
      connection!.output.add(data); // Sending data
      show('Data incoming: ${ascii.decode(data)}');
    }).onDone(() {
      print('Disconnected by remote request');
    });

    return;
  }

  List<String> dataIncoming = [];
  late String s;
  late String dataIncome = '';

  void _connect() async {
    setState(() {
      _isButtonUnavailable = true;
    });
    if (_device == null) {
      show('No device selected');
      final snackBar = SnackBar(
        content: const Text('No device selected!'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      _isButtonUnavailable = false;
      return;
    } else {
      if (!isConnected) {
        try {
          await BluetoothConnection.toAddress(_device?.address)
              .then((_connection) {
            print('Connected to the device');
            connection = _connection;
            _connected = true;
            setState(() {
              final snackBar = SnackBar(
                content: const Text('Device connected!'),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            });

            connection?.input?.listen((Uint8List data) async {
              // dataIncoming.add(data);
              // print('Data incoming: ${ascii.decode(data)}');
              connection!.output.add(data); // Sending data

              s = new String.fromCharCodes(data);

              dataIncoming.add(s);
              String buff = dataIncoming.join().toString();

              buff = buff.replaceAll("\n", "");
              buff = buff.replaceAll("\r", "");

              if (buff.length >= 6) {
                // String buff = dataIncoming.join().toString();
                print('Buff data: ' + buff);
                dataIncoming.clear();
                var t = buff.substring(2);
                dataIncoming.clear();

                if (buff.contains('mt')) {
                  dataC.setMotorTemp(double.parse(t));
                } else if (buff.contains('mc')) {
                  dataC.setMotorCurrent(double.parse(t));
                } else if (buff.contains('mp')) {
                  dataC.setMotorPower(double.parse(t));
                } else if (buff.contains('bt')) {
                  dataC.setBatteryTemp(double.parse(t));
                } else if (buff.contains('bc')) {
                  dataC.setBatteryCapacity(double.parse(t));
                } else if (buff.contains('bv')) {
                  dataC.setBatteryVoltage(double.parse(t));
                } else if (buff.contains('bh')) {
                  dataC.setBatteryCharge(double.parse(t));
                } else if (buff.contains('sp')) {
                  dataC.setSpeed(double.parse(t));
                } else if (buff.contains('th')) {
                  dataC.setThrottleOpening(double.parse(t));
                }
              }
            }).onDone(() {
              print('Disconnected by remote request');
            });

            // listenmess();
          }).catchError((error) {
            print('Cannot connect, exception occurred');
            print(error);
          });
          // show('Device connected');

          setState(() => _isButtonUnavailable = false);
        } catch (e) {
          // show('Cannot connect device!');
          final snackBar = SnackBar(
            content: const Text('Cannot connect device!'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    }
  }

  final TextStyle tStyle = new TextStyle(color: Colors.white, fontSize: 20.0);

  @mustCallSuper
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.grey[900],
        body: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Visibility(
                visible: _isButtonUnavailable &&
                    _bluetoothState == BluetoothState.STATE_ON,
                child: const LinearProgressIndicator(
                  backgroundColor: Colors.yellow,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Enable Bluetooth',
                        style: tStyle,
                      ),
                    ),
                    TextButton.icon(
                      icon: Icon(
                        Icons.refresh,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Refresh",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () async {
                        // So, that when new devices are paired
                        // while the app is running, user can refresh
                        // the paired devices list.
                        await getPairedDevices().then((_) {
                          final snackBar = SnackBar(
                            content: const Text('Device list refreshed!'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                // Some code to undo the change.
                              },
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        });
                      },
                    ),
                    Switch(
                      value: _bluetoothState.isEnabled,
                      onChanged: (bool value) {
                        future() async {
                          if (value) {
                            await FlutterBluetoothSerial.instance
                                .requestEnable();
                          } else {
                            await FlutterBluetoothSerial.instance
                                .requestDisable();
                          }

                          await getPairedDevices();
                          _isButtonUnavailable = false;

                          if (_connected) {
                            _disconnect();
                          }
                        }

                        future().then((_) {
                          setState(() {});
                        });
                      },
                    ),
                  ],
                ),
              ),
              Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      const Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: const Text(
                          "PAIRED DEVICES",
                          style: TextStyle(fontSize: 24, color: Colors.blue),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Device:', style: tStyle),
                            DropdownButton(
                              iconSize: 24,
                              dropdownColor: Colors.grey[900],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                              items: _getDeviceItems(),
                              onChanged: (value) => setState(
                                  () => _device = value as BluetoothDevice),
                              value: _devicesList.isNotEmpty ? _device : null,
                            ),
                            ElevatedButton(
                              onPressed: _isButtonUnavailable
                                  ? null
                                  : _connected
                                      ? _disconnect
                                      : _connect,
                              child:
                                  Text(_connected ? 'Disconnect' : 'Connect'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    color: Colors.blue,
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          "NOTE: If you cannot find the device in the list, please pair the device by going to the bluetooth settings",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          child: const Text("Bluetooth Settings"),
                          onPressed: () {
                            FlutterBluetoothSerial.instance.openSettings();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _disconnect() async {
    // Closing the Bluetooth connection
    await connection?.close();
    // show('Device disconnected');
    final snackBar = SnackBar(
      content: const Text('Device disconnected!'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    // Update the [_connected] variable
    if (!connection!.isConnected) {
      setState(() {
        _connected = false;
      });
    }
  }

  // Method to send message
// for turning the Bluetooth device on
  void _sendOnMessageToBluetooth() async {
    connection?.output.add(utf8.encoder.convert("1" + "\r\n"));
    await connection?.output.allSent;
    show('Device Turned On');
    setState(() {
      _deviceState = 1; // device on
    });
  }

// Method to send message
// for turning the Bluetooth device off
  void _sendOffMessageToBluetooth() async {
    connection?.output.add(utf8.encoder.convert("0" + "\r\n"));
    await connection?.output.allSent;
    show('Device Turned Off');
    setState(() {
      _deviceState = -1; // device off
    });
  }

  void show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) {
    // _scaffoldKey.currentState?.showSnackBar(
    //   SnackBar(
    //     content: Text(message),
    //     padding: EdgeInsets.all(6.0),
    //     duration: Duration(seconds: 2),
    //     // behavior: SnackBarBehavior.floating,
    //     action: SnackBarAction(
    //       label: 'OK',
    //       onPressed: () {
    //         // Some code to undo the chSange.
    //         // print('zaundowano');
    //       },
    //     ),
    //   ),
    // );
  }

  Color giveColor() {
    if (_deviceState == 0) {
      return Colors.transparent;
    } else {
      if (_deviceState == 1) {
        return Colors.green;
      } else {
        return Colors.red;
      }
    }
  }

  // void _onDataReceived(Uint8List data) {
  //   // Allocate buffer for parsed data
  //   int backspacesCounter = 0;
  //   data.forEach((byte) {
  //     if (byte == 8 || byte == 127) {
  //       backspacesCounter++;
  //     }
  //   });
  //   Uint8List buffer = Uint8List(data.length - backspacesCounter);
  //   int bufferIndex = buffer.length;

  //   // Apply backspace control character
  //   backspacesCounter = 0;
  //   for (int i = data.length - 1; i >= 0; i--) {
  //     if (data[i] == 8 || data[i] == 127) {
  //       backspacesCounter++;
  //     } else {
  //       if (backspacesCounter > 0) {
  //         backspacesCounter--;
  //       } else {
  //         buffer[--bufferIndex] = data[i];
  //       }
  //     }
  //   }
  // }

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
