import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/devoir_model.dart';

class DevoirDetailsScreen extends StatelessWidget {
  final Devoir devoir;

  const DevoirDetailsScreen({super.key, required this.devoir});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails du devoir"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            Text(
              devoir.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),

            const SizedBox(height: 20),

            // Informations générales
            _buildInfoCard(),

            const SizedBox(height: 20),

            // Description
            const Text(
              "Description",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                devoir.description,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow('Classe', devoir.classeName),
            _buildInfoRow('Matière', devoir.matiereName),
            _buildInfoRow('Date', DateFormat('dd/MM/yyyy').format(devoir.dateDevoir)),
            _buildInfoRow('Heure', devoir.heureDevoir),
            if (devoir.duree.isNotEmpty) _buildInfoRow('Durée estimée', devoir.duree),
            _buildInfoRow('Créé le', DateFormat('dd/MM/yyyy à HH:mm').format(devoir.createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}