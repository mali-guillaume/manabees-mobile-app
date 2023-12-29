///this screen contain the calendar + the list of notes of the day
///(this widget also allows to edit and delete note )

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/Apiary_model.dart';
import '../../models/Hive_model.dart';
import '../../models/NoteApiary_model.dart';
import '../../models/Note_model.dart';
import '../../services/Database_helper.dart';
import '../PopUp/NoteDelApiary.dart';
import '../PopUp/NoteDelHive.dart';
import '../PopUp/NoteEditorApiary.dart';
import '../PopUp/NoteEditorHive.dart';

class CalendarApiaryWidget extends StatefulWidget {
  final Apiary apiary;
  final Function(DateTime) onDateSeleted;
  Future<List<NoteApiary>?> futureNoteApiary;
  Map<String, List<dynamic>> mySelectedEvents = {};
  final Map<DateTime, List<dynamic>> eventsApiary;
  CalendarApiaryWidget(
      {Key? key,
      required this.apiary,
      required this.onDateSeleted,
      required this.futureNoteApiary,
      required this.mySelectedEvents,
      required this.eventsApiary})
      : super(key: key);

  @override
  State<CalendarApiaryWidget> createState() => _CalendarApiaryWidgetState();
}

class _CalendarApiaryWidgetState extends State<CalendarApiaryWidget> {
  DateTime _focusedDay = DateTime.now();
  CalendarFormat format = CalendarFormat.month;
  late DateTime date;
  var EventDay;
  Map<DateTime, List<dynamic>> _eventsHive = {};
  final ScrollController _controllerNoteApiary = ScrollController();
  final ScrollController _controllerHive = ScrollController();
  late int indexHive;
  late int indexHive1;
  late int DisplayHive = 0;
  var selectedDate;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedDate = _focusedDay;
    _loadEventsHive();

    //loadPreviousEvents();
  }

  ///add item to list to display a marker on the calendar
  Future<void> _loadEventsHive() async {
    List<Hive>? hive =
        await DatabaseHelper.getHiveSearchByApiary("", widget.apiary);

    for (int i = 0; i < hive.length; i++) {
      final eventsHive = await DatabaseHelper.getAllNotes(hive[i]);

      setState(() {
        _eventsHive = {};
        if (eventsHive != null) {
          for (final event in eventsHive) {
            final date = event.date;
            final key = DateFormat('yyyy-MM-dd').parse(date);
            if (_eventsHive[key] == null) {
              _eventsHive[key] = [event];
            } else {
              _eventsHive[key]!.add(event);
            }
          }
        }
      });
    }
  }

  ///search all the hives of an apiary
  Future<List<Hive>> getHiveByApiary() async {
    return await DatabaseHelper.getHiveSearchByApiary("", widget.apiary);
  }

  ///collect all the note from a hive
  Future<Map<Hive, List<Note>>> getNoteByHive(List<Hive> hive) async {
    Map<Hive, List<Note>> NoteHive = {};
    if (hive.isEmpty) {
      return NoteHive;
    }
    for (int i = 0; i < hive.length; i++) {
      final listNote =
          await DatabaseHelper.getAllNotesofDay(selectedDate, hive[i]);

      if (listNote != null && listNote.isNotEmpty) {
        NoteHive.addAll({hive[i]: listNote});
      }
    }
    return NoteHive;
  }

  ///this function allows to calculate the height of the screen
  double getHeight(CalendarFormat format) {
    double heightscreen = MediaQuery.of(context).size.height;
    return format == CalendarFormat.month
        ? heightscreen / 2
        : format == CalendarFormat.twoWeeks
            ? heightscreen / 4
            : heightscreen / 5;
  }


  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Scrollbar(
            thumbVisibility: true,
            interactive: true,
            controller: _controllerNoteApiary,
            thickness: 8,
            scrollbarOrientation: ScrollbarOrientation.right,
            child: SingleChildScrollView(
                controller: _controllerNoteApiary,
                child: Container(
                    height: height,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                            child: SizedBox(
                                height: getHeight(format),
                                child: TableCalendar(
                                  shouldFillViewport: true,
                                  eventLoader: (date) {
                                    final key = DateTime(
                                        date.year, date.month, date.day);
                                    List<dynamic> events = [];
                                    if (widget.eventsApiary[key] != null) {
                                      events.add("Apiary");
                                    }
                                    if (_eventsHive[key] != null) {
                                      events.add("Hive");
                                    }

                                    return events;
                                  },
                                  calendarStyle: CalendarStyle(
                                    todayDecoration: BoxDecoration(
                                        color:
                                            Color(0xFFC69D43).withOpacity(0.7),
                                        shape: BoxShape.circle),
                                    selectedDecoration: BoxDecoration(
                                        color: Color(0xFFC69D43),
                                        shape: BoxShape.circle),
                                  ),
                                  calendarBuilders: CalendarBuilders(
                                      markerBuilder: (context, date, events) {
                                    ///display the marker
                                    if (events.isNotEmpty) {
                                      List<Widget> markers = [];

                                      bool hasApiary =
                                          events.contains("Apiary");
                                      bool hasHive = events.contains("Hive");

                                      if (hasApiary) {
                                        markers.add(Container(
                                          width: 6,
                                          height: 6,
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 1),
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            shape: BoxShape.circle,
                                          ),
                                        ));
                                      }

                                      if (hasHive) {
                                        markers.add(Container(
                                          width: 6,
                                          height: 6,
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 1),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                        ));
                                      }

                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: markers,
                                      );
                                    } else {
                                      return null;
                                    }
                                  }),
                                  locale: 'fr_FR',
                                  focusedDay: _focusedDay,
                                  firstDay: DateTime.utc(2000, 1, 1),
                                  lastDay: DateTime.utc(2100, 3, 14),
                                  availableGestures: AvailableGestures.all,
                                  calendarFormat: format,
                                  onFormatChanged: (CalendarFormat _format) {
                                    setState(() {
                                      format = _format;
                                    });
                                  },
                                  onDaySelected: (_selectedDay, focusedDay) {
                                    setState(() {
                                      selectedDate = focusedDay;
                                      widget.onDateSeleted(selectedDate);

                                      //Navigator.pushNamed(context, kHomeRoute);
                                    });
                                  },
                                  selectedDayPredicate: (day) {
                                    final events = widget.mySelectedEvents[
                                        DateFormat('yyyy-MM-dd').format(day)];
                                    return isSameDay(selectedDate, day);
                                  },
                                  onPageChanged: (focusedDay) {
                                    _focusedDay = focusedDay;
                                  },
                                ))),
                        SizedBox(
                          height: 20,
                        ),
                        Flexible(
                            child: Scrollbar(
                          thumbVisibility: true,
                          interactive: true,
                          controller: _controllerHive,
                          thickness: 8,
                          scrollbarOrientation: ScrollbarOrientation.left,
                          child: SingleChildScrollView(
                            controller: _controllerHive,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ///display apiary note
                                FutureBuilder<List<NoteApiary>?>(
                                    future:
                                        DatabaseHelper.getAllNotesApiariesofDay(
                                            selectedDate, widget.apiary),
                                    builder: (context,
                                        AsyncSnapshot<List<NoteApiary>?>
                                            snapshot) {
                                      String dateForm = DateFormat('yyyy-MM-dd')
                                          .format(selectedDate);

                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        return Center(
                                          child:
                                              Text(snapshot.error.toString()),
                                        );
                                      } else if (snapshot.hasData) {
                                        if (snapshot.data!.isNotEmpty) {
                                          return ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: snapshot.data!.length,
                                              itemBuilder:
                                                  (context, index) => Column(
                                                          children: [
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          50),
                                                              decoration: BoxDecoration(
                                                                  color: Color(
                                                                      0xFFFFFAEB),
                                                                  shape: BoxShape
                                                                      .rectangle,
                                                                  border: Border.all(
                                                                      width: 5,
                                                                      color: Colors
                                                                          .amber)),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    children: <
                                                                        Widget>[
                                                                      SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Container(
                                                                              height: 5,
                                                                              width: 5,
                                                                              decoration: new BoxDecoration(
                                                                                color: Colors.blue,
                                                                                shape: BoxShape.circle,
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            Text(
                                                                              "${snapshot.data![index].title}",
                                                                              style: TextStyle(fontSize: 20),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Spacer(),
                                                                      ///this button allows to edit the apiary note
                                                                      IconButton(
                                                                        onPressed:
                                                                            () async {

                                                                          final updateNote = await showDialog(
                                                                              context: context,
                                                                              builder: (BuildContext context) {
                                                                                return NoteEditorApiary(note: snapshot.data![index]);
                                                                              });
                                                                          setState(
                                                                              () {
                                                                            snapshot.data![index] =
                                                                                updateNote;
                                                                          });
                                                                        },
                                                                        icon: Icon(
                                                                            Icons.edit),
                                                                      ),
                                                                      ///this button allows to delete  the apiary note
                                                                      IconButton(
                                                                        onPressed:
                                                                            () async {
                                                                          final updateNote = await showDialog(
                                                                              context: context,
                                                                              builder: (BuildContext context) {
                                                                                return NoteDelApiary(note: snapshot.data![index]);
                                                                              });
                                                                          setState(
                                                                              () {
                                                                            snapshot.data![index] =
                                                                                updateNote;
                                                                          });
                                                                        },
                                                                        icon: Icon(
                                                                            Icons.cancel),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      Text(
                                                                          "${snapshot.data![index].description}",
                                                                          textAlign:
                                                                              TextAlign.start),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: 20,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 20,
                                                            )
                                                          ]));
                                        } else {
                                          return SizedBox();
                                        }
                                      } else {
                                        return SizedBox();
                                      }
                                    }),
                                ///this future retrieveds all the hives of an apiary and sort them according to the hive
                                /*FutureBuilder<Map<Hive, List<Note>>>(
                                    future: getHiveByApiary().then((hive) {
                                      return getNoteByHive(hive);
                                    }),
                                    builder: (context, snapshot) {
                                      String dateForm = DateFormat('yyyy-MM-dd')
                                          .format(selectedDate);

                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        return Center(
                                          child:
                                              Text(snapshot.error.toString()),
                                        );
                                      } else if (snapshot.hasData) {
                                        if(snapshot.data!.isEmpty){
                                          return SizedBox();
                                        }


                                        return Container(
                                            height: 500,
                                            child: ListView.builder(
                                                itemCount:
                                                    snapshot.data!.length,
                                                itemBuilder: (context, index){



                                                  Hive hive = snapshot
                                                      .data!.keys
                                                      .toList()[index];
                                                  Map<dynamic, dynamic>
                                                      noteruche =
                                                      snapshot.data!;
                                                  if (noteruche[hive] != null) {
                                                    DisplayHive = 1;

                                                    return Column(
                                                        children: <Widget>[
                                                          ListView.builder(
                                                              physics:
                                                                  const NeverScrollableScrollPhysics(),
                                                              shrinkWrap: true,
                                                              itemCount:
                                                                  noteruche[
                                                                          hive]
                                                                      .length,
                                                              itemBuilder: (context,
                                                                      index) =>
                                                                  Column(
                                                                      children: [
                                                                        Container(
                                                                          margin:
                                                                              EdgeInsets.symmetric(horizontal: 50),
                                                                          decoration: BoxDecoration(
                                                                              color: Color(0xFFFFFAEB),
                                                                              shape: BoxShape.rectangle,
                                                                              border: Border.all(width: 5, color: Colors.amber)),
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Row(
                                                                                children: <Widget>[
                                                                                  SizedBox(
                                                                                    width: 10,
                                                                                  ),
                                                                                  Expanded(
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Container(
                                                                                          height: 5,
                                                                                          width: 5,
                                                                                          decoration: new BoxDecoration(
                                                                                            color: Colors.red,
                                                                                            shape: BoxShape.circle,
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(
                                                                                          width: 10,
                                                                                        ),
                                                                                        ///hive name
                                                                                        Text(
                                                                                          "${hive.Name}",
                                                                                          style: TextStyle(fontSize: 20),
                                                                                        ),
                                                                                        ///title of the note
                                                                                        Text(
                                                                                          ": ${noteruche[hive][index].title}",
                                                                                          style: TextStyle(fontSize: 20),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  Spacer(),
                                                                                  ///button to edit the note
                                                                                  IconButton(
                                                                                    onPressed: () async {
                                                                                      final updateNote = await showDialog(
                                                                                          context: context,
                                                                                          builder: (BuildContext context) {
                                                                                            return NoteEditor(note: noteruche[hive][index]);
                                                                                          });
                                                                                      setState(() {
                                                                                        noteruche[hive][index] = updateNote;
                                                                                      });
                                                                                    },
                                                                                    icon: Icon(Icons.edit),
                                                                                  ),
                                                                                  ///button to delete the note
                                                                                  IconButton(
                                                                                    onPressed: () async {
                                                                                      final updateNote = await showDialog(
                                                                                          context: context,
                                                                                          builder: (BuildContext context) {
                                                                                            return NoteDel(note: noteruche[hive][index]);
                                                                                          });
                                                                                      setState(() {
                                                                                        noteruche[hive][index] = updateNote;
                                                                                      });
                                                                                    },
                                                                                    icon: Icon(Icons.cancel),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              Row(
                                                                                children: [
                                                                                  SizedBox(
                                                                                    width: 10,
                                                                                  ),
                                                                                  Text("${noteruche[hive][index].description}", textAlign: TextAlign.start),
                                                                                ],
                                                                              ),
                                                                              SizedBox(
                                                                                height: 20,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              20,
                                                                        )
                                                                      ])),
                                                        ]);
                                                  }
                                                }));

                                      } else {
                                        return SizedBox();
                                      }

                                    }
                                    ),*/
                              ],
                            ),
                          ),
                        )),
                      ],
                    )))));
  }
}
