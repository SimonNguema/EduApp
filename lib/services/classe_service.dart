import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/classe_model.dart';

class ClasseService {
  final _db = FirebaseFirestore.instance.collection('classes');

  Future<void> addClasse(String name, String filiereId) async {
    await _db.add({'name': name, 'filiereId': filiereId, 'createdAt': DateTime.now().toUtc()});
  }

  Stream<List<Classe>> getClassesByFiliere(String filiereId) {
    return _db.where('filiereId', isEqualTo: filiereId).snapshots().map((snapshot) =>
      snapshot.docs.map((d) => Classe.fromMap(d.id, d.data())).toList()
    );
  }

  Stream<List<Classe>> getAllClasses() {
    return _db.snapshots().map((snapshot) =>
      snapshot.docs.map((d) => Classe.fromMap(d.id, d.data())).toList()
    );
  }
}
