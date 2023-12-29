///this is a menu that allows when you click to display a menu to add
/// NoteApiary to the database

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/NoteApiary_model.dart';

import '../../services/Database_helper.dart';


import '../../models/Apiary_model.dart';
import '../../models/Note_model.dart';


///this is a menu that allows when you click to display a menu to add
/// informaton to the database
///
///
/// return [FloatingActionButton] that allows when you click to display a menu to add
/// informaton to the database
class NoteAddApiaryWidget extends StatefulWidget {
  final NoteApiary? noteApiary;
  final Apiary apiary;
  var selectedDate;
  ///function to update the NoteApiary in the calendar
  final Function(Future<List<NoteApiary>?>) onFutureNoteChange;
  Map<String, List<dynamic>> mySelectedEvents = {};
  NoteAddApiaryWidget({Key? key, this.noteApiary, required this.apiary, required this.selectedDate, required this.onFutureNoteChange,})
      : super(key: key);

  @override
  State<NoteAddApiaryWidget> createState() => _NoteAddApiaryWidgetState();
}

class _NoteAddApiaryWidgetState extends State<NoteAddApiaryWidget> {




  ///titleController = title of [Note]
  final titleController = TextEditingController();

  ///[descpController] = description of the [Note]
  final descpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (widget.noteApiary != null) {
      titleController.text = widget.noteApiary!.title;
      descpController.text = widget.noteApiary!.description;
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

                      final NoteApiary model = NoteApiary(
                          title: title,
                          description: description,
                          date:
                          DateFormat('yyyy-MM-dd').format(widget.selectedDate),
                          idApiary: widget.apiary.idApiary);
                      //print('date $selectedDate');
                      if (widget.noteApiary == null) {
                        await DatabaseHelper.addNoteApiary(model);
                        setState(() async {
                          final note =  DatabaseHelper.getAllNotesApiariesofDay(widget.selectedDate, widget.apiary);


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