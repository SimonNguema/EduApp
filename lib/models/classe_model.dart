class Classe {
  final String id;
  final String name;
  final String filiereId;

  Classe({required this.id, required this.name, required this.filiereId});

  Map<String, dynamic> toMap() => {
    'name': name,
    'filiereId': filiereId,
    'createdAt': DateTime.now().toUtc(),
  };

  factory Classe.fromMap(String id, Map<String, dynamic> map) {
    return Classe(
      id: id,
      name: map['name'],
      filiereId: map['filiereId'],
    );
  }
}
