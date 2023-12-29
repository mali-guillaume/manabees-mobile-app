///the screan shows all hive of the apiary and allows search a hive
import 'package:flutter/material.dart';


import '../main.dart';
import '../models/Apiary_model.dart';
import '../models/Hive_model.dart';
import '../partials/form/Search_input.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import '../services/Database_helper.dart';
import '../style/Constants.dart';
import 'HiveHome.dart';

class ApiaryRucheScreen extends StatefulWidget {
  final Apiary apiary;
  const ApiaryRucheScreen({Key? key, required this.apiary}) : super(key: key);

  @override
  State<ApiaryRucheScreen> createState() => _ApiaryRucheScreenState();
}

class _ApiaryRucheScreenState extends State<ApiaryRucheScreen> {
  String hive = "";
  late Future<List<Hive>?> _futureHives;



  ///collect all the hives from apiaries when the page is launched
  @override
  void initState() {
    super.initState();
    _futureHives = DatabaseHelper.getHiveSearchByApiary("", widget.apiary);
  }


  ///the scree/////////n shows all hive of the apiary and allows search a hive
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      hive = value;

                      _futureHives = DatabaseHelper.getHiveSearchByApiary(
                          hive, widget.apiary);
                    });
                  },
                  hintext: 'search a hive with the name',
                ),
              ],
            ),
            Expanded(
                child: FutureBuilder<List<Hive>?>(
              future: _futureHives,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 5.0 / 1.0,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      children: List.generate(snapshot.data!.length, (index) {
                        return Container(
                          height: MediaQuery.of(context).size.height *
                              0.2, // hauteur de 40% de la hauteur de l'écran
                          child: FractionallySizedBox(
                            widthFactor: 0.8,
                            heightFactor: 0.9,
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
                                        Text(snapshot.data![index].Name),
                                      ],
                                    ),
                                  )),
                            ),
                          ),
                        );
                      }));
                } else if (snapshot.hasError) {
                  return Text("Not hive");
                }

                // By default, show a loading spinner.
                return CircularProgressIndicator();
              },
            ))
          ],
        ),
      ),
    );
  }
}
