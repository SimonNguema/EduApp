import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/planning_model.dart';
import '../models/session_model.dart';

class PlanningService {
  final CollectionReference _db = FirebaseFirestore.instance.collection('plannings');

  // Crée planning (doc) et retourne son id
  Future<String> createPlanning({ required String classeId, required DateTime startDate, required DateTime endDate }) async {
    final doc = await _db.add({
      'classeId': classeId,
      'startDate': startDate.toUtc(),
      'endDate': endDate.toUtc(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  // Ajout d'une session sous un planning
  Future<void> addSession(String planningId, Session session) async {
    await _db.doc(planningId).collection('sessions').add(session.toMap());
  }

  // VERSION TEMPORAIRE - Sans orderBy pour éviter l'index
  Stream<List<Planning>> getPlanningsForClasse(String classeId) {
    return _db
        .where('classeId', isEqualTo: classeId)
        // .orderBy('startDate', descending: true) // Commenté temporairement
        .snapshots()
        .map((snap) {
      final plannings = snap.docs.map((d) => Planning.fromMap(d.id, d.data() as Map<String, dynamic>)).toList();
      
      // Tri manuel côté client
      plannings.sort((a, b) => b.startDate.compareTo(a.startDate));
      return plannings;
    });
  }

  // Récupérer sessions d'un planning
  Stream<List<Session>> getSessions(String planningId) {
    return _db.doc(planningId).collection('sessions').orderBy('date').snapshots().map((snap) =>
      snap.docs.map((d) => Session.fromMap(d.id, d.data() as Map<String, dynamic>)).toList()
    );
  }

  // Récupérer tous les plannings (version temporaire)
  Stream<List<Planning>> getPlannings() {
    return _db
        // .orderBy('startDate', descending: true) // Commenté temporairement
        .snapshots()
        .map((snap) {
      final plannings = snap.docs.map((d) => Planning.fromMap(d.id, d.data() as Map<String, dynamic>)).toList();
      
      // Tri manuel côté client
      plannings.sort((a, b) => b.startDate.compareTo(a.startDate));
      return plannings;
    });
  }

  // Récupérer un planning avec ses sessions
  Future<PlanningWithSessions> getPlanningWithSessions(String planningId) async {
    // Récupérer le planning
    final planningDoc = await _db.doc(planningId).get();
    final planning = Planning.fromMap(planningId, planningDoc.data() as Map<String, dynamic>);
    
    // Récupérer les sessions
    final sessionsSnapshot = await _db.doc(planningId).collection('sessions').orderBy('date').get();
    final sessions = sessionsSnapshot.docs.map((doc) => Session.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
    
    return PlanningWithSessions(planning: planning, sessions: sessions);
  }
}

// Classe pour contenir le planning et ses sessions
class PlanningWithSessions {
  final Planning planning;
  final List<Session> sessions;

  PlanningWithSessions({required this.planning, required this.sessions});
}