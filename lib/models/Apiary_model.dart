///this model allows you to create a Dataset

import 'dart:convert';
import 'dart:io';

import '../services/Database_helper.dart';
import '../services/ApiService.dart';

///Collect a list of [Apiary]
///
/// param = str json code sent by the API
///
/// return list of [Apiary]
List<Apiary> ApiaryFromJson(String str) =>
    List<Apiary>.from(json.decode(str).map((x) => Apiary.fromJson(x)));

///this model allows you to create an Apiary
class Apiary {
  final int? idApiary;
  final String Name;
  final String localisation;
  final int? idUser;
  final double latitude;
  final double longitude;

  const Apiary(
      {required this.Name,
      required this.localisation,
      required this.longitude,
      required this.latitude,
      this.idApiary,
      this.idUser});

  ///convert Json to Apiary(model)
  ///
  /// return Apiary
  factory Apiary.fromJson(Map<String, dynamic> json) => Apiary(
        idApiary: json['IdApiary'],
        Name: json['Name'],
        localisation: json['Localisation'],
        idUser: json['IdUser'],
        latitude: json['Latitude'],
        longitude: json['Longitude'],
      );

  ///convert Apiary(model) to Json
  ///
  /// return Apiary  in Json
  Map<String, dynamic> toJson() => {
        'IdApiary': idApiary,
        'Name': Name,
        'Localisation': localisation,
        'IdUser': idUser,
        'Localisation': localisation,
        'Latitude': latitude,
        'Longitude': longitude,
      };

  @override
  String toString() {
    return 'id: $idApiary, nom: $Name localisation: $localisation';
  }
}

/// this method allows to compare the Apiary in the database sqLite and the API
Future<List<Apiary>?> getApiaryFromSQLiteorApi(String nom, String mail) async {
  List<Apiary>? apiaryFromSQLite = await getApiaryFromSQlite(nom, mail);
  if (apiaryFromSQLite != null) {
    if (await hasInternetConnection()) {
      List<Apiary> apiariesFromAPI =
          await httpService().getApiariesSearchProprietaire(nom, mail);
      if (apiariesFromAPI != null) {
        if (await hasInternetConnection()) {
          List<Apiary> diffApiaries =
              compareApiaries(apiaryFromSQLite, apiariesFromAPI);
          if (diffApiaries.isNotEmpty) {
            await copyApiaryToSQLite(diffApiaries);
            return await getApiaryFromSQlite(nom, mail);
          }
        }
      }

      return apiaryFromSQLite;
    }
  } else {
    if (await hasInternetConnection()) {
      List<Apiary>? apiariesFromAPI = await getApiaryFromAPI(nom, mail);
      if (apiariesFromAPI != null) {
        await copyApiaryToSQLite(apiariesFromAPI);
        return apiariesFromAPI;
      }
    }
  }
  return apiaryFromSQLite;
}

///get the Apiary in the database sqlite
Future<List<Apiary>?> getApiaryFromSQlite(String nom, String mail) async {
  return DatabaseHelper.getAllApiaryByProprietaire(nom, mail);
}

/// get the Apiary in the API
///
/// return list<Apiary>
Future<List<Apiary>?> getApiaryFromAPI(String nom, String mail) async {
  if (await hasInternetConnection()) {
    return httpService().getApiariesSearchProprietaire(nom, mail);
  } else {
    return null;
  }
}


///first compare the Apiary in sqlite database and in API
///and then add the Apiaries in the list diffApiaries
///
/// return the Apiary that is not the sqlite database
///
/// parameter: ApiarySQLite and Apiaries from API
List<Apiary> compareApiaries(
    List<Apiary> ApiariesSQLite, List<Apiary> ApiariesAPI) {
  List<Apiary> diffApiaries = [];
  for (Apiary apiaryApi in ApiariesAPI) {
    bool isUnique = true;
    for (Apiary apiarySqlite in ApiariesSQLite) {
      if (apiaryApi.idApiary == apiarySqlite.idApiary) {
        isUnique = false;
        break;
      }
    }
    if (isUnique) {
      diffApiaries.add(apiaryApi);
    }
  }
  return diffApiaries;
}

///add the apiary in the sqlite database
Future<void> copyApiaryToSQLite(List<Apiary> apiariesAPI) async {
  for (Apiary apiary in apiariesAPI) {
    DatabaseHelper.addApiary(apiary);
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
