import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import '../controllers/BluetoothProvider.dart';
import 'BluetoothOffScreen.dart';
import 'FindDeviceScreen.dart';

class HomeDeviceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
        stream: FlutterBluePlus.instance.state,
        initialData: BluetoothState.unknown,
        builder: (context, snapshot) {
          final state = snapshot.data;
          Provider.of<BluetoothProvider>(context, listen: false)
              .bluetoothState = state!;
          if (state == BluetoothState.on) {
            return FindDevicesScreen();
          }
          return BluetoothOffScreen();
        },
      ),
    );
  }
}