class Matiere {
  final String id;
  final String name;
  final double coefficient;

  Matiere({required this.id, required this.name, required this.coefficient});

  Map<String, dynamic> toMap() => {
    'name': name,
    'coefficient': coefficient,
    'createdAt': DateTime.now().toUtc(),
  };

  factory Matiere.fromMap(String id, Map<String, dynamic> map) {
    return Matiere(
      id: id,
      name: map['name'] ?? '',
      coefficient: (map['coefficient'] is num) ? (map['coefficient'] as num).toDouble() : 0.0,
    );
  }
}
