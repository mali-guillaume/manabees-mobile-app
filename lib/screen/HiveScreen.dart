///this screen allows you to view all hives
import 'package:flutter/material.dart';


import '../main.dart';
import '../models/Hive_model.dart';
import '../partials/PopUp/FloatingButtonAddNewHive.dart';
import '../partials/form/Search_input.dart';
import 'dart:async';

import '../partials/sidebar/Sidebar.dart';
import '../routes/Routes.dart';
import '../style/Constants.dart';
import 'HiveHome.dart';

class RucheScreen extends StatefulWidget {
  const RucheScreen({Key? key}) : super(key: key);

  @override
  State<RucheScreen> createState() => _RucheScreenState();
}

class _RucheScreenState extends State<RucheScreen> {
  String ruche = "";
  late Future<List<Hive>?> _futureRuches;

  @override
  void initState() {
    super.initState();
    _futureRuches = getHiveFromSQLiteorApi("", user.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFAEB),
      drawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.transparent,
        ),
        child: const Drawer(
          child: SidebarScreen(),
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, kHomeConnectedRoute);
              },
              icon: Icon(Icons.home)),
        ],
        title: Text(
          "Hive",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color(0xFFC69D43),
        foregroundColor: Colors.black,
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                const SizedBox(
                  height: kVerticalSpacer * 2,
                ),
                SearchInput(
                  onChanged: (value) {
                    setState(() {
                      ruche = value;
                      _futureRuches =
                          getHiveFromSQLiteorApi(ruche, user.toString());
                    });
                  },
                  hintext: 'search hive with name',
                ),
              ],
            ),
            Expanded(
                child: FutureBuilder<List<Hive>?>(
              future: _futureRuches,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 5.0 / 1.0,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      children: List.generate(
                        snapshot.data!.length,
                        (index) {
                          return Container(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HiveHomePage(
                                              hive: snapshot.data![index],
                                            )));
                              },
                              child: new Container(
                                  color: Color(0xFFC69D43),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(Icons.hive),
                                        SizedBox(
                                          width: 20.0,
                                        ),
                                        Text(snapshot.data![index].Name),
                                      ],
                                    ),
                                  )),
                            ),
                          );
                        },
                      ));
                } else if (snapshot.hasError) {
                  return Text("we haven't hive");
                }

                // By default, show a loading spinner.
                return CircularProgressIndicator();
              },
            ))
          ],
        ),
      ),
      floatingActionButton: FloatingButtonAddNewHive(),
    );
  }
}
