/// the screen allows to display a map a apiary

import 'dart:async';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';

import 'package:latlong2/latlong.dart';


import '../models/Apiary_model.dart';

import '../partials/FloatingActionButton/SeparatedColumn.dart';

class ScreenApiaryInformation extends StatefulWidget {
  final Apiary apiary;
  const ScreenApiaryInformation({Key? key, required this.apiary})
      : super(key: key);

  @override
  State<ScreenApiaryInformation> createState() =>
      _ScreenApiaryInformationState();
}

class _ScreenApiaryInformationState extends State<ScreenApiaryInformation>
    with TickerProviderStateMixin {
  var position;
  late final mapController = AnimatedMapController(vsync: this);
  late List<Marker> marker = [];

  ///center map north
  void _centertoNorth() {
    mapController.animatedRotateTo(0.0, curve: Curves.ease);
  }

  ///center map position
  void _centertoPosition() {
    mapController.centerOnPoint(
        LatLng(widget.apiary.latitude, widget.apiary.longitude),
        curve: Curves.ease);
  }

  @override
  void initState() {
    super.initState();

    ///recovery the position of the apiary
    _getLocation();
  }

  @override
  void dispose() {
    //_networkConnectivity.disposeStream();
    super.dispose();
    mapController.dispose();
  }

  Future<void> _getLocation() async {
    setState(() {
      marker = <Marker>[
        Marker(
            point: LatLng(widget.apiary.latitude, widget.apiary.longitude),
            builder: (context) => GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text(widget.apiary.toString()),
                            ));
                  },
                  child: getMaker(),
                ))
      ];
    });
  }


  getMaker() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: Icon(Icons.location_on_outlined),
    );
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Color(0xFFFFFAEB),
        body: Column(
          children: <Widget>[
            Text(widget.apiary.toString()),
            Expanded(
                child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                  center:
                      LatLng(widget.apiary.latitude, widget.apiary.longitude),
                  zoom: 14.0,
                  screenSize: size,
                  maxBounds: LatLngBounds(LatLng(-90, -180), LatLng(90, 180))),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: marker,
                ),
              ],
            )),
          ],
        ),
        floatingActionButton: SeparatedColumn(
          mainAxisSize: MainAxisSize.min,
          separator: const SizedBox(height: 12),
          children: [
            FloatingActionButton(
              onPressed: _centertoNorth,
              heroTag: 'Rotate Nord apiary',
              child: const Text("N"),
              backgroundColor: Color(0xFFC69D43),
            ),
            FloatingActionButton(
              onPressed: _centertoPosition,
              heroTag: 'Return localisation apiary',
              child: const Icon(Icons.location_on_outlined),
              backgroundColor: Color(0xFFC69D43),
            ),
          ],
        ));
  }
}
