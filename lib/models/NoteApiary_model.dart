/// this model allows a noteApiary
class NoteApiary {
  final int? id;
  final String title;
  final String description;
  final String date;
  final int? idApiary;

  const NoteApiary(
      {required this.title,
        required this.description,
        this.id,
        required this.date,
        required this.idApiary});

  ///convert json to [NoteApiary]
  ///
  /// return [NoteApiary]
  factory NoteApiary.fromJson(Map<String, dynamic> json) => NoteApiary(
    id: json['Id'],
    title: json['Title'],
    description: json['Description'],
    date: json['Date'],
    idApiary: json['IdApiary'],
  );

  ///convert Note to Json
  ///
  /// return json
  Map<String, dynamic> toJson() => {
    'Id': id,
    'Title': title,
    'Description': description,
    'Date': date,
    'IdApiary' : idApiary,
  };

  @override
  String toString() {

    return 'id: $id, title: $title , description: $description idApiary: $idApiary';
  }
}