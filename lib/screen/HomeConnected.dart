///this screen is the first one you see when connected with the lastest graphic and 2 tabs,
/// one for the hive and the other one for the apiary
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';




import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import '../services/Database_helper.dart';

import '../main.dart';
import '../models/Dataset_model.dart';
import '../models/Hive_model.dart';
import '../models/SensorMysql_model.dart';
import '../partials/graphic/BarHiveView.dart';
import '../partials/graphic/CartesianHiveView.dart';
import '../partials/navbar/NavBar.dart';
import '../partials/sidebar/Sidebar.dart';
import '../routes/Routes.dart';
import '../services/ApiService.dart';

///this screen allow you to create the fist page when you know how to connect

class HomeConnected extends StatefulWidget {
  const HomeConnected({Key? key}) : super(key: key);

  @override
  State<HomeConnected> createState() => _HomeConnectedState();
}

class _HomeConnectedState extends State<HomeConnected> {
  List<Future<List<Dataset>>> futureDatasets = [];
  List<String> selectedSensors = [];
  late String graphic;
  late DateTime lastDay;
  late DateTime firstDay;
  late Hive hive;

  @override
  void initState() {
    super.initState();
    _loadFirstDay();
    _loadGraphic();
    _loadLastDay();
    _loadSensor();
    _loadHive();

  }

  Future<List<dynamic>> fetchData() async {
    print("la recup de toute les info");
    print(graphic);
    print(selectedSensors);
    print(hive);
    print(lastDay);
    print(firstDay);
    return [graphic, selectedSensors, hive, lastDay, firstDay];
  }


  Future<void> _loadSensor() async {
    final prefs = await SharedPreferences.getInstance();
    final sensorListString =
    prefs.getStringList('sensor');

    if (sensorListString == null) {
      return;
    }

    final widgetList = sensorListString.map((string) => string).toList();
    setState(() {
      selectedSensors = widgetList;
    });

  }

  Future<void> _loadHive() async {
    final prefs = await SharedPreferences.getInstance();
    int? hiveInt =prefs.getInt('hive');

    if (hiveInt == null) {
      return;
    }

    print("hiveInt = $hiveInt");

    List<Hive>? listHive = await DatabaseHelper.getHiveByID(hiveInt);
    Hive? hive = listHive?.first;

    setState(() {
      this.hive = hive!;
    });
  }


  ///get the graphic (cartesian or bar)
  Future<void> _loadGraphic() async {
    final prefs = await SharedPreferences.getInstance();
    final GraphiqueString =
    prefs.getString('graphic');

    if (GraphiqueString == null) {
      return;
    }

    setState(() {
      graphic = GraphiqueString;

    });
  }

  Future<void> _loadLastDay() async {
    final prefs = await SharedPreferences.getInstance();
    final LastDayString =
    prefs.getString('lastday');

    if (LastDayString == null) {

      return;
    }


    setState(() {
      lastDay = DateTime.parse(LastDayString);
    });
  }

  Future<void> _loadFirstDay() async {
    final prefs = await SharedPreferences.getInstance();
    final PremierJourString =
    prefs.getString('firstday');

    if (PremierJourString == null) {
      return;
    }
    setState(() {

      firstDay = DateTime.parse(PremierJourString);
    });
  }




  var user1 = user.toString();

  @override
  Widget build(BuildContext context) {
    largeurEcran = MediaQuery.of(context).size.width;
    hauteurEcran = MediaQuery.of(context).size.height;
    return Scaffold(
      drawer:
        const Drawer(
          child: SidebarScreen(),

      ),
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Color(0xFFC69D43),
        title: Text("Tableau de bord"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, kHomeConnectedRoute);
              },
              icon: Icon(Icons.home)),
        ],
      ),
      body: SafeArea(
          child: Column(
        children: <Widget>[
          const NavBar(),
          const SizedBox(
            height: 0,
          ),
          Expanded(

              ///retrieve all the information saved in the flutterSession to build graphic
              child: FutureBuilder<List<dynamic>>(
            future: fetchData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data![0] == "Bar") {

                  Hive hive = snapshot.data![2];
                  List<dynamic> mySelectedsensor = snapshot.data![1];
                  List<String> stringListSensor = mySelectedsensor
                      .map((element) => element.toString())
                      .toList();
                  return BarHiveView(
                      hive: hive,
                      lastDay: snapshot.data![3],
                      firstDay: snapshot.data![4],
                      selectedSensor: stringListSensor);
                } else if (snapshot.hasData &&
                    snapshot.data![0] == "Cartesian") {
                  Hive hive = snapshot.data![2];
                  List<dynamic> mySelectedsensor = snapshot.data![1];
                  List<String> stringListSensor = mySelectedsensor
                      .map((element) => element.toString())
                      .toList();
                  return CartesianHiveView(
                      hive: hive,
                      lastDay: snapshot.data![3],
                      firstDay: snapshot.data![4],
                      selectedSensor: stringListSensor);
                } else {
                  return Text("Not graph saved");
                }
              } else {
                return Shimmer.fromColors(
                  direction: ShimmerDirection.btt,
                  baseColor: Colors.grey.shade200,
                  highlightColor: Colors.grey.shade100,
                  child: Row(children: <Widget>[
                    SfCartesianChart(series: <ChartSeries>[
                      LineSeries<double, double>(
                        dataSource: [1, 2, 3, 4, 5],
                        xValueMapper: (double value, _) => value,
                        yValueMapper: (double value, _) => value,
                      )
                    ])
                  ]),
                );
              }
            },
          ))
        ],
      )),
    );
  }
}

var largeurEcran;
var hauteurEcran;
