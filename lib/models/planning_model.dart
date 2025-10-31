import 'package:cloud_firestore/cloud_firestore.dart';

class Planning {
  final String id;
  final String classeId;
  final DateTime startDate;
  final DateTime endDate;
  final List<Map<String, dynamic>> sessions; // Gardez List<Map> pour l'instant

  Planning({
    required this.id,
    required this.classeId,
    required this.startDate,
    required this.endDate,
    required this.sessions,
  });

  factory Planning.fromMap(String id, Map<String, dynamic> map) {
    return Planning(
      id: id,
      classeId: map['classeId'] ?? '',
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sessions: List<Map<String, dynamic>>.from(map['sessions'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'classeId': classeId,
      'startDate': startDate,
      'endDate': endDate,
      'sessions': sessions,
    };
  }
}