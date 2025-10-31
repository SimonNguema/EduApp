import 'package:flutter/material.dart';
import '../../services/devoir_service.dart';
import '../../models/devoir_model.dart';
import 'devoir_details_screen.dart';

class DevoirsListScreen extends StatelessWidget {
  const DevoirsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final devoirService = DevoirService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des devoirs"),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<List<Devoir>>(
        stream: devoirService.getDevoirs(),
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
            return const Center(child: CircularProgressIndicator());
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
                    "Aucun devoir créé",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Les devoirs apparaîtront ici",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: devoirs.length,
            itemBuilder: (context, index) {
              final devoir = devoirs[index];
              return _buildDevoirCard(context, devoir);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDevoirScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDevoirCard(BuildContext context, Devoir devoir) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.assignment, color: Colors.deepPurple),
        title: Text(
          devoir.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Classe: ${devoir.classeName}'),
            Text('Matière: ${devoir.matiereName}'),
            Text('Date: ${_formatDate(devoir.dateDevoir)} à ${devoir.heureDevoir}'),
            if (devoir.duree.isNotEmpty) Text('Durée: ${devoir.duree}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DevoirDetailsScreen(devoir: devoir),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}