///this model allows the timestamp

import 'dart:convert';
import 'dart:io';

import 'package:nom_du_projet/models/Dataset_model.dart';

import '../services/ApiService.dart';
import '../services/Database_helper.dart';
import 'Hive_model.dart';

///Collect a list of [TimeStamp]
///
/// param = str (json code sent by the api)
///
/// return list of [TimeStamp]
List<TimeStamp> timeStampFromJson(String str) =>
    List<TimeStamp>.from(json.decode(str).map((x) => TimeStamp.fromJson(x)));

///this model allows you to create a [TimeStamp]
class TimeStamp {
  final DateTime max;
  final DateTime min;

  const TimeStamp({
    required this.max,
    required this.min,
  });

  ///convert json to [TimeStamp]
  ///
  /// return [TimeStamp]
  factory TimeStamp.fromJson(Map<String, dynamic> json) => TimeStamp(
        max: DateTime.parse(json['max']),
        min: DateTime.parse(json['min']),
      );

  ///convert [TimeStamp] (model) to Json
  ///
  /// return json
  Map<String, dynamic> toJson() => {
        'max': max.toIso8601String(),
        'min': min.toIso8601String(),
      };

  @override
  String toString() {
    return 'temp max : $max, temp min: $min';
  }
}

Future<List<TimeStamp>?> getTimeFromSQLiteorApi(Hive hive) async {
  if (await hasInternetConnection()) {
    return await httpService().getDatasetTimestamp(hive.hiveid.toString());
  }
  else{
    List<Dataset>? listDatasetSql = await DatabaseHelper.getDataset();
    if (listDatasetSql != null) {
      return await DatabaseHelper.getTimeStamp();
    }
  }
}

/// check if we can reach the API
Future<bool> hasInternetConnection() async {
  try {
    final result = await InternetAddress.lookup('vmlin002.manakeen.local');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}
