/// this widget allows you to create a sidebar menu to disconnect, to return to dashboard
/// or return to the hives menu or return to the Apiaries menu

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../../routes/Routes.dart';
import '../../style/Constants.dart';


class SidebarScreen extends StatefulWidget {
  const SidebarScreen({Key? key}) : super(key: key);

  @override
  _SidebarScreenState createState() => _SidebarScreenState();
}


class _SidebarScreenState extends State<SidebarScreen> {

  Future<void> BackupUser() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'token', "");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFAEB),
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(34)),
      ),
      width: MediaQuery.of(context).size.width * 0.7,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 10),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, kHomeConnectedRoute);
                },
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.dashboard,
                      color: Colors.black,
                    ),
                    Spacer(),
                    Text("Dashboard",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: Colors.black)),
                  ],
                ),
              ),
              Divider(thickness: 5,color: Colors.grey,),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, kRucherRoute);
                },
                child: Row(children: <Widget>[
                  Icon(Icons.location_on_outlined,color: Colors.black,
                    ),
                  Text(
                    "Apiaries",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Colors.black),
                  )
                ]),
              ),
              Divider(thickness: 5,color: Colors.grey,),
              TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, kRucheRoute);
                  },
                  child:Row(children: <Widget>[
                    Icon(Icons.hive,color: Colors.black,
                  ),
                  Text(
                    "Hives",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Colors.black),
                  )])),
              const Spacer(),
              Row(
                children: [
                  const Icon(
                    Icons.logout,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 5),
                  TextButton(
                    onPressed: () {
                      BackupUser();
                      Navigator.pushNamed(context, kHomeNotConnectedRoute);
                    },
                    child: const Text(
                      "Disconnect!",
                      style: fontStyleLegend,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
