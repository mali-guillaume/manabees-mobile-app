/// this screen allows you to display noteApiary in a calendar and add notesApiary

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';


import '../models/Apiary_model.dart';
import '../models/NoteApiary_model.dart';
import '../models/User_model.dart';
import '../models/Note_model.dart';
import '../models/Hive_model.dart';
import '../partials/calendar/CalendarApiaryWidget.dart';
import '../services/Database_helper.dart';
import '../partials/PopUp/NoteAddApiary.dart';

class CalendarApiaryScreen extends StatefulWidget {
  /// param [Apiary]
  final Apiary apiary;

  ///create widget for the button to add [NoteApiary] + a calendar to see the [NoteApiary]
  const CalendarApiaryScreen({
    Key? key,
    required this.apiary,
  }) : super(key: key);

  @override
  State<CalendarApiaryScreen> createState() => _CalendarApiaryScreenState();
}


class _CalendarApiaryScreenState extends State<CalendarApiaryScreen> {
  Map<DateTime, List<dynamic>> eventsApiary = {};
  var selectedDate = DateTime.now();
  Map<String, List<dynamic>> mySelectedEvents = {};
  late Future<List<NoteApiary>?> futureNote;



  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    futureNote =   DatabaseHelper.getAllNotesApiariesofDay(selectedDate, widget.apiary);
    _loadEventsApiary();
  }

  ///add item to list eventsApiary to display a marker on the calendar
  Future<void> _loadEventsApiary() async {
    final events = await DatabaseHelper.getAllNotesApiary(widget.apiary);
    setState(() {
      eventsApiary = {};
      if (events != null) {
        print("event Apiary");
        for (final event in events) {
          final date = event.date;
          final key = DateFormat('yyyy-MM-dd').parse(date);
          if (eventsApiary[key] == null) {
            eventsApiary[key] = [event];
          } else {
            eventsApiary[key]!.add(event);
          }
        }
      }
    });
  }

  ///this Screen contains the button to add Notes + a calendar to see the note
  /// param [Buildcontext] context :  it's a description of the widget position in the widget tree
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// CalendarApiaryWidget aloows you to display the notes in the calendar
      body: CalendarApiaryWidget(
        futureNoteApiary: futureNote,
        apiary: widget.apiary,onDateSeleted: (newDate){setState(() {
        selectedDate = newDate;
        futureNote =   DatabaseHelper.getAllNotesApiariesofDay(selectedDate, widget.apiary);
      });}, mySelectedEvents: mySelectedEvents, eventsApiary: eventsApiary,),


      ///floatingButton allows you to add a note
      floatingActionButton: NoteAddApiaryWidget(
        apiary: widget.apiary, selectedDate: selectedDate, onFutureNoteChange: (newFutureNote){setState(() {
        futureNote = newFutureNote;
        _loadEventsApiary();
      });}),
    );
  }
}


//Map<String, List> mySelectedEvent = {};
//Map<String, String> mySelectedEventsPuce = {};
