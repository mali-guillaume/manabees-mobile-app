/// widget allows you to create a search bar

import 'package:flutter/material.dart';
import '../../style/Constants.dart';

import 'Text_input.dart';


@immutable
class SearchInput extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final String hintext;

  const SearchInput({this.onChanged, Key? key, required this.hintext}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: kHorizontalSpacer / 2,
        ),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: kBorderRadiusItem,
            boxShadow: kBoxShadowItem),
        child: TextInput(
            icon: Icons.search,
            labelText: 'Search ',
            hintText: hintext,
            keyboardType: TextInputType.text,
            validator: (value) {},
            onChanged: onChanged,
            autofocus: false),
      ),
    );
  }
}