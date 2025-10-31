import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Création d'un compte étudiant (par un admin) ---
  Future<String?> createStudentAccount({
    required String email,
    required String password,
    required String? name,
    required String? phone,
  }) async {
    try {
      // Crée le compte Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User user = result.user!;

      // Crée le document utilisateur Firestore
      AppUser appUser = AppUser(
        uid: user.uid,
        name: name,
        email: email,
        phone: phone,
        role: 'student',
      );

      await _firestore.collection('users').doc(user.uid).set(appUser.toMap());
      return user.uid;
    } catch (e) {
      print("Erreur création compte étudiant: $e");
      return null;
    }
  }

  // --- Connexion d'un utilisateur existant ---
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result =
          await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      print("Erreur connexion: $e");
      return null;
    }
  }

  // --- Déconnexion ---
  Future<void> signOut() async => await _auth.signOut();

  // --- Suivi de l'état d'authentification ---
  Stream<User?> get user => _auth.authStateChanges();

  // --- ✅ Récupérer le profil utilisateur depuis Firestore ---
  Future<AppUser?> getProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.data()!);
      } else {
        return null;
      }
    } catch (e) {
      print("Erreur récupération profil: $e");
      return null;
    }
  }
}
