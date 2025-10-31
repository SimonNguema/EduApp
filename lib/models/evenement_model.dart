import 'package:cloud_firestore/cloud_firestore.dart';

class Evenement {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime createdAt;

  // ✅ URL d'image statique définie directement dans le modèle
  static const String staticImageUrl = 
      'https://images.unsplash.com/photo-1540575467063-178a50c2df87?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80';

  Evenement({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.createdAt,
  });

  // Constructeur pour créer un nouvel événement avec image statique
  Evenement.create({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  }) : imageUrl = staticImageUrl;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Evenement.fromMap(String id, Map<String, dynamic> data) {
    return Evenement(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? staticImageUrl, //  Utilise staticImageUrl du modèle
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  @override
  String toString() {
    return 'Evenement{id: $id, title: $title, createdAt: $createdAt}';
  }
}