import 'package:cloud_firestore/cloud_firestore.dart';

class Session {
  final String id;
  final DateTime date;       // date complète (jour)
  final String dayName;      // ex: "Lundi"
  final String matiereId;
  final String matiereName;
  final String startTime;    // "09:00"
  final String endTime;      // "12:00"
  final double coefficient;
  final String? teacher;
  final String? room;

  Session({
    required this.id,
    required this.date,
    required this.dayName,
    required this.matiereId,
    required this.matiereName,
    required this.startTime,
    required this.endTime,
    required this.coefficient,
    this.teacher,
    this.room,
  });

  Map<String, dynamic> toMap() => {
    'date': date.toUtc(),
    'dayName': dayName,
    'matiereId': matiereId,
    'matiereName': matiereName,
    'startTime': startTime,
    'endTime': endTime,
    'coefficient': coefficient,
    'teacher': teacher,
    'room': room,
    'createdAt': DateTime.now().toUtc(),
  };

  factory Session.fromMap(String id, Map<String, dynamic> map) {
    return Session(
      id: id,
      date: (map['date'] is Timestamp) ? (map['date'] as Timestamp).toDate() : DateTime.parse(map['date']),
      dayName: map['dayName'] ?? '',
      matiereId: map['matiereId'] ?? '',
      matiereName: map['matiereName'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      coefficient: (map['coefficient'] is num) ? (map['coefficient'] as num).toDouble() : 0.0,
      teacher: map['teacher'],
      room: map['room'],
    );
  }
}
