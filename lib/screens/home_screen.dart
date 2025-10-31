import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/pages/planning_screen.dart';
import '/pages/notes_screen.dart';
import '/pages/evenements_screen.dart';
import '/pages/devoirs_screen.dart';
import '/pages/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Map<String, dynamic>> services = const [
    {"title": "Planning", "icon": Icons.schedule, "route": "/planning", "color": Colors.blue},
    {"title": "Mes Notes", "icon": Icons.grade, "route": "/notes", "color": Colors.green},
    {"title": "Devoirs", "icon": Icons.assignment, "route": "/devoirs", "color": Colors.orange},
    {"title": "Événements", "icon": Icons.event, "route": "/evenements", "color": Colors.purple},
    {"title": "Mes Absences", "icon": Icons.person_off, "route": "/absences", "color": Colors.red},
    {"title": "Évaluations", "icon": Icons.rate_review, "route": "/evaluations", "color": Colors.teal},
    {"title": "Paiements", "icon": Icons.payment, "route": "/paiements", "color": Colors.indigo},
    {"title": "Ressources", "icon": Icons.folder, "route": "/ressources", "color": Colors.brown},
  ];

  Future<String?> getStudentClasseId(String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection('students')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (doc.docs.isNotEmpty) {
      return doc.docs.first['classeId'] as String?;
    }
    return null;
  }

  void _navigateToScreen(BuildContext context, String route) async {
    final user = FirebaseAuth.instance.currentUser;
    
    switch (route) {
      case "/planning":
        if (user != null) {
          final classeId = await getStudentClasseId(user.uid);
          if (classeId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PlanningScreen(classeId: classeId),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Classe de l'étudiant introuvable")),
            );
          }
        }
        break;
      
      case "/devoirs":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DevoirsScreen()),
        );
        break;
      
      case "/notes":
        Navigator.pushNamed(context, route);
        break;
      
      case "/evenements":
        Navigator.pushNamed(context, route);
        break;
      
      default:
        // Pour les autres services non implémentés
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$route - Fonctionnalité à venir'),
            backgroundColor: Colors.blue,
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'Étudiant';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "EduApp",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  user?.photoURL ?? 
                  'https://ui-avatars.com/api/?name=${user?.displayName ?? 'U'}&background=7E57C2&color=fff'
                ),
                radius: 20,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête de bienvenue
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour,',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bienvenue sur votre espace étudiant',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section des services
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Services',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Accédez à toutes vos fonctionnalités',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Grille des services
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: services.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  final service = services[index];
                  return _buildServiceCard(context, service);
                },
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, Map<String, dynamic> service) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              service['color'].withOpacity(0.1),
              service['color'].withOpacity(0.05),
            ],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _navigateToScreen(context, service['route']),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: service['color'].withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      service['icon'],
                      size: 28,
                      color: service['color'],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    service['title'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}