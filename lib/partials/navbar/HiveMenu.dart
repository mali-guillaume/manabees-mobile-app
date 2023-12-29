/// this widget show the user's number hive

import 'package:flutter/material.dart';


import '../../main.dart';
import '../../models/Hive_model.dart';
import '../../routes/Routes.dart';
import '../../screen/HomeConnected.dart';
import '../../services/ApiService.dart';
import '../../style/Constants.dart';

@immutable
class HiveMenu extends StatefulWidget {
  const HiveMenu({Key? key}) : super(key: key);

  @override
  _HiveMenuState createState() => _HiveMenuState();
}

class _HiveMenuState extends State<HiveMenu> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, kRucheRoute);
        Scaffold.of(context).openDrawer();
      },
      child: Container(

          width: largeurEcran / 6,
          height: hauteurEcran / 3,
          decoration: BoxDecoration(
            color: Color(0xFFC69D43),
            borderRadius: kBorderRadiusItem,
            boxShadow: kBoxShadowItem,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.hive,
                size: hauteurEcran/18,),
              Text(
                "Ruches",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: largeurEcran / 15),
              ),
              /*Text(
                "5",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.grey[700], fontSize: largeurEcran / 15),
              ),*/
              FutureBuilder<List<Hive>?>(
                    future: getHiveFromSQLiteorApi("", user.toString()),
                    builder: (context, snapshot) {

                      if (snapshot.hasData) {

                        return Text(snapshot.data!.length.toString(), style: TextStyle(
                            fontSize: largeurEcran / 15), );




                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                      }

                      // By default, show a loading spinner.
                      return CircularProgressIndicator();
                    },
                  )



            ],
          )),
    );
  }
}
