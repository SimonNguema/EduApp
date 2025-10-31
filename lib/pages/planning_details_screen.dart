import 'package:flutter/material.dart';
import '../models/planning_model.dart';
import '../models/session_model.dart';
import '../services/planning_service.dart';

class PlanningDetailsScreen extends StatefulWidget {
  final Planning planning;

  const PlanningDetailsScreen({super.key, required this.planning});

  @override
  State<PlanningDetailsScreen> createState() => _PlanningDetailsScreenState();
}

class _PlanningDetailsScreenState extends State<PlanningDetailsScreen> {
  final PlanningService _planningService = PlanningService();
  List<Session> _sessions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    try {
      final planningWithSessions = await _planningService.getPlanningWithSessions(widget.planning.id);
      setState(() {
        _sessions = planningWithSessions.sessions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur de chargement des sessions: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails du planning"),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _error != null
            ? Center(child: Text(_error!))
            : _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête du planning
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Planning du ${_formatDate(widget.planning.startDate)} au ${_formatDate(widget.planning.endDate)}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Période : ${_formatDate(widget.planning.startDate)} → ${_formatDate(widget.planning.endDate)}",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Statut : ${_getPlanningStatus(widget.planning)}",
                    style: TextStyle(
                      fontSize: 14,
                      color: _getStatusColor(widget.planning),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Section des sessions
          const Text(
            "Emploi du temps",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          _sessions.isEmpty
              ? _buildEmptyState()
              : _buildSessionsList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          const Icon(Icons.schedule, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "Aucun cours planifié pour cette période",
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Vérifiez plus tard ou contactez l'administration",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsList() {
    // Grouper les sessions par date
    final sessionsByDate = <DateTime, List<Session>>{};
    for (final session in _sessions) {
      final date = DateTime(session.date.year, session.date.month, session.date.day);
      if (!sessionsByDate.containsKey(date)) {
        sessionsByDate[date] = [];
      }
      sessionsByDate[date]!.add(session);
    }

    // Trier les dates
    final sortedDates = sessionsByDate.keys.toList()..sort();

    return Column(
      children: sortedDates.map((date) {
        final daySessions = sessionsByDate[date]!;
        // Trier les sessions par heure de début
        daySessions.sort((a, b) => a.startTime.compareTo(b.startTime));
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête de date
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20, color: Colors.deepPurple),
                  const SizedBox(width: 8),
                  Text(
                    _formatDayHeader(date),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Sessions de la journée
            ...daySessions.map((session) => _buildSessionCard(session)).toList(),
            
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSessionCard(Session session) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Horaires
            Container(
              width: 80,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: [
                  Text(
                    session.startTime,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const Text(
                    'à',
                    style: TextStyle(fontSize: 10, color: Colors.deepPurple),
                  ),
                  Text(
                    session.endTime,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Détails de la session
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.matiereName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  if (session.teacher != null && session.teacher!.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.person, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          session.teacher!,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  
                  if (session.room != null && session.room!.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.place, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          session.room!,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 4),
                  
                  Row(
                    children: [
                      const Icon(Icons.school, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Coefficient: ${session.coefficient}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }

  String _formatDayHeader(DateTime date) {
    final today = DateTime.now();
    final dateOnly = DateTime(date.year, date.month, date.day);
    final todayOnly = DateTime(today.year, today.month, today.day);

    final days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    final dayName = days[date.weekday - 1];

    if (dateOnly == todayOnly) {
      return "Aujourd'hui - $dayName ${_formatDate(date)}";
    } else {
      return "$dayName ${_formatDate(date)}";
    }
  }

  String _getPlanningStatus(Planning planning) {
    final now = DateTime.now();
    if (planning.startDate.isAfter(now)) {
      return 'À venir';
    } else if (planning.endDate.isBefore(now)) {
      return 'Terminé';
    } else {
      return 'En cours';
    }
  }

  Color _getStatusColor(Planning planning) {
    final now = DateTime.now();
    if (planning.startDate.isAfter(now)) {
      return Colors.orange;
    } else if (planning.endDate.isBefore(now)) {
      return Colors.grey;
    } else {
      return Colors.green;
    }
  }
}