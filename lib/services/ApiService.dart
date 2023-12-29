import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';


import 'package:http/http.dart' as http;

import '../models/Apiary_model.dart';
import '../models/Dataset_model.dart';
import '../models/Hive_model.dart';
import '../models/SensorMysql_model.dart';
import '../models/TimeStamp_model.dart';
import '../models/User_model.dart';




///helper to reach an API
class httpService {


  /// Create [User_model.User] in the api
  ///
  /// return [User_model.User] is true
  ///
  /// return [Exception] is false
  Future<User> createUser(User user) async {
    print(user.toJson());
    final response = await http.post(
      Uri.parse('http://vmlin002.manakeen.local:8080/api/User/create.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'Name': user.name,
        'Firstname': user.firstname,
        'Mail': user.mail,
        'Password': user.password
      }),
    );

    if (response.statusCode == 201) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON

      print(response.body);

      return User.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.

      throw Exception('Failed to create User.');
    }
  }


  ///verify password and email
  ///
  /// return user
  ///
  /// param mail and mdp
  Future<User> verifyUserandPassword(String mail, String mdp) async {
    final response = await http.post(
      Uri.parse(
          'http://vmlin002.manakeen.local:8080/api/User/verifypassword.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'Mail': mail, 'Password': mdp}),
    );

    print(response.statusCode);
    if (response.statusCode == 200) {
      print(response.body);
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      print("coucou");

      return User.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.

      throw Exception("mauvais mdp");
    }
  }



  ///verifyUser in the api if [mail] exist
  ///
  /// return 1 is true
  ///
  /// return 0 is false
  Future<int> verifyUser(String mail) async {
    final response = await http.post(
      Uri.parse('http://vmlin002.manakeen.local:8080/api/User/verifymail.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'Mail': mail}),
    );

    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {
       bool json = jsonDecode(response.body);

       if(json)
         {
           return 1;
         }
       else{
         throw Exception("utilisateur non existant");
       }


    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception("utilisateur non existant");
    }
  }




  /// collect all the hive
  ///
  /// return [Future<List<Ruche>>] if he can parse in the list of the hive
  ///
  /// return [Exception] if not the hive
  Future<List<Hive>> getHives() async {
    final response = await http.post(
      Uri.parse('http://vmlin002.manakeen.local:8080/api/Ruche/read.php'),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      print(response.body);

      //return (ddd as List).map((data) => new Ruche.fromJson(data)).toList();*/
      var json = response.body;
      //print(json);
      return hiveFromJson(json);
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.

      throw Exception('Failed to create User.');
    }
  }

  ///collect all the data of the sensor
  ///
  /// return [Future<List<Dataset>>] if the api send the data
  ///
  /// return [Exception] if not can parse in the Dataset
  Future<List<Dataset>> getDataset(String data) async {
    print('$data');
    final response = await http.post(
      Uri.parse('http://vmlin002.manakeen.local:8080/api/dataset/read.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'capteur': data,
      }),
    );
    String res = response.request.toString();
    print('$res');
    print(response.statusCode);
    if (response.statusCode == 200) {
      print(response.body);

      //return (ddd as List).map((data) => new Ruche.fromJson(data)).toList();*/
      var json = response.body;
      //print(json);
      return datasetFromJson(json);
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.

      throw Exception('Failed to create User.');
    }
  }




  ///collect all the hive with [nom]
  ///
  ///return [Future<List<Ruche>>] if the api return the [ruche_model.Ruche]
  ///
  ///return [Exception] if if not can parse in the [ruche_model.Ruche]
  Future<List<Hive>> getHivesSearch(String nom) async {
    final response = await http.post(
      Uri.parse(
          'http://vmlin002.manakeen.local:8080/api/Ruche/read_search.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nom': nom,
      }),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      print(response.body);

      //return (ddd as List).map((data) => new Ruche.fromJson(data)).toList();*/
      var json = response.body;
      //print(json);
      return hiveFromJson(json);
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.

      throw Exception('Failed to create User.');
    }
  }




  /// collect all hive of the owner with name
  ///
  /// return [Future<List<Ruche>>] if the api return List<[ruche_model.Ruche]> in the json
  ///
  /// return [Exception] if can not parse in the List<[ruche_model.Ruche]>
  Future<List<Hive>> getHivesSearchProprietaire(
      String nom, String mail) async {
    final response = await http.post(
      Uri.parse(
          'http://vmlin002.manakeen.local:8080/api/Ruche/read_searchProprietaire.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nom': nom,
        'mail': mail,
      }),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      print(response.body);

      //return (ddd as List).map((data) => new Ruche.fromJson(data)).toList();*/
      var json = response.body;
      //print(json);
      return hiveFromJson(json);
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.

      throw Exception('Failed to create User.');
    }
  }


  ///collect all the sensors in the hive
  ///
  /// return [Future<List<Capteur>>] if the api return List<[Capteur]> in the json
  ///
  /// return [Exception] if can not parse in the List<[Capteur]>
  Future<List<Sensor_model>> getDatasetName(int? hiveid) async {
    //print('$data');
    final response = await http.post(
      Uri.parse(
          'http://vmlin002.manakeen.local:8080/api/dataset/readAllCapteur.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'hiveid': hiveid.toString(),
      }),
    );
    String res = response.request.toString();
    print('$res');
    print(response.statusCode);
    if (response.statusCode == 200) {
      print(response.body);

      //return (ddd as List).map((data) => new Ruche.fromJson(data)).toList();*/
      var json = response.body;
      //print(json);
      return sensorFromJson(json);
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.

      throw Exception('Failed to create User.');
    }
  }



  ///retrieve data for the hive with sensor
  ///
  /// return list<Dataset>
  ///
  /// param sensor, hiveid, dataset min and max
  Future<List<Dataset>> getDatasetHiveID(String sensor, String hiveid,String min, String max) async {

    final response = await http.post(
      Uri.parse('http://vmlin002.manakeen.local:8080/api/dataset/readHive.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'capteur': sensor,
        'hiveid': hiveid,
        'min': min,
        'max':max,
      }),
    );
    String res = response.request.toString();
    print('$res');
    print(response.statusCode);
    if (response.statusCode == 200) {
      print(response.body);

      //return (ddd as List).map((data) => new Ruche.fromJson(data)).toList();*/
      var json = response.body;
      //print(json);
      return datasetFromJson(json);
    } else {
      /// If the server did not return a 201 CREATED response,
      /// then throw an exception.

      throw Exception('Failed to create User.');
    }
  }



  ///retrieve the min and max timestamp for the dataset
  ///
  /// param hiveid
  ///
  /// return TimeStamp
  Future<List<TimeStamp>> getDatasetTimestamp(String hiveid) async {

    final response = await http.post(
      Uri.parse('http://vmlin002.manakeen.local:8080/api/dataset/readTime.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'hiveid': hiveid,
      }),
    );
    String res = response.request.toString();
    print('$res');
    print(response.statusCode);
    if (response.statusCode == 200) {
      print(response.body);

      //return (ddd as List).map((data) => new Ruche.fromJson(data)).toList();*/
      var json = response.body;
      //print(json);
      return timeStampFromJson(json);
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.

      throw Exception('Failed to create User.');
    }
  }

///retrieve all name of the sensors from the hives
  Future<List<Sensor_model>> getDatasetNameBatonnet(int? hiveid) async {

    final response = await http.post(
      Uri.parse(
          'http://vmlin002.manakeen.local:8080/api/dataset/readAllcapteurGraphiqueBatonnet.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'hiveid': hiveid.toString(),
      }),
    );
    String res = response.request.toString();
    print('$res');
    print(response.statusCode);
    if (response.statusCode == 200) {
      print(response.body);

      //return (ddd as List).map((data) => new Ruche.fromJson(data)).toList();*/
      var json = response.body;
      //print(json);
      return sensorFromJson(json);
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.

      throw Exception('Failed to create User.');
    }
  }


///retrieves the sensor data in a bar chart
  Future<List<Dataset>> getDatasetHiveIDBatonnet(String data, String hiveid, String min, String max) async {
    print('$data');
    print("min: $min");
    print("max $max");
    final response = await http.post(
      Uri.parse('http://vmlin002.manakeen.local:8080/api/dataset/readHiveBatonnet.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'capteur': data,
        'hiveid': hiveid,
        'min': min,
        'max':max,
      }),
    );
    String res = response.request.toString();
    print('$res');
    print(response.statusCode);
    if (response.statusCode == 200) {
      print(response.body);

      //return (ddd as List).map((data) => new Ruche.fromJson(data)).toList();*/
      var json = response.body;
      //print(json);
      return datasetFromJson(json);
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.

      throw Exception('Failed to create User.');
    }
  }


///retrieve all apiary of a user
  ///
  /// param name and email
  ///
  /// return list<Apiary>
  Future<List<Apiary>> getApiariesSearchProprietaire(
      String name, String mail) async {
    final response = await http.post(
      Uri.parse(
          'http://vmlin002.manakeen.local:8080/api/Apiary/read_searchProprietaire.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nom': name,
        'mail': mail,
      }),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      print(response.body);

      //return (ddd as List).map((data) => new Ruche.fromJson(data)).toList();*/
      var json = response.body;
      //print(json);
      return ApiaryFromJson(json);
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.

      throw Exception('Failed to create User.');
    }
  }


  ///search for an apiary based on its name
  ///
  /// param name and email
  ///
  /// return Future<List<Hive>>
  Future<List<Hive>> getHiveSearchApiary(
      String name, Apiary apiary) async {

    final response = await http.post(
      Uri.parse(
          'http://vmlin002.manakeen.local:8080/api/Ruche/read_searchApiary.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nom': name,
        'apiary': apiary.idApiary.toString(),
      }),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      print(response.body);

      var json = response.body;
      //print(json);
      return hiveFromJson(json);
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.

      throw Exception('Failed to create User.');
    }
  }




}
