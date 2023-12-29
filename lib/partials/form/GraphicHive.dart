///the widget allows get to ++ xcthe type of graphic and the Sensor

import 'package:flutter/material.dart';
import '../../models/SensorApi_model.dart';
import '../../models/SensorMysql_model.dart';
import '../../models/TimeStamp_model.dart';
import '../../services/ApiService.dart';
import 'package:multiselect/multiselect.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/Hive_model.dart';
import '../graphic/BarHiveView.dart';
import '../graphic/CartesianHiveView.dart';

class HiveGraphic extends StatefulWidget {
  final Hive hive;
  final int index;
  const HiveGraphic({
    Key? key,
    required this.hive,
    required this.index,
  }) : super(key: key);

  @override
  State<HiveGraphic> createState() =>
      _HiveGraphicState();
}

class _HiveGraphicState extends State<HiveGraphic> {
  List<String> graphic = ['Bar', 'Cartesian'];
  late String selectedgraphic = "";
  late DateTime firstDay;
  late DateTime lastDay;
  bool graphicChanged = false;

  late Future<List<Sensor_model>> _futureSensor;
  DateTimeRange? _dateRange;
  late int selectionDate = 0;
  DateTimeRange? _dateTimeRange;
  List<String> selectedSensors = [];
  bool NotSensor = false;
  late int index;

  @override
  void initState() {
    super.initState();
    selectedSensors = [];
    _futureSensor = httpService().getDatasetName(widget.hive.hiveid);

    _loadGraphic();
    _loadFirstDay();
    _loadLastDay();
    _loadSensor();

  }


  ///get all Sensor
  Future<void> _loadSensor() async {
    final prefs = await SharedPreferences.getInstance();
    final sensorListString =
        prefs.getStringList('sensor${widget.hive.Name}${widget.index}');

    if (sensorListString == null) {
      return;
    }

    final widgetList = sensorListString.map((string) => string).toList();
    setState(() {
      selectedSensors = widgetList;
    });
  }


  ///get the graphic (cartesian or bar)
  Future<void> _loadGraphic() async {
    final prefs = await SharedPreferences.getInstance();
    final GraphiqueString =
        prefs.getString('graphic${widget.hive.Name}${widget.index}');

    if (GraphiqueString == null) {
      return;
    }

    setState(() {
      selectedgraphic = GraphiqueString;

    });
  }

  Future<void> _loadLastDay() async {
    final prefs = await SharedPreferences.getInstance();
    final DernierJourString =
        prefs.getString('lastday${widget.hive.Name}${widget.index}');

    if (DernierJourString == null) {

      return;
    }


    setState(() {
      lastDay = DateTime.parse(DernierJourString);
    });
  }

  Future<void> _loadFirstDay() async {
    final prefs = await SharedPreferences.getInstance();
    final PremierJourString =
        prefs.getString('firstday${widget.hive.Name}${widget.index}');

    if (PremierJourString == null) {
      return;
    }
    setState(() {

      firstDay = DateTime.parse(PremierJourString);
    });
  }

  Future<void> BackupSensor() async {
    final widgetStrings = selectedSensors.map((widget) => widget).toList();
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
        'sensor${widget.hive.Name}${widget.index}', widgetStrings);
  }

  Future<void> BackupGraphic() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'graphic${widget.hive.Name}${widget.index}', selectedgraphic);
  }

  Future<void> BackupLastDay() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'lastday${widget.hive.Name}${widget.index}', lastDay.toString());
  }

  Future<void> BackupFirstDay() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'firstday${widget.hive.Name}${widget.index}', firstDay.toString());
  }

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(days: 7));




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFFFFAEB),
        body: Column(
          children: <Widget>[
        Row(children: <Widget>[
          SizedBox(
          width: 20,
        ),
      Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                color: Colors.grey),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: DropdownButtonFormField(

                  value: selectedgraphic.isEmpty
                      ? null
                      : selectedgraphic,
                  decoration: InputDecoration(
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 20),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none),
                  items: graphic.map((String option) {
                    return DropdownMenuItem(

                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  hint: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "selected an option",
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      )),
                  onChanged: (value) {
                    setState(()  {
                      selectedSensors = [];
                      selectedgraphic = value!;


                      BackupGraphic();
                      graphicChanged = true;
                    });
                  }),
            ),
          )),
      SizedBox(
        width: 20,
      ),
            FutureBuilder<List<Sensor_model>?>(

              future: selectedgraphic == 'Bar'
                  ? getSensorFromSQLiteorApiBatonnet(widget.hive)
                  : getSensorFromSQLiteorApi(widget.hive),
              builder: (context, snapshot) {
                if (graphicChanged) {
                  selectedSensors = [];
                  graphicChanged = false;
                }
                if (snapshot.hasData) {
                  List<String> Namesensor =
                      snapshot.data!.map((sensor) => sensor.Name).toList();
                  NotSensor = true;
                  return
                    Expanded(
                        child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25.0),
                                color: Colors.grey),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(25.0),
                                child: DropDownMultiSelect(
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 20),

                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none),
                                  options: Namesensor,
                                  selectedValues: selectedSensors,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedSensors = value;
                                      BackupSensor();
                                    });
                                  },
                                  whenEmpty: 'Select the sensors',
                                ))));

                } else if (snapshot.hasError) {
                  return Row(
                    children: [
                      Expanded(
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25.0),
                                  color: Colors.grey),
                              child: SizedBox(
                                height: 50,
                                child: Center(
                                  child: Text(
                                    "you cannot select a graphic",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ))),
                      SizedBox(
                        width: 20,
                      ),

                      Expanded(
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25.0),
                                  color: Colors.grey),
                              child: SizedBox(
                                height: 50,
                                child: Center(
                                  child: Text(
                                    "you don't have a sensor in the hive",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ))),
                      SizedBox(
                        width: 20,
                      ),
                    ],
                  );
                }

                // By default, show a loading spinner.
                return CircularProgressIndicator();
              },
            ),
        SizedBox(
          width: 20,
        ),
        ]),

            Expanded(
                child: selectedgraphic != ""
                    ? selectedgraphic == "Cartesian"
                        ? CartesianHiveView(
                            hive: widget.hive,
                            lastDay: lastDay,
                            firstDay: firstDay,
                            selectedSensor: selectedSensors,
                          )
                        : BarHiveView(
                            hive: widget.hive,
                            lastDay: lastDay,
                            firstDay: firstDay,
                            selectedSensor: selectedSensors,
                          )
                    : Text("choose a graphic")),
            SizedBox(),
            FutureBuilder<List<TimeStamp>?>(
              future: getTimeFromSQLiteorApi(widget.hive),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  lastDay = snapshot.data![0].max;
                  firstDay = snapshot.data![0].max
                      .subtract(Duration(days: selectionDate));

                  print("$lastDay");

                  //return Text(snapshot.data.toString());
                  return Container(
                    child: Column(children: <Widget>[
                      SizedBox(
                        height: 16,
                      ),
                      SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.all(16),
                          physics: BouncingScrollPhysics(),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ElevatedButton(
                                  onPressed: () async {
                                    final DateTimeRange? newDateRange =
                                        await showDateRangePicker(
                                      context: context,
                                      firstDate: snapshot.data![0].min,
                                      // 1461 jours = 4 ans
                                      lastDate: snapshot.data![0].max,
                                      initialDateRange: _dateRange ??
                                          DateTimeRange(
                                            start: selectionDate != 0
                                                ? snapshot.data![0].max
                                                    .subtract(Duration(
                                                        days: selectionDate))
                                                : snapshot.data![0].max
                                                    .subtract(
                                                        Duration(days: 7)),
                                            end: snapshot.data![0].max,
                                          ),
                                    );
                                    if (newDateRange != null) {

                                      _updateStartDate(newDateRange.start);
                                      _updateEndDate(newDateRange.end);
                                    }
                                    setState(() {
                                      _dateRange = newDateRange;
                                    });
                                  },
                                  child: Text('selected a period')),
                              SizedBox(
                                height: 16,
                              ),
                              SizedBox(
                                width: 16,
                              ),
                              ElevatedButton(
                                  onPressed: DateTimeRange(
                                                  start: snapshot.data![0].min,
                                                  end: snapshot.data![0].max)
                                              .duration >
                                          Duration(days: 7)
                                      ? () {
                                          selectionDate = 7;
                                          _updateEndDate(snapshot.data![0].max);

                                          _updateStartDate(snapshot.data![0].max
                                              .subtract(Duration(
                                                  days: selectionDate)));


                                        }
                                      : null,
                                  child: Text("a week")),
                              SizedBox(
                                width: 16,
                              ),
                              ElevatedButton(
                                  onPressed: DateTimeRange(
                                                  start: snapshot.data![0].min,
                                                  end: snapshot.data![0].max)
                                              .duration >
                                          Duration(days: 30)
                                      ? () {
                                          selectionDate = 30;
                                          _updateEndDate(snapshot.data![0].max);

                                          _updateStartDate(snapshot.data![0].max
                                              .subtract(Duration(
                                                  days: selectionDate)));
                                        }
                                      : null,
                                  child: Text("a month")),
                              SizedBox(
                                width: 16,
                              ),
                              ElevatedButton(
                                  onPressed: DateTimeRange(
                                                  start: snapshot.data![0].min,
                                                  end: snapshot.data![0].max)
                                              .duration >
                                          Duration(days: 6 * 30)
                                      ? () {
                                          selectionDate = 6 * 30;
                                          _updateEndDate(snapshot.data![0].max);

                                          _updateStartDate(snapshot.data![0].max
                                              .subtract(Duration(
                                                  days: selectionDate)));

                                        }
                                      : null,
                                  child: Text(
                                    "3 months",
                                  )),
                              SizedBox(
                                width: 16,
                              ),
                              ElevatedButton(
                                  onPressed: DateTimeRange(
                                                  start: snapshot.data![0].min,
                                                  end: snapshot.data![0].max)
                                              .duration >
                                          Duration(days: 3 * 30)
                                      ? () {
                                          selectionDate = 6 * 30;
                                          _updateEndDate(snapshot.data![0].max);

                                          _updateStartDate(snapshot.data![0].max
                                              .subtract(Duration(
                                                  days: selectionDate)));

                                        }
                                      : null,
                                  child: Text(
                                    "6 mois",
                                  )),
                              SizedBox(
                                width: 16,
                              ),
                              ElevatedButton(
                                  onPressed: DateTimeRange(
                                                  start: snapshot.data![0].min,
                                                  end: snapshot.data![0].max)
                                              .duration >
                                          Duration(days: 365)
                                      ? () {
                                          selectionDate = 365;
                                          _updateStartDate(
                                              snapshot.data![0].max);

                                          _updateEndDate(snapshot.data![0].max
                                              .subtract(Duration(
                                                  days: selectionDate)));

                                        }
                                      : null,
                                  child: Text(
                                    "a year",
                                  )),
                              SizedBox(
                                width: 16,
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    selectionDate = DateTimeRange(
                                            start: snapshot.data![0].min,
                                            end: snapshot.data![0].max)
                                        .duration
                                        .inDays;
                                    _updateEndDate(snapshot.data![0].max);

                                    _updateStartDate(snapshot.data![0].max
                                        .subtract(
                                            Duration(days: selectionDate)));


                                  },
                                  child: Text(
                                    "Max time",
                                  ))
                            ],
                          ))
                    ]),
                  );
                } else if (snapshot.hasError) {
                  return Text("you haven't data");
                }

                // By default, show a loading spinner.
                return CircularProgressIndicator();
              },
            ),
          ],
        ));
  }

  void _updateStartDate(DateTime newStartDate) {
    setState(() {
      firstDay = newStartDate;
      BackupFirstDay();
    });
  }

  void _updateEndDate(DateTime newEndDate) {
    setState(() {
      lastDay = newEndDate;
      BackupLastDay();
    });
  }
}
