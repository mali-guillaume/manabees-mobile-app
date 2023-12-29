///the screen shows all apiaries and allows to search an apiary
import 'package:flutter/material.dart';
import 'package:nom_du_projet/services/Database_helper.dart';

import '../main.dart';
import '../models/Apiary_model.dart';
import '../models/Hive_model.dart';
import '../partials/form/Search_input.dart';
import 'dart:async';

import '../services/ApiService.dart';
import '../style/Constants.dart';
import 'ApiaryHome.dart';

class ApiariesScreen extends StatefulWidget {
  const ApiariesScreen({Key? key}) : super(key: key);

  @override
  State<ApiariesScreen> createState() => _ApiariesScreenState();
}

class _ApiariesScreenState extends State<ApiariesScreen> {
  String apiary = "";
  late Future<List<Apiary>?> _futureApiaries;

  @override
  void initState() {
    super.initState();
    _futureApiaries =
        getApiaryFromSQLiteorApi("", user.toString());
  }



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
                      apiary = value;
                      _futureApiaries = getApiaryFromSQLiteorApi(apiary, user.toString());
                    });
                  },
                  hintext: 'search a apiary with name',
                ),
              ],
            ),
            Expanded(
                child: FutureBuilder<List<Apiary>?>(
              future: _futureApiaries,
              builder: (context, snapshot) {

                if (snapshot.hasData) {
                  return GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 5.0/1.0,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      children :List.generate (snapshot.data!.length,(index) {
                      return Container(
                        height: MediaQuery.of(context).size.height *
                            0.2, // hauteur de 40% de la hauteur de l'écran
                        child: FractionallySizedBox(
                          widthFactor:
                              0.8, // occupe 80% de la largeur disponible
                          heightFactor:
                              0.9, // occupe 80% de la hauteur disponible
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ApiaryHomePage(
                                            apiary: snapshot.data![index],
                                          )));
                            },
                            child:  Container(
                                color: const Color(0xFFC69D43),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      const Icon(Icons.hive),
                                      Text(snapshot.data![index].Name),
                                      FutureBuilder<List<Hive>?>(
                                        future: DatabaseHelper.getHiveSearchByApiary("",snapshot.data![index] ),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return Text(" : ${snapshot.data!.length
                                                .toString()} hive(s)");
                                          } else if (snapshot.hasError) {
                                            return const Text(": 0 hive");
                                          }

                                          // By default, show a loading spinner.
                                          return const Text("0");
                                        },
                                      )
                                    ],
                                  ),
                                )),
                          ),
                        ),
                      );
                    },
                  ));
                } else if (snapshot.hasError) {
                  return Text("Not Apiary");
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
