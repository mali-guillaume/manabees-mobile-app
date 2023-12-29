///this screen is the first one you see when not connected
import 'package:flutter/material.dart';
import '../routes/Routes.dart';

import '../main.dart';

class HomeNotConnected extends StatelessWidget {
  const HomeNotConnected({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text(
                    "Welcome",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Welcome Manabees App Mobile",
                    style: TextStyle(color: Colors.grey[700], fontSize: 15),
                  )
                ],
              ),
              /*Container(
                height: MediaQuery.of(context).size.height/3,
                decoration: BoxDecoration(
                  image: DecorationImage(image: )
                )
              )*/
              Column(
                children: <Widget>[
                  MaterialButton(
                    minWidth: double.infinity,
                    height: 60,
                    onPressed: () {
                      Navigator.pushNamed(context, kLoginRoute);
                    },
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.black
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  MaterialButton(
                    minWidth: double.infinity,
                    height: 60,
                    onPressed: () {
                      Navigator.pushNamed(context, kRegisterRoute);
                    },
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: Colors.black
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    color: Colors.amber,
                    child: Text(
                      "Sign up",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
