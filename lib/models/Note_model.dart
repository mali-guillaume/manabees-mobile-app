/// this model allow to recover and a note to the sqlite database
class Note {
  final int? id;
  final String title;
  final String description;
  final String date;
  final int? hiveid;

  const Note(
      {required this.title,
      required this.description,
      this.id,
      required this.date,
      required this.hiveid});

  ///convert json to [Note]
  ///
  /// return [Note]
  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['Id'],
        title: json['Title'],
        description: json['Description'],
        date: json['Date'],
    hiveid: json['Hiveid'],
      );

  ///convert Note to Json
  ///
  /// return json
  Map<String, dynamic> toJson() => {
        'Id': id,
        'Title': title,
        'Description': description,
        'Date': date,
    'Hiveid' : hiveid,
      };

  @override
  String toString() {
    return 'id: $id, title: $title , description: $description hiveid: $hiveid';
  }
}
