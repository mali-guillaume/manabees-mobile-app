/// this screen allows you to display note from a hive in a calendar and add note

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';



import '../models/Note_model.dart';
import '../models/Hive_model.dart';
import '../partials/PopUp/NoteAddHive.dart';
import '../partials/calendar/CalendarHiveWidget.dart';
import '../services/Database_helper.dart';

class CalendarScreen extends StatefulWidget {
  /// param [Hive]
  final Hive hive;

  ///create widget fro the button to add [Note] + a calendar to see the [Note]
  const CalendarScreen({
    Key? key,
    required this.hive,
  }) : super(key: key);

  ///[_CalendarScreenState] pour visualiser l
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

/// the State class for the [CalendarScreen] widget
class _CalendarScreenState extends State<CalendarScreen> {
  var selectedDate = DateTime.now();
  Map<String, List<dynamic>> mySelectedEvents = {};
  late Future<List<Note>?> futureNote;
  Map<DateTime, List<dynamic>> eventsHive = {};

  @override
  void initState() {
    // TODO: implement initState

    super.initState();

    futureNote = DatabaseHelper.getAllNotesofDay(selectedDate, widget.hive);
    _loadEventsHive();
    print("selected date ${selectedDate}");
  }

  ///add item to list eventsHive to display a marker on the calendar
  Future<void> _loadEventsHive() async {
    final events = await DatabaseHelper.getAllNotes(widget.hive);
    setState(() {
      eventsHive = {};
      if (events != null) {
        for (final event in events) {
          print("load event hive");
          final date = event.date;
          final key = DateFormat('yyyy-MM-dd').parse(date);
          if (eventsHive[key] == null) {
            eventsHive[key] = [event];
          } else {
            eventsHive[key]!.add(event);
          }
        }
      }
    });
  }

  ///this Screen contains the button to add Notes + a calendar to see the note
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFAEB),
      body: CalendarHiveWidget(
        hive: widget.hive,
        futureNote: futureNote,
        onDateSeleted: (newDate) {
          setState(() {
            selectedDate = newDate;
            print("nouvelle date $selectedDate");
            futureNote =
                DatabaseHelper.getAllNotesofDay(selectedDate, widget.hive);
          });
        },
        mySelectedEvents: mySelectedEvents,
        eventsHive: eventsHive,
      ),
      floatingActionButton: NoteAddHive(
          hive: widget.hive,
          selectedDate: selectedDate,
          onFutureNoteChange: (newFutureNote) {
            setState(() {
              futureNote = newFutureNote;
              _loadEventsHive();
            });
          }),
    );
  }
}
