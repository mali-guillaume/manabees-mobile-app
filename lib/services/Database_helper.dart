
import 'package:intl/intl.dart';
import 'package:nom_du_projet/models/TimeStamp_model.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/Apiary_model.dart';
import '../models/Dataset_model.dart';
import '../models/Hive_model.dart';
import '../models/NoteApiary_model.dart';
import '../models/Note_model.dart';
import '../models/SensorMysql_model.dart';
import '../models/User_model.dart';



/// class to retrieve, add, update or delete some notes
class DatabaseHelper {
  static const int _version = 2;
  static const String _dbName = "Hive.db";



  ///open database
  ///
  /// Future<Database>
  static Future<Database> _getDB() async {
    return openDatabase(join(await getDatabasesPath(), _dbName),
        onCreate: (db, version) async  {
      await db.execute('Create Table Apiary(IdApiary INTEGER PRIMARY KEY,Name varchar(50), Localisation varchar(50), IdUser INTEGER, Latitude double, Longitude double);');
      await db.execute('Create TABLE hive_data(Hiveid INTEGER PRIMARY KEY, Name varchar(50) NOT NULL, Localisation varchar(50) NOT NULL, Deployment DATE, IdApiary integer,idProprietaire integer);');
      await db.execute("Create TABLE Note(Id INTEGER PRIMARY KEY, Title TEXT NOT NULL, Description TEXT NOT NULL, Date DATE,Hiveid INTEGER, FOREIGN KEY (Hiveid) REFERENCES hive_data(Hiveid));");
      await db.execute('Create TABLE User(Id INTEGER PRIMARY KEY, Name varchar(50) NOT NULL, Firstname varchar(50) NOT NULL, Mail varchar(50) NOT NULL);');
      await db.execute('Create Table Sensor(IdSensor INTEGER PRIMARY KEY , Name varchar(50) NOT NULL, Type varchar(50) NOT NULL , Unit varchar(50) NOT NULL, Hiveid integer);');
      await db.execute("Create TABLE NoteApiary(Id INTEGER PRIMARY KEY, Title TEXT NOT NULL, Description TEXT NOT NULL, Date DATE,idApiary INTEGER, FOREIGN KEY (IdApiary) REFERENCES Apiary(IdApiary));");
      await db.execute('Create Table Dataset(IdDataset Varchar(50) PRIMARY KEY,Timestamp datetime , Data INTEGER, idSensor INTEGER, FOREIGN KEY (IdSensor) REFERENCES Sensor(IdSensor));');
      //await db.execute('Create Table Apiary(idApiary INTEGER PRIMARY KEY,nom varchar(50), localisation varchar(50), IdUser INTEGER, latitude double, longitude double);');
      //await db.execute("ALTER TABLE hive_data ADD CONSTRAINT fk_Apiary FOREIGN KEY (idApiary) REFERENCES Apiary(idApiary)");
      },
        version: _version);
  }








  /// add note
  ///
  ///return Future<int> if its true or false
  ///
  ///Create a new [Note]
  static Future<int> addNote(Note note) async {
    final db = await _getDB();
    return await db.insert("Note", note.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// update note
  ///
  ///return Future<int> if its true or false
  static Future<int> updateNote(Note note) async {

    final db = await _getDB();
    return await db.update("Note", note.toJson(),
        where: 'Id = ?',
        whereArgs: [note.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  ///delete note
  ///
  ///return Future<int> if its true or false
  static Future<int> deleteNote(Note note) async {
    final db = await _getDB();
    return await db.delete("Note",
        where: 'Id = ?',
        whereArgs: [note.id],
    );
  }

  ///recover all note
  ///
  /// return Future<List<Notes>?>
  static Future<List<Note>?> getAllNotes(Hive hive) async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query("Note where Hiveid = ${hive.hiveid}");
    if(maps.isEmpty){
      return null;
    }

    return List.generate(maps.length, (index) => Note.fromJson(maps[index]));
  }


  /// retrieve all the notes of the day [DateTime]
  ///
  ///retrieves all the notes for the day requested
  ///
  ///retunrs the new list of the notes
  static Future<List<Note>?> getAllNotesofDay(DateTime date, Hive hive) async {
    String dateBD = DateFormat("yyyy-MM-dd").format(date);
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query("Note where Date = '$dateBD' and Hiveid = ${hive.hiveid}");
    if(maps.isEmpty){
      return null;
    }

    return List.generate(maps.length, (index) => Note.fromJson(maps[index]));
  }


  /// This function retrieves a list of Hive objects from a database based on the
  /// owner's name and email.
  ///
  /// param the nom ( name of hive ), email for the owner
  static Future<List<Hive>?> getAllHiveByProprietaire(String nom,String mail) async {
    final db = await _getDB();

    final List<Map<String, dynamic>> maps = await db.query("hive_data where Name like '${nom}%'");
    if(maps.isEmpty){
      return null;
    }
    return List.generate(maps.length, (index) => Hive.fromJson(maps[index]));
  }


  /// This function adds a Hive object to a SQLite database.
  ///
  ///param hive
  ///
  /// return future<int>
  static Future<int> addHive(Hive hive) async {
    final db = await _getDB();
    return await db.insert("hive_data", hive.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }



  /// This function adds a user to the "User" table in a database using their JSON
  /// representation.
  ///
  ///param user
  ///
  /// return Future<int>
  static Future<int> addUser(User user) async {
    final db = await _getDB();
    return await db.insert("User", user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }



  ///retrieve hive by its ID
  static Future<List<Hive>?> getHiveByID(int? id) async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query("hive_data where Hiveid = ${id}");
    if(maps.isEmpty){
      return null;
    }

    return List.generate(maps.length, (index) => Hive.fromJson(maps[index]));
  }


  ///delete hive
  ///
  /// param hive
  static Future<int> deleteHive(Hive hive) async {
    final db = await _getDB();
    return await db.delete("Hive",
      where: 'Id = ?',
      whereArgs: [hive.hiveid],
    );
  }


  ///delete sensor
  ///
  /// param sensor
  static Future<int> deleteSensor(Sensor_model sensor) async {
    final db = await _getDB();
    return await db.delete("Sensor",
      where: 'Id = ?',
      whereArgs: [sensor.idSensor],
    );
  }


///add sensen
  ///
  /// param sensor
  static Future<int> addSensor(Sensor_model sensor) async {
    final db = await _getDB();
    return await db.insert("Sensor", sensor.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }


  ///add dataset
  ///
  /// param dataset
  static Future<int> addDataset(Dataset dataset) async {
    final db = await _getDB();
    return await db.insert("Dataset", dataset.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }


  ///retrieves all sensor for the application
  static Future<List<Sensor_model>?> getAllSensorByHive(Hive hive) async {
    final db = await _getDB();

    final List<Map<String, dynamic>> maps = await db.query("Sensor where Hiveid = '${hive.hiveid}' and Name not like '%bee%'");
    if(maps.isEmpty){
      return null;
    }
    return List.generate(maps.length, (index) => Sensor_model.fromJson(maps[index]));
  }


  ///retrieves all dataset for the bar graphic
  ///
  static Future<List<Sensor_model>?> getAllSensorByHiveBatonnet(Hive hive) async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query("Sensor where Hiveid = '${hive.hiveid}' and Name like '%bee%'");
    print(maps.length);
    if(maps.isEmpty){
      return null;
    }
    return List.generate(maps.length, (index) => Sensor_model.fromJson(maps[index]));
  }



  ///retrieves all Apiary for user
  ///
  /// return Future<List<Apiary>>
  ///
  ///
  static Future<List<Apiary>?> getAllApiaryByProprietaire(String nom,String mail) async {
    final db = await _getDB();

    final List<Map<String, dynamic>> maps = await db.query("Apiary where Name like '${nom}%'");
    if(maps.isEmpty){
      return null;
    }
    return List.generate(maps.length, (index) => Apiary.fromJson(maps[index]));
  }


  static Future<int> addApiary(Apiary apiary) async {
    final db = await _getDB();
    return await db.insert("Apiary", apiary.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }


  ///retrieves all dataset for a hive
  ///
  /// param hive
  ///
  /// return List<Dataset>
  static Future<List<Dataset>?> getAllDatasetByHive(Hive hive) async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query("Dataset where Hiveid = ${hive.hiveid}");
    if(maps.isEmpty){
      return null;
    }

    return List.generate(maps.length, (index) => Dataset.fromJson(maps[index]));
  }




  /// This function retrieves a list of datasets from a database based on a given for one hour
  /// Hive, time range, and sensor.
  ///
  ///param hive ,Datetime min max ,sensor
  ///
  /// Returns:
  ///   This function returns a Future object that resolves to a List of Dataset
  /// objects that match the specified criteria (hive, time range, and sensor). If
  /// no matching datasets are found, it returns null.
  static Future<List<Dataset>?> getAllDatasetByHivebyHour(Hive hive,DateTime min , DateTime max, String sensor) async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query("Dataset where idDataset like '%Hour%' and Date('$min') <= Date(timestamp) and Date('$max') >= Date(timestamp) and idSensor =(select idSensor from Sensor where Name like '${sensor}')");
    if(maps.isEmpty){
      return null;
    }

    return List.generate(maps.length, (index) => Dataset.fromJson(maps[index]));
  }

  /// This function retrieves a list of datasets from a database based on a given for 6 hours
  /// Hive, time range, and sensor.
  ///
  ///param hive ,Datetime min max ,sensor
  ///
  /// Returns:
  ///   This function returns a Future object that resolves to a List of Dataset
  /// objects that match the specified criteria (hive, time range, and sensor). If
  /// no matching datasets are found, it returns null.
  static Future<List<Dataset>?> getAllDatasetByHiveby6Hours(Hive hive,DateTime min , DateTime max, String sensor) async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query("Dataset where idDataset like '%6Hours%' and Date('$min') <= Date(timestamp) and Date('$max') >= Date(timestamp) and idSensor =(select idSensor from Sensor where Name like '${sensor}')");
    if(maps.isEmpty){
      return null;
    }

    return List.generate(maps.length, (index) => Dataset.fromJson(maps[index]));
  }


  /// This function retrieves a list of datasets from a database based on a given for a day
  /// Hive, time range, and sensor.
  ///
  ///param hive ,Datetime min max ,sensor
  ///
  /// Returns:
  ///   This function returns a Future object that resolves to a List of Dataset
  /// objects that match the specified criteria (hive, time range, and sensor). If
  /// no matching datasets are found, it returns null.
  static Future<List<Dataset>?> getAllDatasetByHivebyDay(Hive hive,DateTime min , DateTime max, String sensor) async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query("Dataset where idDataset like '%Day%' and Date('$min') <= Date(timestamp) and Date('$max') >= Date(timestamp) and idSensor =(select idSensor from Sensor where Name like '${sensor}')");
    if(maps.isEmpty){
      return null;
    }

    return List.generate(maps.length, (index) => Dataset.fromJson(maps[index]));
  }


  /// This function retrieves a list of datasets from a database based on a given for 30 min
  /// Hive, time range, and sensor.
  ///
  ///param hive ,Datetime min max ,sensor
  ///
  /// Returns:
  ///   This function returns a Future object that resolves to a List of Dataset
  /// objects that match the specified criteria (hive, time range, and sensor). If
  /// no matching datasets are found, it returns null.
  static Future<List<Dataset>?> getAllDatasetByHiveBy30min(Hive hive,DateTime min , DateTime max, String sensor) async {

    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query("Dataset where idDataset like '%30min%' and Date('$min') <= Date(timestamp) and Date('$max') >= Date(timestamp) and idSensor =(select idSensor from Sensor where Name like '${sensor}')");
    if(maps.isEmpty){
      return null;
    }

    return List.generate(maps.length, (index) => Dataset.fromJson(maps[index]));
  }


  /// This function retrieves a list of datasets from a database based on a given for 12 hours
  /// Hive, time range, and sensor.
  ///
  ///param hive ,Datetime min max ,sensor
  ///
  /// Returns:
  ///   This function returns a Future object that resolves to a List of Dataset
  /// objects that match the specified criteria (hive, time range, and sensor). If
  /// no matching datasets are found, it returns null.
  static Future<List<Dataset>?> getAllDatasetByHiveby12hours(Hive hive,DateTime min , DateTime max, String sensor) async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query("Dataset where idDataset like '%12Hours%' and Date('$min') <= Date(timestamp) and Date('$max') >= Date(timestamp) and idSensor =(select idSensor from Sensor where Name like '${sensor}')");
    if(maps.isEmpty){
      return null;
    }

    return List.generate(maps.length, (index) => Dataset.fromJson(maps[index]));
  }


  /// This function retrieves a list of datasets from a database based on certain
  /// criteria, including the hive ID, date range, and sensor name.
  ///
  ///param hive , Datetime min and max sensor_model
  ///
  /// Returns:
  ///   This function returns a Future object that resolves to a List of Dataset
  /// objects that match the specified criteria of being associated with a
  /// particular Hive, having an ID containing the string "Batonnet", having a
  /// timestamp within a specified range, and being associated with a specified
  /// Sensor. If no matching datasets are found, it returns null.
  static Future<List<Dataset>?> getAllDatasetByHivebyBatonnet(Hive hive,DateTime min , DateTime max, String sensor) async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query("Dataset where idDataset like '%Batonnet%' and Date('$min') <= Date(timestamp) and Date('$max') >= Date(timestamp) and idSensor =(select IdSensor from Sensor where Name like '$sensor' and Hiveid = ${hive.hiveid})");
    if(maps.isEmpty){
      return null;
    }

    return List.generate(maps.length, (index) => Dataset.fromJson(maps[index]));
  }







  /// This function retrieves an Apiary object from the database based on its ID.
  ///
  /// param Id
  ///
  /// Returns:
  ///   This function returns a `Future` that resolves to a `List` of `Apiary`
  /// objects that match the provided `id`. If no matching `Apiary` is found, it
  /// returns `null`.
  static Future<List<Apiary>?> getApiaryByID(int? id) async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query("Apiary where idApiary = ${id}");
    if(maps.isEmpty){
      return null;
    }

    return List.generate(maps.length, (index) => Apiary.fromJson(maps[index]));
  }


  /// This function deletes an Apiary object from the database using its id.
  ///
  ///param apiary
  ///
  /// return Future<int>
  static Future<int> deleteApiary(Apiary apiary) async {
    final db = await _getDB();
    return await db.delete("Apiary",
      where: 'IdApiary = ?',
      whereArgs: [apiary.idApiary],
    );
  }

  /// add noteApiary
  ///
  ///return Future<int> if its true or false
  ///
  ///Create a new [NoteApiary]
  static Future<int> addNoteApiary(NoteApiary note) async {
    final db = await _getDB();
    return await db.insert("NoteApiary", note.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// update note
  ///
  ///return Future<int> if its true or false
  static Future<int> updateNoteApiary(NoteApiary note) async {
    final db = await _getDB();
    return await db.update("NoteApiary", note.toJson(),
        where: 'Id = ?',
        whereArgs: [note.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  ///delete note
  ///
  ///return Future<int> if its true or false
  static Future<int> deleteNoteApiary(NoteApiary note) async {
    final db = await _getDB();
    return await db.delete("NoteApiary",
      where: 'Id = ?',
      whereArgs: [note.id],
    );
  }

  ///recover all note
  ///
  /// return Future<List<Notes>?>
  static Future<List<NoteApiary>?> getAllNotesApiary(Apiary apiary) async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query("NoteApiary where IdApiary = ${apiary.idApiary}");
    if(maps.isEmpty){
      return null;
    }

    return List.generate(maps.length, (index) => NoteApiary.fromJson(maps[index]));
  }


  /// retrieve all the notes of the day [DateTime]
  ///
  ///retrieves all the notes for the day requested
  ///
  ///retunrs the new list of the notes
  static Future<List<NoteApiary>> getAllNotesApiariesofDay(DateTime date, Apiary apiary) async {
    String dateBD = DateFormat("yyyy-MM-dd").format(date);
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query("NoteApiary where date = '$dateBD' and IdApiary = ${apiary.idApiary}");


    return List.generate(maps.length, (index) => NoteApiary.fromJson(maps[index]));
  }


  static Future<List<Hive>> getHiveSearchByApiary(String Name, Apiary apiary) async {
    final db = await _getDB();

    final List<Map<String, dynamic>> maps = await db.query("hive_data where Name like '${Name}%' and IdApiary = ${apiary.idApiary}");


    return List.generate(maps.length, (index) => Hive.fromJson(maps[index]));
  }

  static Future<List<Dataset>?> getDataset() async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query("Dataset");
    if(maps.isEmpty){
      return null;
    }

    return List.generate(maps.length, (index) => Dataset.fromJson(maps[index]));
  }



  static Future<List<TimeStamp>?> getTimeStamp() async {
    final db = await _getDB();
    List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT MAX(timestamp) AS max, MIN(timestamp) AS min FROM dataset');
    if(result.isEmpty){
      return null;
    }

    return List.generate(result.length, (index) => TimeStamp.fromJson(result[index]));
  }




}
