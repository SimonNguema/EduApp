import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/filiere_model.dart';

class FiliereService {
  final _db = FirebaseFirestore.instance.collection('filieres');

  Future<void> addFiliere(String name) async {
    await _db.add({'name': name, 'createdAt': DateTime.now().toUtc()});
  }

  Stream<List<Filiere>> getFilieres() {
    return _db.snapshots().map((snapshot) =>
      snapshot.docs.map((d) => Filiere.fromMap(d.id, d.data())).toList()
    );
  }
}
