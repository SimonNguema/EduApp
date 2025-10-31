import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/evenement_model.dart';

class EvenementService {
  final CollectionReference _db =
      FirebaseFirestore.instance.collection('evenements');

  // Utilise l'URL statique du modèle
  String get staticImageUrl => Evenement.staticImageUrl;

  // Ajouter un événement (sans upload d'image)
  Future<void> addEvenement({
    required String title,
    required String description,
  }) async {
    await _db.add({
      'title': title,
      'description': description,
      'imageUrl': Evenement.staticImageUrl, 
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Récupérer la liste des événements (stream)
  Stream<List<Evenement>> getEvenements() {
    return _db
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Evenement.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  // Supprimer un événement
  Future<void> deleteEvenement(String id) async {
    await _db.doc(id).delete();
  }
}