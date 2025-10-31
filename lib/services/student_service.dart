import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';

class StudentService {
  final CollectionReference _db = FirebaseFirestore.instance.collection('students');

  Future<void> addStudent({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String classeId,
    required String userId,
  }) async {
    await _db.add({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'classeId': classeId,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Student>> getStudents() {
    return _db.snapshots().map((snapshot) =>
        snapshot.docs.map((d) => Student.fromMap(d.id, d.data() as Map<String, dynamic>)).toList());
  }

  Future<void> deleteStudent(String id) async => await _db.doc(id).delete();
}
