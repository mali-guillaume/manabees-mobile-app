///this screen contain the calendar + the list of notes of the day
///(this widget also allows to edit and delete note )

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/Apiary_model.dart';
import '../../models/Note_model.dart';
import '../../routes/Routes.dart';
import '../../services/Database_helper.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/NoteApiary_model.dart';
import '../../models/Hive_model.dart';
import '../PopUp/NoteDelApiary.dart';
import '../PopUp/NoteDelHive.dart';
import '../PopUp/NoteEditorApiary.dart';
import '../PopUp/NoteEditorHive.dart';
import '../../screen/CalendarHiveScreen.dart';

class CalendarHiveWidget extends StatefulWidget {
  final Hive hive;
  final Function(DateTime) onDateSeleted;
  Future<List<Note>?> futureNote;
  Map<String, List<dynamic>> mySelectedEvents = {};
  final Map<DateTime, List<dynamic>> eventsHive;
  CalendarHiveWidget({
    Key? key,
    required this.hive,
    required this.onDateSeleted,
    required this.futureNote,
    required this.mySelectedEvents,
    required this.eventsHive,
  }) : super(key: key);

  @override
  State<CalendarHiveWidget> createState() => _CalendarHiveWidgetState();
}

class _CalendarHiveWidgetState extends State<CalendarHiveWidget> {
  DateTime _focusedDay = DateTime.now();
  CalendarFormat format = CalendarFormat.month;
  var selectedDate;
  late DateTime date;
  var EventDay;
  Map<DateTime, List<dynamic>> _eventsApiary = {};
  final ScrollController _controllerNoteApiary = ScrollController();
  final ScrollController _controllerHive = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedDate = _focusedDay;
    _loadEventsApiary();
  }

  ///retrieve all apiary notes from an apiary
  Future<void> _loadEventsApiary() async {
    List<Apiary>? apiary =
        await DatabaseHelper.getApiaryByID(widget.hive.idApiary);

    for (int i = 0; i < apiary!.length; i++) {
      final eventsApiary = await DatabaseHelper.getAllNotesApiary(apiary[i]);
      setState(() {
        _eventsApiary = {};
        if (eventsApiary != null) {
          for (final event in eventsApiary) {
            print("load event Apiary");
            final date = event.date;
            final key = DateFormat('yyyy-MM-dd').parse(date);
            if (_eventsApiary[key] == null) {
              _eventsApiary[key] = [event];
            } else {
              _eventsApiary[key]!.add(event);
            }
          }
        }
      });
    }
  }

  Future<List<NoteApiary>?> getAllNoteApiary() async {
    List<Apiary>? apiary =
        await DatabaseHelper.getApiaryByID(widget.hive.idApiary);
    return DatabaseHelper.getAllNotesApiariesofDay(selectedDate, apiary![0]);
  }

  ///
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
    double heightscreen = MediaQuery.of(context).size.height;

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
                    height: heightscreen,
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                            height: getHeight(format),
                            child: TableCalendar(
                              shouldFillViewport: true,
                              eventLoader: (date) {
                                ///retrieve all event
                                final key =
                                    DateTime(date.year, date.month, date.day);
                                List<dynamic> events = [];
                                if (_eventsApiary[key] != null) {
                                  events.add("Apiary");
                                }
                                if (widget.eventsHive[key] != null) {
                                  events.add("Hive");
                                }
                                return events;
                              },
                              calendarStyle: CalendarStyle(
                                todayDecoration: BoxDecoration(
                                    color: Color(0xFFC69D43).withOpacity(0.7),
                                    shape: BoxShape.circle),
                                selectedDecoration: BoxDecoration(
                                    color: Color(0xFFC69D43),
                                    shape: BoxShape.circle),
                              ),
                              calendarBuilders: CalendarBuilders(
                                  markerBuilder: (context, date, events) {
                                if (events.isNotEmpty) {
                                  List<Widget> markers = [];

                                  bool hasApiary = events.contains("Apiary");
                                  bool hasHive = events.contains("Hive");

                                  if (hasApiary) {
                                    print("has Apiary");
                                    markers.add(Container(
                                      width: 6,
                                      height: 6,
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 1),
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
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 1),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ));
                                  }

                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                            )),
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
                                ///this future allows to show notes and to edit and delete note.
                                FutureBuilder<List<Note>?>(
                                    future: widget.futureNote,
                                    builder: (context,
                                        AsyncSnapshot<List<Note>?> snapshot) {
                                      String dateForm = DateFormat('yyyy-MM-dd')
                                          .format(selectedDate);
                                      print('date $dateForm');
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
                                                                      color: Color(
                                                                          0xFFC69D43))),
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
                                                                                color: Colors.red,
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

                                                                      /// this button to edit the note
                                                                      IconButton(
                                                                        onPressed:
                                                                            () async {
                                                                          final updateNote = await showDialog(
                                                                              context: context,
                                                                              builder: (BuildContext context) {
                                                                                return NoteEditor(note: snapshot.data![index]);
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

                                                                      /// this button to delete the note
                                                                      IconButton(
                                                                        onPressed:
                                                                            () async {
                                                                          final updateNote = await showDialog(
                                                                              context: context,
                                                                              builder: (BuildContext context) {
                                                                                return NoteDel(note: snapshot.data![index]);
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

                                /// retrieves all the note from an apiary
                                FutureBuilder<List<NoteApiary>?>(
                                    future: getAllNoteApiary(),
                                    builder: (context,
                                        AsyncSnapshot<List<NoteApiary>?>
                                            snapshot) {
                                      String dateForm = DateFormat('yyyy-MM-dd')
                                          .format(selectedDate);
                                      print('date $dateForm');
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

                                                                      /// button to edit note from apiary
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

                                                                        /// button to delete the note from apiary
                                                                        icon: Icon(
                                                                            Icons.edit),
                                                                      ),
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
                              ],
                            ),
                          ),
                        )),
                      ],
                    )))));
  }
}
