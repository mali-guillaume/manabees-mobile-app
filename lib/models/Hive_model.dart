///model allows to create a hive

import 'dart:convert';
import 'dart:io';

import '../services/Database_helper.dart';
import '../services/ApiService.dart';
import 'SensorApi_model.dart';

List<Hive> hiveFromJson(String str) =>
    List<Hive>.from(json.decode(str).map((x) => Hive.fromJson(x)));

class Hive {
  final int? hiveid;
  final String Name;
  final String localisation;
  final String deployment;
  final int idApiary;
  final int idProprietaire;

  const Hive(
      {required this.Name,
      required this.localisation,
      required this.deployment,
      this.hiveid,
      required this.idProprietaire,
      required this.idApiary});

  ///convert json to Hive
  ///
  /// return Hive
  factory Hive.fromJson(Map<String, dynamic> json) => Hive(
      hiveid: json['Hiveid'],
      Name: json['Name'],
      localisation: json['Localisation'],
      deployment: json['Deployment'],
      idApiary: json['IdApiary'],
      idProprietaire: json['idProprietaire']);

  ///convert Hive to Json
  ///
  /// return json
  Map<String, dynamic> toJson() => {
        'Hiveid': hiveid,
        'Name': Name,
        'Localisation': localisation,
        'Deployment': deployment,
        'IdApiary': idApiary,
        'idProprietaire': idProprietaire,
      };

  @override
  String toString() {
    return 'id: $hiveid, nom: $Name localisation: $localisation';
  }
}

/// this method allow to compare the Hive in the database sqLite et the API
Future<List<Hive>?> getHiveFromSQLiteorApi(String nom, String mail) async {
  List<Hive>? hiveFromSQLite = await getHiveFromSQlite(nom, mail);
  if (hiveFromSQLite != null) {
    if (await hasInternetConnection()) {
      List<Hive> hivesFromAPI =
          await httpService().getHivesSearchProprietaire(nom, mail);
      if (hivesFromAPI != null) {
        if (await hasInternetConnection()) {
          List<Hive> diffHives = compareHives(hiveFromSQLite, hivesFromAPI);
          if (diffHives.isNotEmpty) {
            await copyHiveToSQLite(diffHives);
            return await getHiveFromSQlite(nom, mail);
          }
        }
      }
      return hiveFromSQLite;
    }
  } else {
    if (await hasInternetConnection()) {
      List<Hive>? ruchesFromAPI = await getHiveFromAPI(nom, mail);
      if (ruchesFromAPI != null) {
        await copyHiveToSQLite(ruchesFromAPI);
        return ruchesFromAPI;
      }
    }
  }
  return hiveFromSQLite;
}

/// get hive from sqlite dataset
Future<List<Hive>?> getHiveFromSQlite(String nom, String mail) async {
  return DatabaseHelper.getAllHiveByProprietaire(nom, mail);
}
/// get hive from API
Future<List<Hive>?> getHiveFromAPI(String name, String mail) async {
  if (await hasInternetConnection()) {
    return httpService().getHivesSearchProprietaire(name, mail);
  } else {
    return null;
  }
}

///first compare the Hives in sqlite database and in API
///and then add the Hives in the list diffDatasets
///
/// return the Hives that is not the sqlite database
///
/// parameter: hivesSQLite and hives from API
List<Hive> compareHives(List<Hive> hiveSqlite, List<Hive> hivesApi) {
  List<Hive> diffHives = [];
  for (Hive hive in hivesApi) {
    bool isUnique = true;
    for (Hive hive2 in hiveSqlite) {
      if (hive.hiveid == hive2.hiveid) {
        isUnique = false;
        break;
      }
    }
    if (isUnique) {
      diffHives.add(hive);
    }
  }
  return diffHives;
}

///add the Hives in the sqlite database
Future<void> copyHiveToSQLite(List<Hive> hives) async {
  for (Hive hive in hives) {
    DatabaseHelper.addHive(hive);
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
