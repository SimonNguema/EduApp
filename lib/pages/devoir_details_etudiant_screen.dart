import 'package:flutter/material.dart';
import '../../models/devoir_model.dart';

class DevoirDetailsEtudiantScreen extends StatelessWidget {
  final Devoir devoir;

  const DevoirDetailsEtudiantScreen({super.key, required this.devoir});

  @override
  Widget build(BuildContext context) {
    final isPast = _isPast(devoir.dateDevoir);
    final isToday = _isToday(devoir.dateDevoir);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: Colors.deepPurple,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                devoir.matiereName,
                style: const TextStyle(fontSize: 16),
              ),
              background: Container(
                color: Colors.deepPurple,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête avec statut
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getStatusColor(isToday, isPast).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(isToday, isPast),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.assignment,
                          color: _getStatusColor(isToday, isPast),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getStatusText(isToday, isPast),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(isToday, isPast),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_formatDate(devoir.dateDevoir)} à ${devoir.heureDevoir}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

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

                  // Informations détaillées
                  _buildInfoSection(),

                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    "Description du devoir",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

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
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow('Matière', devoir.matiereName, Icons.menu_book),
            _buildInfoRow('Classe', devoir.classeName, Icons.class_),
            _buildInfoRow('Date du devoir', _formatSimpleDate(devoir.dateDevoir), Icons.calendar_today),
            _buildInfoRow('Heure', devoir.heureDevoir, Icons.access_time),
            if (devoir.duree.isNotEmpty) 
              _buildInfoRow('Durée estimée', devoir.duree, Icons.timer),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.deepPurple),
          const SizedBox(width: 12),
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
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(bool isToday, bool isPast) {
    if (isPast) return Colors.grey;
    if (isToday) return Colors.orange;
    return Colors.green;
  }

  String _getStatusText(bool isToday, bool isPast) {
    if (isPast) return "Devoir passé";
    if (isToday) return "À rendre aujourd'hui";
    return "Devoir à venir";
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

    if (dateOnly == today) return "Aujourd'hui";
    if (dateOnly == today.add(const Duration(days: 1))) return "Demain";
    return _formatSimpleDate(date);
  }

  String _formatSimpleDate(DateTime date) {
    // Format simple sans utiliser intl
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }
}