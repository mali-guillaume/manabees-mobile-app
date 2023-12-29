///definition for the different route

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../screen/ApiaryIndexHome.dart';
import '../screen/CalendarHiveScreen.dart';
import '../screen/HiveScreen.dart';
import '../screen/HomeConnected.dart';
import '../screen/HomeDeviceScreen.dart';
import '../screen/HomeNotConnected.dart';
import '../screen/Login_form.dart';
import '../screen/Register_form.dart';
import 'Routes.dart';

Map<String, WidgetBuilder> router = {
  kHomeNotConnectedRoute: (context) => const HomeNotConnected(),
  kRegisterRoute: (context) => SignupPage(),
  kLoginRoute: (context) => LoginForm(),
  kHomeConnectedRoute: (context) => const HomeConnected(),
  kRucheRoute: (context) => const RucheScreen(),
  kRucherRoute: (context) => const ApiaryIndexPage(),
  kAddBluetoothHive: (context) => HomeDeviceScreen(),
  //kResetPasswordRoute: (context) => const ResetPasswordForm(),
};

goHome({formKey, context}) {
  if (formKey.currentState != null && formKey.currentState!.validate()) {
    if (kDebugMode) {
      Navigator.pushNamed(context, kHomeNotConnectedRoute);
    } else {
      if (kDebugMode) {
        print('KO');
      }
    }
  }
}
