///this model allows you to create a sensor
import 'dart:convert';



List<SensorAPI> capteurFromJson(String str) =>
    List<SensorAPI>.from(json.decode(str).map((x) => SensorAPI.fromJson(x)));



///this model allows you to create a Capteur
class SensorAPI {
  final String Name;


  const SensorAPI({
    required this.Name,

  });

  ///convert json to Capteur
  ///
  /// return Capteur
  factory SensorAPI.fromJson(Map<String, dynamic> json){
    return SensorAPI(
      Name: json['capteur'],

    );
  }


  ///convert capteur to Json
  ///
  /// return json
  Map<String, dynamic> toJson() => {
    'capteur': Name,
  };





  @override
  String toString() {
    return 'capteur: $Name';
  }
}