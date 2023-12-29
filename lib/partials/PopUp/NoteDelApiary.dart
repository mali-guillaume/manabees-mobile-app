/// modal page allows you to delete a note from an apiary


import 'package:flutter/material.dart';

import '../../models/NoteApiary_model.dart';
import '../../services/Database_helper.dart';




class NoteDelApiary extends StatefulWidget {
  final NoteApiary note;

  const NoteDelApiary({required this.note});

  @override
  _NoteDelApiaryState createState() => _NoteDelApiaryState();
}

class _NoteDelApiaryState extends State<NoteDelApiary> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.note.title;
    _descriptionController.text = widget.note.description;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete the note'),
      content: SingleChildScrollView(
          child: Container(
            width: 500,
            height: 250,
            child: Column(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      TextField(
                        readOnly: true,
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 1,
                        controller: _titleController,
                        decoration: new InputDecoration(
                            labelText: 'Title',
                            focusColor:  Color(0xFFC69D43),
                            labelStyle: TextStyle(color: Colors.black,fontSize: 22),
                            iconColor: Colors.black,

                            enabledBorder: new OutlineInputBorder(
                                borderSide: new BorderSide(color: Color(0xFFC69D43)),
                                borderRadius:
                                new BorderRadius.all(Radius.circular(20.0))),
                            focusedBorder: new OutlineInputBorder(
                                borderSide: new BorderSide(color: Colors.black),
                                borderRadius:
                                new BorderRadius.all(Radius.circular(20.0)))),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextField(
                          readOnly: true,
                          keyboardType: TextInputType.multiline,
                          minLines: 3,
                          maxLines: 3,
                          controller: _descriptionController,
                          decoration: new InputDecoration(
                              labelText: 'Description',
                              focusColor:  Color(0xFFC69D43),
                              labelStyle: TextStyle(color: Colors.black),
                              enabledBorder: new OutlineInputBorder(
                                  borderSide: new BorderSide(color: Color(0xFFC69D43)),
                                  borderRadius:
                                  new BorderRadius.all(Radius.circular(20.0))),
                              focusedBorder: new OutlineInputBorder(
                                  borderSide: new BorderSide(color: Colors.black),
                                  borderRadius: new BorderRadius.all(
                                      Radius.circular(20.0))))),
                    ],
                  ),
                ),
              ],
            ),
          )),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            ///delete the note
            DatabaseHelper.deleteNoteApiary(widget.note);
            Navigator.pop(context);
          },
          child: Text('Delete'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }
}