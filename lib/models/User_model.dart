///this model allows you to create a User

class User {
  final int? IdUser;
  final String name;
  final String firstname;
  final String mail;
  final String password;

  const User({
    required this.name,
    required this.firstname,
    this.IdUser,
    required this.mail,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json){
    return User(
      IdUser: json['IdUser'],
      name: json['Name'],
      firstname: json['Firstname'],
      mail: json['Mail'],
      password: json['Password'],
    );
  }



  Map<String, dynamic> toJson() => {
        'IdUser': IdUser,
        'Name': name,
        'Firstname': firstname,
        'Mail': mail,
        'Password': password
      };



  @override
  String toString() {
    // TODO: implement toString
    return 'id: $IdUser, nom: $name prenom: $firstname';
  }
}
