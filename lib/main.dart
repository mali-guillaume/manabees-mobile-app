///
import 'package:flutter/material.dart';


import 'package:intl/date_symbol_data_local.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/BluetoothProvider.dart';
import 'routes/Router.dart';
import 'routes/Routes.dart';



/// This function initializes date formatting and runs the MyApp widget.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting().then((_) => runApp(
    ChangeNotifierProvider(
      create: (context) => BluetoothProvider(),
      child: MyApp(),
    ),
  ));
}


class MyApp extends StatelessWidget {



  /// This function fetches a token from FlutterSession and returns it as a
  /// Future<String>.
  ///
  /// Returns:
  ///   A `Future<String>` object is being returned.
  Future<String?> fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final UserString =
    prefs.getString('token');

    return UserString;
  }




  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          ///if there is a token, the user will be redirected kHOMERoute
          if (snapshot.hasData && snapshot.data != '') {

            user = snapshot.data;
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              initialRoute: kHomeConnectedRoute,
              routes: router,
            );
          } else {
            ///if there isn't a token, the user will be redirected on KHomeRoute
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              initialRoute: kHomeNotConnectedRoute,
              routes: router,
            );
          }
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}


var user;