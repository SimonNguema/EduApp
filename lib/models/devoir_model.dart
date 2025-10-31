import 'package:cloud_firestore/cloud_firestore.dart';

class Devoir {
  final String id;
  final String title;
  final String description;
  final String classeId;
  final String classeName;
  final String matiereId;
  final String matiereName;
  final DateTime dateDevoir;
  final String heureDevoir;
  final String duree;
  final DateTime createdAt;

  Devoir({
    required this.id,
    required this.title,
    required this.description,
    required this.classeId,
    required this.classeName,
    required this.matiereId,
    required this.matiereName,
    required this.dateDevoir,
    required this.heureDevoir,
    required this.duree,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'classeId': classeId,
      'classeName': classeName,
      'matiereId': matiereId,
      'matiereName': matiereName,
      'dateDevoir': Timestamp.fromDate(dateDevoir),
      'heureDevoir': heureDevoir,
      'duree': duree,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory Devoir.fromMap(String id, Map<String, dynamic> data) {
    return Devoir(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      classeId: data['classeId'] ?? '',
      classeName: data['classeName'] ?? '',
      matiereId: data['matiereId'] ?? '',
      matiereName: data['matiereName'] ?? '',
      dateDevoir: (data['dateDevoir'] as Timestamp).toDate(),
      heureDevoir: data['heureDevoir'] ?? '',
      duree: data['duree'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  @override
  String toString() {
    return 'Devoir{id: $id, title: $title, classe: $classeName, matiere: $matiereName}';
  }
}