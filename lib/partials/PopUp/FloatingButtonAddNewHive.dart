///this modal screen allows to add a hive and see the bluetooth device

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:get/get_state_manager/src/simple/get_state.dart';



import '../../main.dart';
import '../../models/Apiary_model.dart';
import '../../models/Hive_model.dart';
import '../../routes/Routes.dart';

class FloatingButtonAddNewHive extends StatefulWidget {
  const FloatingButtonAddNewHive();

  @override
  _FloatingButtonAddNewHiveState createState() =>
      _FloatingButtonAddNewHiveState();
}

class _FloatingButtonAddNewHiveState extends State<FloatingButtonAddNewHive> {
  final _NameController = TextEditingController();
  final _LocalityController = TextEditingController();
  DateTime DeployementDate = DateTime.now();
  final ScrollController _controllerBluetooth = ScrollController();

  late Future<List<Apiary>?> _futureApiaries;
  late Apiary apiary;

  @override
  void initState() {
    super.initState();
    _futureApiaries = getApiaryFromSQLiteorApi("", user.toString());
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
        backgroundColor:const Color(0xFFC69D43),
        onPressed: () => _ShowAddEventDialog(context),
        label: const Text('Add the new hive'));
  }

  _ShowAddEventDialog(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (context) => Container(
            width: 300,
            height: 400,
            child: AlertDialog(
              title:const Text('Add new hive'),
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
                          controller: _NameController,
                          decoration:  const InputDecoration(
                              labelText: 'Name',
                              helperText: 'Add the hive name',
                              focusColor: Color(0xFFC69D43),
                              labelStyle: TextStyle(color: Colors.black),
                              iconColor: Colors.black,
                              enabledBorder:  OutlineInputBorder(
                                  borderSide:
                                       BorderSide(color: Color(0xFFC69D43)),
                                  borderRadius:  BorderRadius.all(
                                      Radius.circular(20.0))),
                              focusedBorder:  OutlineInputBorder(
                                  borderSide:
                                       BorderSide(color: Colors.black),
                                  borderRadius:  BorderRadius.all(
                                      Radius.circular(20.0)))),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextField(
                            keyboardType: TextInputType.multiline,
                            minLines: 1,
                            maxLines: 1,
                            controller: _LocalityController,
                            decoration: const InputDecoration(
                                labelText: 'Locality',
                                focusColor: Color(0xFFC69D43),
                                labelStyle: TextStyle(color: Colors.black),
                                enabledBorder:  OutlineInputBorder(
                                    borderSide:  BorderSide(
                                        color: Color(0xFFC69D43)),
                                    borderRadius:  BorderRadius.all(
                                        Radius.circular(20.0))),
                                focusedBorder:  OutlineInputBorder(
                                    borderSide:
                                         BorderSide(color: Colors.black),
                                    borderRadius:  BorderRadius.all(
                                        Radius.circular(20.0))))),
                        const SizedBox(
                          height: 20,
                        ),
                            SizedBox(
                              height:300,
                              child:
                        FutureBuilder<List<Apiary>?>(
                          future: _futureApiaries,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25.0),
                                    color: Colors.grey),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(25.0),
                                  child: DropdownButtonFormField(
                                      isExpanded: true,
                                      value:
                                          apiary == null ? null : apiary.Name,
                                      decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 20),
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none),
                                      items:
                                          snapshot.data!.map((Apiary option) {
                                        return DropdownMenuItem(
                                          value: option,
                                          child: Text(option.Name),
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
                                        setState(() {
                                          apiary = value! as Apiary;
                                        });
                                      }),
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Text("Not Apiary");
                            }

                            // By default, show a loading spinner.
                            return CircularProgressIndicator();
                          },
                        )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                    onPressed: () async {
                                      Navigator.pushNamed(context, kAddBluetoothHive);
                                    },
                                    child: Text("Scan ")),
                               const SizedBox(
                                  width: 20,
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    )),
                  ],
                ),
              )),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    print("new hive ${Hive(Name: _NameController.text, localisation: _LocalityController.text, deployment: DeployementDate.toIso8601String(), idProprietaire: user, idApiary: apiary.idApiary as int)}");
                    Navigator.pop(
                      context,
                    );
                  },
                  child: Text('add the new hive'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
              ],
            )));
  }
}
