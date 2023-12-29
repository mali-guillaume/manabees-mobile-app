///this screen contains all widget

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/Hive_model.dart';
import '../partials/form/GraphicHive.dart';

class HiveScreenGraphic extends StatefulWidget {
  final Hive hive;
  const HiveScreenGraphic({Key? key, required this.hive}) : super(key: key);

  @override
  State<HiveScreenGraphic> createState() => _HiveScreenGraphicState();
}

class _HiveScreenGraphicState extends State<HiveScreenGraphic>
    with WidgetsBindingObserver {
  late List<HiveGraphic> _partial;

  void _addNewGraphic() {
    int index = _partial.length;
    setState(() {
      _partial.add(HiveGraphic(hive: widget.hive, index: index,));
      print(_partial);
    });
    SaveWidget();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _partial = [];
    WidgetsBinding.instance.addObserver(this);
    _loadWidgets();
  }


  ///
  Future<void> SaveWidget() async {
    final widgetStrings = _partial.map((widget) => widget.toString()).toList();
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('widgets${widget.hive.Name}', widgetStrings);
  }



///load all widget for build this page
  Future<void> _loadWidgets() async {
    final prefs = await SharedPreferences.getInstance();
    final widgetString = prefs.getStringList('widgets${widget.hive.Name}');
    if (widgetString == null) {
      print("je veux recpere tout ");
      return;
    }
    final widgetList = <HiveGraphic>[];

    for(int i= 0; i< widgetString.length ; i++){
      widgetList.add(HiveGraphic(hive: widget.hive, index: i));
    }





    setState(() {
      _partial = widgetList;
    });
  }


  ///delete the information in sharedPreference
  Future<void> DeleteGraf(index) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('capteur${widget.hive.Name}${index}');
    prefs.remove('graphique${widget.hive.Name}${index}');
    prefs.remove('premierjour${widget.hive.Name}${index}');
    prefs.remove('dernierJour${widget.hive.Name}${index}');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }





  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xFFFFFAEB),
      body:
          ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: _partial.length,
        itemBuilder: (context, index) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  height: size.height * 0.75,
                  width: size.height * 0.75,
                  child: _partial[index],
                ),
              ),
              Container(
                alignment: Alignment.topRight,
                child: IconButton(
                    color: Color(0xFFC69D43),
                    onPressed: () {
                      setState(() {

                        DeleteGraf(index);
                        _partial.removeAt(index);
                      });
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    )),
              )
            ],
          );
        },
      ),


///button add a new widget [partialGraphic]
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFC69D43),
        foregroundColor: Colors.black,
        onPressed: _addNewGraphic,
        child: Icon(Icons.add),
      ),

    );
  }
}




