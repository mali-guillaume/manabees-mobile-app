///this screen allows a user to create a new user
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Login_form.dart';
import '/services/ApiService.dart';

import '../models/User_model.dart';
import '../routes/Routes.dart';

class SignupPage extends StatelessWidget {
  SignupPage({Key? key}) : super(key: key);

  final mailController = TextEditingController();
  final mdpController = TextEditingController();
  final mdpconfirmController = TextEditingController();
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  Future<int>? _futureint;

  Future<User>? _futureUser;

  Future<void> BackupUser() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'token', mailController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height - 50,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text(
                    "Sign up",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Create a account",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
              Column(
                children: <Widget>[
                  inputFile(label: "Name", controller: nomController),
                  inputFile(label: "Firstname", controller: prenomController),
                  inputFile(label: "mail", controller: mailController),
                  inputFile(
                      label: "Password",
                      obscureText: true,
                      controller: mdpController),
                  inputFile(
                      label: "confirm mdp ",
                      obscureText: true,
                      controller: mdpconfirmController)
                ],
              ),
              Container(
                padding: EdgeInsets.only(top: 3, left: 3),
                child: MaterialButton(
                  highlightColor: Colors.amber,
                  minWidth: double.infinity,
                  height: 60,
                  onPressed: () {
                    if (mdpController.text == mdpconfirmController.text) {
                      _futureint =
                          httpService().verifyUser(mailController.text);

                      _futureint!.then((value) {
                        print(value);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("user exist already")));
                      }).catchError((onError) async {
                        print("prrr");
                        User user = new User(
                            name: nomController.text,
                            firstname: prenomController.text,
                            mail: mailController.text,
                            password: mdpController.text);
                        _futureUser = httpService().createUser(user);
                        BackupUser();

                        Navigator.pushNamed(context, kHomeNotConnectedRoute);
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("the passwords aren't equals")));
                    }
                  },
                  color: Colors.amberAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    "login",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
