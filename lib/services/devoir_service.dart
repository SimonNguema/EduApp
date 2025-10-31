import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/devoir_model.dart';

class DevoirService {
  final CollectionReference _db =
      FirebaseFirestore.instance.collection('devoirs');

  // Ajouter un devoir
  Future<void> addDevoir({
    required String title,
    required String description,
    required String classeId,
    required String classeName,
    required String matiereId,
    required String matiereName,
    required DateTime dateDevoir,
    required String heureDevoir,
    required String duree,
  }) async {
    await _db.add({
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
    });
  }

  // Récupérer tous les devoirs (pour admin)
  Stream<List<Devoir>> getDevoirs() {
    return _db
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Devoir.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  //  Récupérer les devoirs par classe (pour étudiants)
  Stream<List<Devoir>> getDevoirsByClasse(String classeId) {
    return _db
        .where('classeId', isEqualTo: classeId)
        .orderBy('dateDevoir', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Devoir.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  // Supprimer un devoir
  Future<void> deleteDevoir(String id) async {
    await _db.doc(id).delete();
  }
}