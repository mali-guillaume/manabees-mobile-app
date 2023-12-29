/// modal page allows you to edit a note from an apiary
import 'package:flutter/material.dart';

import '../../models/NoteApiary_model.dart';
import '../../services/Database_helper.dart';

class NoteEditorApiary extends StatefulWidget {
  final NoteApiary note;

  const NoteEditorApiary({required this.note});

  @override
  _NoteEditorApiaryState createState() => _NoteEditorApiaryState();
}

class _NoteEditorApiaryState extends State<NoteEditorApiary> {
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
      title: Text('Edit note'),
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
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 1,
                    controller: _titleController,
                    decoration: new InputDecoration(
                        labelText: 'Title',
                        focusColor: Color(0xFFC69D43),
                        labelStyle:
                            TextStyle(color: Colors.black, fontSize: 22),
                        iconColor: Colors.black,
                        enabledBorder: new OutlineInputBorder(
                            borderSide:
                                new BorderSide(color: Color(0xFFC69D43)),
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
                      keyboardType: TextInputType.multiline,
                      minLines: 3,
                      maxLines: 3,
                      controller: _descriptionController,
                      decoration: new InputDecoration(
                          labelText: 'Description',
                          focusColor: Color(0xFFC69D43),
                          labelStyle: TextStyle(color: Colors.black),
                          enabledBorder: new OutlineInputBorder(
                              borderSide:
                                  new BorderSide(color: Color(0xFFC69D43)),
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
        ElevatedButton(
          onPressed: () {
            print(_titleController.text);
            print(_descriptionController.text);
            DatabaseHelper.updateNoteApiary(
              NoteApiary(
                id: widget.note.id,
                title: _titleController.text,
                description: _descriptionController.text,
                date: widget.note.date,
                idApiary: widget.note.idApiary,
              ),
            );

            Navigator.pop(
              context,
              NoteApiary(
                title: _titleController.text,
                description: _descriptionController.text,
                date: widget.note.date,
                idApiary: widget.note.idApiary,
              ),
            );
          },
          child: Text('Register'),
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
