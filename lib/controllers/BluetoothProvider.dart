import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothProvider extends ChangeNotifier {

  BluetoothState _bluetoothState = BluetoothState.unknown;

  BluetoothState get bluetoothState => _bluetoothState;

  set bluetoothState(BluetoothState state) {
    _bluetoothState = state;
    notifyListeners();
  }
}
