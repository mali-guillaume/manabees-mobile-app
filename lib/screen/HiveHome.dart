/// this screen is the central menu for the hive with the the tab for the calendar , the information hive and graphic
import 'package:flutter/material.dart';


import '../models/Hive_model.dart';
import '../partials/sidebar/Sidebar.dart';
import '../routes/Routes.dart';
import 'CalendarHiveScreen.dart';
import 'HiveScreenGraphic.dart';
import 'ScreenHiveInformation.dart';

class HiveHomePage extends StatefulWidget {
  final Hive hive;
  const HiveHomePage({Key? key, required this.hive}) : super(key: key);
  @override
  _HiveHomePageState createState() => _HiveHomePageState();
}

class _HiveHomePageState extends State<HiveHomePage> {


  final List<Tab> myTabs = <Tab>[
    Tab(text: 'Information',icon: Icon(Icons.info),),
    Tab(text: 'Graphic', icon: Icon(Icons.graphic_eq),),
    Tab(text: 'Calendrar', icon: Icon(Icons.calendar_month),),
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
          centerTitle: true,
          actions: <Widget>[
            IconButton(onPressed: (){
              Navigator.pushNamed(context, kHomeConnectedRoute);
            }, icon: Icon(Icons.home)),
          ],
          title: Text(widget.hive.Name),
          titleTextStyle: TextStyle(fontFamily: 'Roboto', fontSize: 35, color: Colors.black),
          foregroundColor: Colors.black,
          backgroundColor: Color(0xFFC69D43),
          bottom: TabBar(
            tabs: myTabs,
            indicatorColor: Colors.black,
            //dividerColor: Colors.black,
            unselectedLabelColor: Colors.black,
            unselectedLabelStyle: TextStyle(fontFamily: 'Roboto', color: Color(0xFFFFFAEB)),
          ),
        ),
        body:



        TabBarView(
          children: [
            ScreenHiveInformation(
              hive: widget.hive,
            ),
            HiveScreenGraphic(hive: widget.hive),
            CalendarScreen(
              hive: widget.hive,
            ),
          ],
        ),
      ),
    );
  }
}
