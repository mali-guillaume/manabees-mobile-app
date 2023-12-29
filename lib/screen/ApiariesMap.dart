/// the screen shows all hives on a map

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';


import '../main.dart';
import '../models/Apiary_model.dart';
import '../models/NetworkConnectivity.dart';
import '../models/Hive_model.dart';
import '../partials/FloatingActionButton/SeparatedColumn.dart';
import '../services/ApiService.dart';
import '../services/Database_helper.dart';
import 'ApiaryHome.dart';

class ScreenApiaryMap extends StatefulWidget {
  const ScreenApiaryMap({
    Key? key,
  }) : super(key: key);

  @override
  State<ScreenApiaryMap> createState() => _ScreenApiaryMapState();
}

class _ScreenApiaryMapState extends State<ScreenApiaryMap>
    with TickerProviderStateMixin {
  Map _source = {ConnectivityResult.none: false};

  var position = null;
  late final mapController = AnimatedMapController(vsync: this);
  late List<Marker> marker = [];
  late Future<List<Apiary>?> _futureApiaries;
  late List<Marker> markers = [];
  double longitude = 0;
  double latitude = 0;

  @override
  void initState() {
    super.initState();
    _getLocation();

    _futureApiaries =
        DatabaseHelper.getAllApiaryByProprietaire("", user.toString());
    _futureApiaries.then((apiaries) {
      if (apiaries != null) {
        int i = 0;

        ///add one markers to show all hives
        for (var apiary in apiaries) {
          i++;
          longitude += apiary.longitude;
          latitude += apiary.latitude;
          markers.add(Marker(
              point: LatLng(apiary.latitude, apiary.longitude),
              builder: (context) => GestureDetector(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) => ApiaryHomePage(
                                apiary: apiary,
                              ));
                    },
                    child: getMaker(),
                  )));
        }
        longitude = longitude / i;
        latitude = latitude / i;
      }
    });
  }

  ///center map north
  void _centertoNorth() {
    mapController.animatedRotateTo(0.0, curve: Curves.ease);
  }

  ///center map position
  void _centertoPosition() {
    mapController.centerOnPoint(LatLng(position.latitude, position.longitude),
        curve: Curves.ease);
  }

  @override
  void dispose() {
    super.dispose();
    mapController.dispose();
  }

  Future<void> _getLocation() async {
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

    await Geolocator.checkPermission();
    await Geolocator.requestPermission();
    final currentposition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print("${currentposition.longitude}, ${currentposition.latitude}");

    setState(() {
      position = currentposition;
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
        body: FutureBuilder<List<Apiary>?>(
          future: _futureApiaries,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              int length = snapshot.data!.length;
              if (position == null) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                      center: LatLng(latitude, longitude),
                      zoom: 7.0,
                      minZoom: 1.0,
                      screenSize: size,
                      maxBounds:
                          LatLngBounds(LatLng(-90, -180), LatLng(90, 180))),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                      maxZoom: 22.0,
                      minZoom: 1.0,
                      minNativeZoom: 1,
                    ),
                    MarkerLayer(markers: markers)
                  ],
                );
              }
            } else if (snapshot.hasError) {
              return Text("No Apiary");
            }

            return CircularProgressIndicator();
          },
        ),
        floatingActionButton: SeparatedColumn(
          mainAxisSize: MainAxisSize.min,
          separator: const SizedBox(height: 12),
          children: [
            FloatingActionButton(
              onPressed: _centertoNorth,
              heroTag: 'center to North',
              child: Icon(Icons.explore),
              backgroundColor: Color(0xFFC69D43),
            ),
            FloatingActionButton(
              onPressed: _centertoPosition,
              heroTag: 'center to position',
              child: Icon(Icons.location_on_outlined),
              backgroundColor: Color(0xFFC69D43),
            ),
          ],
        ));
  }
}
