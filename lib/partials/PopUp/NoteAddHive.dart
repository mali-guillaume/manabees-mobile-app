///this is a menu that allows when you click to display a menu to add a note

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/Database_helper.dart';
import 'package:path/path.dart';

import '../../models/Note_model.dart';
import '../../models/Hive_model.dart';
import '../../screen/CalendarHiveScreen.dart';

///this is a menu that allows when you click to display a menu to add
/// informaton to the database
///
///param [hive] and [Note]
///
/// return [FloatingActionButton] that allows when you click to display a menu to add
/// informaton to the database
class NoteAddHive extends StatefulWidget {
  final Hive hive;
  final Note? note;
  var selectedDate;
  final Function(Future<List<Note>?>) onFutureNoteChange;
  Map<String, List<dynamic>> mySelectedEvents = {};

  NoteAddHive({Key? key, this.note, required this.hive, required this.selectedDate, required this.onFutureNoteChange,})
      : super(key: key);

  @override
  State<NoteAddHive> createState() => _NoteAddHiveState();
}


class _NoteAddHiveState extends State<NoteAddHive> {
  ///titleController = title of [Note]
  final titleController = TextEditingController();
  //final List<Note> listNote;

  ///[descpController] = description of the [Note]
  final descpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (widget.note != null) {
      titleController.text = widget.note!.title;
      descpController.text = widget.note!.description;
    }
    return FloatingActionButton.extended(
        backgroundColor: Color(0xFFC69D43),
        onPressed: () => _ShowAddEventDialog(context),
        label: const Text('Add Event'));
  }

  /// method allow to show the menu with 2 TextField (titleController / descpController)
  /// and 2 button ( Cancel and Add the [Note] at the database
  ///
  /// return AlertDialog
  ///
  /// param
  _ShowAddEventDialog(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (context) => Container(
              width: 300,
              height: 400,
              child: AlertDialog(
                title: const Text('Add New event'),
                content: Container(
                  width: 300,
                  height: 200,
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            TextField(
                              controller: titleController,
                              decoration:
                                  const InputDecoration(labelText: 'Title'),
                            ),
                            TextField(
                              controller: descpController,
                              decoration: const InputDecoration(
                                  labelText: 'Description'),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('cancel')),
                  TextButton(
                      onPressed: () async {

                        final title = titleController.text;
                        final description = descpController.text;
                        if (titleController.text.isEmpty &&
                            descpController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Required title and description'),
                            duration: Duration(seconds: 2),
                          ));
                          return;
                        } else {
                          print(titleController.text);
                          print(descpController.text);

                          final Note model = Note(
                              title: title,
                              description: description,
                              date:
                                  DateFormat('yyyy-MM-dd').format(widget.selectedDate),
                              hiveid: widget.hive.hiveid);
                          print('date ${widget.selectedDate}');
                          if (widget.note == null) {


                            await DatabaseHelper.addNote(model);
                            /// update note
                            setState(() async {
                              final note =  DatabaseHelper.getAllNotesofDay(widget.selectedDate, widget.hive);
                              widget.onFutureNoteChange(note);
                              Navigator.pop(context);

                            });



                          }

                          titleController.clear();
                          descpController.clear();
                          Navigator.pop(context);

                          return;
                        }

                      },
                      child: const Text('ADD')),
                  SizedBox(
                    width: 20,
                  ),
                ],
              ),
            ));
  }
}
