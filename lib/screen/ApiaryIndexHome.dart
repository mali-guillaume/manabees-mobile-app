///this widget allows to navigate between the list of hive and map of apiary

import 'package:flutter/material.dart';





import '../partials/sidebar/Sidebar.dart';
import '../routes/Routes.dart';
import 'ApiariesMap.dart';
import 'ApiariesScreen.dart';

class ApiaryIndexPage extends StatefulWidget {
  const ApiaryIndexPage({
    Key? key,
  }) : super(key: key);
  @override
  _ApiaryIndexPageState createState() => _ApiaryIndexPageState();
}

class _ApiaryIndexPageState extends State<ApiaryIndexPage> {
  /// different tab with the icon
  final List<Tab> myTabs = <Tab>[
    Tab(
      text: 'Apiaries',
      icon: Icon(Icons.info),
    ),
    Tab(
      text: 'Map',
      icon: Icon(Icons.hive),
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
          centerTitle: true,
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, kHomeConnectedRoute);
                },
                icon: Icon(Icons.home)),
          ],
          title: Text("Apiaries"),
          titleTextStyle: TextStyle(
              fontFamily: 'Roboto', fontSize: 35, color: Colors.black),
          foregroundColor: Colors.black,
          backgroundColor: Color(0xFFC69D43),
          bottom: TabBar(
            tabs: myTabs,
            indicatorColor: Colors.black,
            //dividerColor: Colors.black,
            unselectedLabelColor: Colors.black,
            unselectedLabelStyle:
                TextStyle(fontFamily: 'Roboto', color: Color(0xFFFFFAEB)),
          ),
        ),
        body:

            ///redirection between the list of apiary and the map
            TabBarView(
          children: [
            ApiariesScreen(),
            ScreenApiaryMap(),
          ],
        ),
      ),
    );
  }
}
