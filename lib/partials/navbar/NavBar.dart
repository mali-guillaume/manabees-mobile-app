/// this widget use [ApiaryMenu] and [HiveMenu] to create a menu

import 'package:flutter/material.dart';

import '../../style/Constants.dart';
import 'ApiaryMenu.dart';
import 'HiveMenu.dart';


@immutable
class NavBar extends StatelessWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: kVerticalSpacer / 2, bottom: kVerticalSpacer),
      child: Row(

        children:const <Widget> [
          SizedBox(
            width: kHorizontalSpacer/2,
          ),
          Expanded(child: ApiaryMenu()),

          SizedBox(
            width: kHorizontalSpacer,
          ),
          Expanded(child: HiveMenu()),
          SizedBox(
            width: kHorizontalSpacer/2,
          ),
        ],
      ),
    );
  }
}
