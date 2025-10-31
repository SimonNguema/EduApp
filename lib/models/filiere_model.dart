class Filiere {
  final String id;
  final String name;

  Filiere({required this.id, required this.name});

  Map<String, dynamic> toMap() => {
    'name': name,
    'createdAt': DateTime.now().toUtc(),
  };

  factory Filiere.fromMap(String id, Map<String, dynamic> map) {
    return Filiere(
      id: id,
      name: map['name'],
    );
  }
}
