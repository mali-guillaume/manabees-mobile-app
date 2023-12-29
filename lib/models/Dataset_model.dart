///this model allows you to create a Dataset
import 'dart:convert';
import 'dart:io';

import 'Hive_model.dart';
import '../services/Database_helper.dart';

import '../services/ApiService.dart';

///collect a list of [Dataset]
///
/// param str = json code sent by the api
///
/// return List of [Dataset]
List<Dataset> datasetFromJson(String str) =>
    List<Dataset>.from(json.decode(str).map((x) => Dataset.fromJson(x)));

class Dataset {
  final String idDataset;
  final String timestamp;
  final Data;
  final Sensor;

  const Dataset({
    required this.idDataset,
    required this.timestamp,
    required this.Data,
    required this.Sensor
  });

  ///convert json to Dataset(model)
  ///
  /// return Dataset
  factory Dataset.fromJson(Map<String, dynamic> json) {
    return Dataset(
      idDataset: json['IdDataset'],
      timestamp: json['Timestamp'],
      Data: json['Data'],
      Sensor: json['idSensor'],
    );
  }

  ///convert Dataset(model) to Json
  ///
  /// return json
  Map<String, dynamic> toJson() => {
        'IdDataset': idDataset,
        'Timestamp': timestamp,
        'idSensor': Sensor,
    'Data':Data,
      };

  @override
  String toString() {
    return 'id: $idDataset, capteur: $Sensor ';
  }
}

/// this method allows to compare the Dataset in the database SqLite and the Api
Future<List<Dataset>?> getDatasetFromSQLiteorApi(
    String data, Hive hive, String min, String max) async {
  DateTime minTime = DateTime.parse(min);
  DateTime maxTime = DateTime.parse(max).add(Duration(days: 1));
  Duration differenceTime = maxTime.difference(minTime);
  List<Dataset>? datasetFromSQLite;
  if (differenceTime.inDays < 15) {

    datasetFromSQLite = await DatabaseHelper.getAllDatasetByHiveBy30min(
        hive, minTime, maxTime, data);
  } else if (differenceTime.inDays < 30) {
    datasetFromSQLite = await DatabaseHelper.getAllDatasetByHivebyHour(
        hive, minTime, maxTime, data);
  } else if (differenceTime.inDays < 180) {
    datasetFromSQLite = await DatabaseHelper.getAllDatasetByHiveby6Hours(
        hive, minTime, maxTime, data);
  } else if (differenceTime.inDays < 365) {
    datasetFromSQLite = await DatabaseHelper.getAllDatasetByHiveby12hours(
        hive, minTime, maxTime, data);
  } else {
    datasetFromSQLite = await DatabaseHelper.getAllDatasetByHivebyDay(
        hive, minTime, maxTime, data);
  }

  if (datasetFromSQLite != null) {
    if (await hasInternetConnection()) {
      List<Dataset> DatasetFromAPI = await httpService()
          .getDatasetHiveID(data, hive.hiveid.toString(), min, max);
      if (DatasetFromAPI != null) {
        if (await hasInternetConnection()) {
          List<Dataset> diffDataset =
              compareDataset(datasetFromSQLite, DatasetFromAPI);
          if (diffDataset.isNotEmpty) {
            await copyDatasetToSQLite(diffDataset);
            //await deleteHiveFromSqLite(HiveFromSQLite, diffHives);
            return await getDatasetFromSQlite(data, hive, min, max);
          }
        }
      }
      return datasetFromSQLite;
    }
  } else {
    if (await hasInternetConnection()) {
      List<Dataset>? datasetFromAPI =
          await getDatasetFromAPI(data, hive, min, max);
      if (datasetFromAPI != null) {
        await copyDatasetToSQLite(datasetFromAPI);
        return datasetFromAPI;
      }
    }
  }
  return datasetFromSQLite;
}

/// get dataset from sqlite database
Future<List<Dataset>?> getDatasetFromSQlite(
    String data, Hive hive, String min, String max) async {
  DateTime minTime = DateTime.parse(min);
  DateTime maxTime = DateTime.parse(max);
  Duration differenceTime = maxTime.difference(minTime);
  List<Dataset>? datasetFromSQLite;
  if (differenceTime.inDays < 15) {
    datasetFromSQLite = await DatabaseHelper.getAllDatasetByHiveBy30min(
        hive, minTime, maxTime, data);
  } else if (differenceTime.inDays < 30) {
    datasetFromSQLite = await DatabaseHelper.getAllDatasetByHivebyHour(
        hive, minTime, maxTime, data);
  } else if (differenceTime.inDays < 180) {
    datasetFromSQLite = await DatabaseHelper.getAllDatasetByHiveby6Hours(
        hive, minTime, maxTime, data);
  } else if (differenceTime.inDays < 365) {
    datasetFromSQLite = await DatabaseHelper.getAllDatasetByHiveby12hours(
        hive, minTime, maxTime, data);
  } else {
    datasetFromSQLite = await DatabaseHelper.getAllDatasetByHivebyDay(
        hive, minTime, maxTime, data);
  }
  return datasetFromSQLite;
}

/// get dataset from API
Future<List<Dataset>?> getDatasetFromAPI(
    String data, Hive hive, String min, String max) async {
  if (await hasInternetConnection()) {
    return httpService()
        .getDatasetHiveID(data, hive.hiveid.toString(), min, max);
  } else {
    return null;
  }
}

///first compare the Dataset in sqlite database and in API
///and then add the Dataset in the list diffDatasets
///
/// return the Dataset that is not the sqlite database
///
/// parameter: DatasetSQLite and Apiaries from API
List<Dataset> compareDataset(
    List<Dataset> datasetsSqlite, List<Dataset> datasetsApi) {
  List<Dataset> diffdatasets = [];
  for (Dataset datasetApi in datasetsApi) {
    bool isUnique = true;
    for (Dataset datasetSqlite in datasetsSqlite) {
      if (datasetApi.idDataset == datasetSqlite.idDataset) {
        isUnique = false;
        break;
      }
    }
    if (isUnique) {
      diffdatasets.add(datasetApi);
    }
  }
  return diffdatasets;
}

///add the dataset in the sqlite database
Future<void> copyDatasetToSQLite(List<Dataset> datasets) async {
  for (Dataset dataset in datasets) {
    DatabaseHelper.addDataset(dataset);
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


Future<List<Dataset>?> getDatasetBatonnetFromSQLiteorApi(
    String sensor, Hive hive, String min, String max) async {
  DateTime minTime = DateTime.parse(min);
  DateTime maxTime = DateTime.parse(max).add(Duration(days: 1));
  Duration differenceTime = maxTime.difference(minTime);
  List<Dataset>? datasetFromSQLite = await DatabaseHelper.getAllDatasetByHivebyBatonnet(hive, minTime, maxTime, sensor);



  if (datasetFromSQLite != null) {
    if (await hasInternetConnection()) {
      List<Dataset> DatasetFromAPI = await httpService()
          .getDatasetHiveIDBatonnet(sensor, hive.hiveid.toString(), min, max);
      if (DatasetFromAPI != null) {
        if (await hasInternetConnection()) {
          List<Dataset> diffDataset =
          compareDataset(datasetFromSQLite, DatasetFromAPI);
          if (diffDataset.isNotEmpty) {
            await copyDatasetToSQLite(diffDataset);
            //await deleteHiveFromSqLite(HiveFromSQLite, diffHives);
            return DatasetFromAPI;
          }
        }
      }
      return datasetFromSQLite;
    }
  } else {
    if (await hasInternetConnection()) {
      List<Dataset>? datasetFromAPI =
      await httpService()
          .getDatasetHiveIDBatonnet(sensor, hive.hiveid.toString(), min, max);
      if (datasetFromAPI != null) {
        await copyDatasetToSQLite(datasetFromAPI);
        return datasetFromAPI;
      }
    }
  }
  return datasetFromSQLite;
}

