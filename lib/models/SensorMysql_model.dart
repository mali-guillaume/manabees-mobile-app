///this model allows you to create a sensor
import 'dart:convert';

import 'dart:io';

import 'SensorApi_model.dart';
import 'Hive_model.dart';
import '../services/Database_helper.dart';
import '../services/ApiService.dart';

List<Sensor_model> sensorFromJson(String str) => List<Sensor_model>.from(
    json.decode(str).map((x) => Sensor_model.fromJson(x)));

class Sensor_model {
  final int? idSensor;
  final String Name;
  final String unit;
  final String type;
  final int? hiveid;

  const Sensor_model({
    required this.idSensor,
    required this.Name,
    required this.unit,
    required this.type,
    required this.hiveid,
  });

  ///convert json to Sensor
  ///
  /// return Capteur
  factory Sensor_model.fromJson(Map<String, dynamic> json) {
    return Sensor_model(
      idSensor: json['IdSensor'],
      Name: json['Name'],
      unit: json['Unit'],
      type: json['Type'],
      hiveid: json['Hiveid'],
    );
  }

  ///convert sensor to Json
  ///
  /// return json
  Map<String, dynamic> toJson() => {
        'IdSensor': idSensor,
        'Name': Name,
        'Unit': unit,
        'Type': type,
        'Hiveid': hiveid,
      };
  @override
  String toString() {
    return 'sensor: $Name, type: $type';
  }
}

/// this method allows to compare the Sensor for cartesian graphic in the database sqLite and the API
Future<List<Sensor_model>?> getSensorFromSQLiteorApi(Hive hive) async {
  List<Sensor_model>? SensorFromSQLite =
      await DatabaseHelper.getAllSensorByHive(hive);
  if (SensorFromSQLite != null) {
    if (await hasInternetConnection()) {
      List<Sensor_model> SensorFromAPI =
          await httpService().getDatasetName(hive.hiveid);
      if (SensorFromAPI != null) {
        if (await hasInternetConnection()) {
          List<Sensor_model> diffCapteur =
              compareSensor(SensorFromSQLite, SensorFromAPI);
          if (diffCapteur.isNotEmpty) {
            await copySensorToSQLite(diffCapteur);
            return await getSensorFromSQlite(hive);
          }
        }
      }
      return SensorFromSQLite;
    }
  } else {
    if (await hasInternetConnection()) {
      List<Sensor_model>? SensorFromAPI = await getSensorFromAPI(hive);

      if (SensorFromAPI != null) {
        await copySensorToSQLite(SensorFromAPI);
        return SensorFromAPI;
      }
    }
  }
  return SensorFromSQLite;
}

/// get hive from sqlite dataset
Future<List<Sensor_model>?> getSensorFromSQlite(Hive hive) async {
  return DatabaseHelper.getAllSensorByHive(hive);
}

/// get hive from API
Future<List<Sensor_model>?> getSensorFromAPI(Hive hive) async {
  if (await hasInternetConnection()) {
    return await httpService().getDatasetName(hive.hiveid);
  } else {
    return null;
  }
}

///first compare the sensors in sqlite database and in API
///and then add the sensors in the list diffDatasets
///
/// return the sensors that is not the sqlite database
///
/// parameter: sensorSqlite and sensorsApi
List<Sensor_model> compareSensor(
    List<Sensor_model> sensorSqlite, List<Sensor_model> sensorsApi) {
  List<Sensor_model> diffSensors = [];
  for (Sensor_model sensorapi in sensorsApi) {
    bool isUnique = true;
    for (Sensor_model sensor in sensorSqlite) {
      if (sensorapi.idSensor == sensor.idSensor) {
        isUnique = false;
        break;
      }
    }
    if (isUnique) {
      diffSensors.add(sensorapi);
    }
  }
  return diffSensors;
}

///add the sensors in the sqlite database
Future<void> copySensorToSQLite(List<Sensor_model> capteurs) async {
  for (Sensor_model sensor in capteurs) {
    await DatabaseHelper.addSensor(sensor);
  }
}

/// check if we can reach the Api
Future<bool> hasInternetConnection() async {
  try {
    final result = await InternetAddress.lookup('vmlin002.manakeen.local');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}
/// this method allows to compare the Sensor for bar graphic in the database sqLite and the API
Future<List<Sensor_model>?> getSensorFromSQLiteorApiBatonnet(Hive hive) async {
  List<Sensor_model>? SensorFromSQLite =
      await DatabaseHelper.getAllSensorByHiveBatonnet(hive);
  print(SensorFromSQLite);
  if (SensorFromSQLite != null) {
    if (await hasInternetConnection()) {
      List<Sensor_model> SensorFromAPI =
          await httpService().getDatasetNameBatonnet(hive.hiveid);
      if (SensorFromAPI != null) {
        if (await hasInternetConnection()) {
          List<Sensor_model> diffCapteur =
              compareSensor(SensorFromSQLite, SensorFromAPI);
          if (diffCapteur.isNotEmpty) {
            await copySensorToSQLite(diffCapteur);
            return await getSensorFromSQlite(hive);
          }
        }
      }
      return SensorFromSQLite;
    }
  } else {
    if (await hasInternetConnection()) {
      List<Sensor_model>? SensorFromAPI = await getSensorFromAPIBar(hive);

      if (SensorFromAPI != null) {
        await copySensorToSQLite(SensorFromAPI);
        return SensorFromAPI;
      }
    }
  }
  return SensorFromSQLite;
}

Future<List<Sensor_model>?> getSensorFromAPIBar(Hive hive) async {
  if (await hasInternetConnection()) {
    return httpService().getDatasetNameBatonnet(hive.hiveid);
  } else {
    return null;
  }
}
