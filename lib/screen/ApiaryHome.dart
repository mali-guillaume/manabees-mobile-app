
import 'package:flutter/material.dart';


import '../models/Apiary_model.dart';
import '../partials/sidebar/Sidebar.dart';
import '../routes/Routes.dart';
import 'ApiaryInformationScreen.dart';
import 'ApiaryScreenHive.dart';
import 'CalendarAparyScreen.dart';

class ApiaryHomePage extends StatefulWidget {
  final Apiary apiary;
  const ApiaryHomePage({Key? key, required this.apiary}) : super(key: key);
  @override
  _ApiaryHomePageState createState() => _ApiaryHomePageState();
}

class _ApiaryHomePageState extends State<ApiaryHomePage> {
  /// différent tb with the icon
  final List<Tab> myTabs = <Tab>[
    Tab(
      text: 'Information',
      icon: Icon(Icons.info),
    ),
    Tab(
      text: 'Hive',
      icon: Icon(Icons.hive),
    ),
    Tab(
      text: 'Calendar',
      icon: Icon(Icons.calendar_view_week_sharp),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        drawer: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.transparent,
          ),
          child: const Drawer(
            child: SidebarScreen(),
          ),
        ),
        appBar: AppBar(
          title: Text(widget.apiary.Name),
          titleTextStyle: TextStyle(
              fontFamily: 'Roboto', fontSize: 35, color: Colors.black),
          foregroundColor: Colors.black,
          backgroundColor: Color(0xFFC69D43),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, kHomeConnectedRoute);
                },
                icon: Icon(Icons.home)),
          ],
          bottom: TabBar(
            tabs: myTabs,
            indicatorColor: Colors.black,

            //dividerColor: Colors.black,
            unselectedLabelColor: Colors.black,
            unselectedLabelStyle:
                TextStyle(fontFamily: 'Roboto', color: Color(0xFFFFFAEB)),
          ),
        ),
        ///redirection between the list of hives and the map and apiary information
        body: TabBarView(
          children: [
            ScreenApiaryInformation(apiary: widget.apiary),
            ApiaryRucheScreen(apiary: widget.apiary),
            CalendarApiaryScreen(apiary: widget.apiary),
          ],
        ),
      ),
    );
  }
}
