///this screen show the information for the hive

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/NetworkConnectivity.dart';
import '../models/Hive_model.dart';

class ScreenHiveInformation extends StatefulWidget {
  final Hive hive;
  const ScreenHiveInformation({Key? key, required this.hive}) : super(key: key);

  @override
  State<ScreenHiveInformation> createState() => _ScreenHiveInformationState();
}

class _ScreenHiveInformationState extends State<ScreenHiveInformation> {


  ///display the information for the hive

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFFFFAEB),
        body: Column(
          children: <Widget>[
            Text(widget.hive.toString()),
          ],
        ));
  }
}
