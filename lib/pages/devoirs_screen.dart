import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/devoir_service.dart';
import '../../models/devoir_model.dart';
import 'devoir_details_etudiant_screen.dart';

class DevoirsScreen extends StatefulWidget {
  const DevoirsScreen({super.key});

  @override
  State<DevoirsScreen> createState() => _DevoirsScreenState();
}

class _DevoirsScreenState extends State<DevoirsScreen> {
  final DevoirService _devoirService = DevoirService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _classeId;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStudentClasse();
  }

  Future<void> _loadStudentClasse() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _error = "Utilisateur non connecté";
          _isLoading = false;
        });
        return;
      }

      final studentDoc = await _firestore
          .collection('students')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (studentDoc.docs.isEmpty) {
        setState(() {
          _error = "Profil étudiant non trouvé";
          _isLoading = false;
        });
        return;
      }

      final studentData = studentDoc.docs.first.data();
      final classeId = studentData['classeId'] as String?;

      if (classeId == null) {
        setState(() {
          _error = "Classe non assignée";
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _classeId = classeId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Erreur de chargement: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes devoirs"),
        backgroundColor: Colors.deepPurple,
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement de vos devoirs...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadStudentClasse,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_classeId == null) {
      return const Center(
        child: Text('Aucune classe assignée'),
      );
    }

    return StreamBuilder<List<Devoir>>(
      stream: _devoirService.getDevoirsByClasse(_classeId!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Erreur: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Chargement des devoirs...'),
              ],
            ),
          );
        }

        final devoirs = snapshot.data!;

        if (devoirs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.assignment, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  "Aucun devoir pour le moment",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  "Les devoirs de votre classe apparaîtront ici",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return _buildDevoirsList(devoirs);
      },
    );
  }

  Widget _buildDevoirsList(List<Devoir> devoirs) {
    // Séparer les devoirs par statut (à venir, aujourd'hui, passé)
    final now = DateTime.now();
    final aujourdhui = DateTime(now.year, now.month, now.day);

    final devoirsAvenir = devoirs.where((d) {
      final dateDevoir = DateTime(d.dateDevoir.year, d.dateDevoir.month, d.dateDevoir.day);
      return dateDevoir.isAfter(aujourdhui);
    }).toList();

    final devoirsAujourdhui = devoirs.where((d) {
      final dateDevoir = DateTime(d.dateDevoir.year, d.dateDevoir.month, d.dateDevoir.day);
      return dateDevoir.isAtSameMomentAs(aujourdhui);
    }).toList();

    final devoirsPasses = devoirs.where((d) {
      final dateDevoir = DateTime(d.dateDevoir.year, d.dateDevoir.month, d.dateDevoir.day);
      return dateDevoir.isBefore(aujourdhui);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (devoirsAujourdhui.isNotEmpty) ...[
          _buildSectionHeader("Aujourd'hui", Colors.orange),
          ...devoirsAujourdhui.map((d) => _buildDevoirCard(d, Colors.orange.shade50)),
          const SizedBox(height: 20),
        ],
        
        if (devoirsAvenir.isNotEmpty) ...[
          _buildSectionHeader("À venir", Colors.green),
          ...devoirsAvenir.map((d) => _buildDevoirCard(d, Colors.green.shade50)),
          const SizedBox(height: 20),
        ],
        
        if (devoirsPasses.isNotEmpty) ...[
          _buildSectionHeader("Passés", Colors.grey),
          ...devoirsPasses.map((d) => _buildDevoirCard(d, Colors.grey.shade100)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            color: color,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevoirCard(Devoir devoir, Color backgroundColor) {
    final isToday = _isToday(devoir.dateDevoir);
    final isPast = _isPast(devoir.dateDevoir);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: backgroundColor,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            Icons.assignment,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          devoir.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            decoration: isPast ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Matière: ${devoir.matiereName}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              'Date: ${_formatDate(devoir.dateDevoir)} à ${devoir.heureDevoir}',
              style: TextStyle(
                fontSize: 13,
                color: isToday ? Colors.orange : Colors.grey,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (devoir.duree.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                'Durée: ${devoir.duree}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade600,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DevoirDetailsEtudiantScreen(devoir: devoir),
            ),
          );
        },
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isPast(DateTime date) {
    final now = DateTime.now();
    final dateOnly = DateTime(date.year, date.month, date.day);
    final nowOnly = DateTime(now.year, now.month, now.day);
    return dateOnly.isBefore(nowOnly);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return "Aujourd'hui";
    } else if (dateOnly == today.add(const Duration(days: 1))) {
      return "Demain";
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return "Hier";
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }
}