import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/matiere_model.dart';

class MatiereService {
  final CollectionReference _db = FirebaseFirestore.instance.collection('matieres');

  Future<void> addMatiere(String name, double coefficient) async {
    await _db.add({'name': name, 'coefficient': coefficient, 'createdAt': FieldValue.serverTimestamp()});
  }

  Stream<List<Matiere>> getMatieres() {
    return _db.orderBy('name').snapshots().map((snap) =>
      snap.docs.map((d) => Matiere.fromMap(d.id, d.data() as Map<String, dynamic>)).toList()
    );
  }
}
