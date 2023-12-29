/// this widget shows the user's numbervb ((§(§(ytgf vg Apiary

import 'package:flutter/material.dart';


import '../../main.dart';
import '../../models/Apiary_model.dart';
import '../../routes/Routes.dart';
import '../../screen/HomeConnected.dart';
import '../../style/Constants.dart';

@immutable
class ApiaryMenu extends StatefulWidget {
  const ApiaryMenu({Key? key}) : super(key: key);

  @override
  _ApiaryMenuState createState() => _ApiaryMenuState();
}

class _ApiaryMenuState extends State<ApiaryMenu> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, kRucherRoute);
      },
      child: Container(
          width: largeurEcran / 3,
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
              Icon(
                Icons.location_on_outlined,
                size: hauteurEcran / 18,
              ),
              Text(
                "Ruchers",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: largeurEcran / 15),
              ),
              FutureBuilder<List<Apiary>?>(
                future: getApiaryFromSQLiteorApi("", user.toString()),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      snapshot.data!.length.toString(),
                      style: TextStyle(fontSize: largeurEcran / 15),
                    );
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
