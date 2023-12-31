import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/BluetoothProvider.dart';

class BluetoothOffScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context);
    final state = bluetoothProvider.bluetoothState;

    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state != null ?
              state.toString().substring(15) : 'not available'}.',

            ),
          ],
        ),
      ),
    );
  }
}