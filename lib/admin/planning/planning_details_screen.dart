import 'package:flutter/material.dart';
import '../../services/planning_service.dart';
import '../../models/planning_model.dart';
import '../../models/session_model.dart';

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
        _error = 'Erreur de chargement: $e';
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
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Section des sessions
          const Text(
            "Cours planifiés",
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
            "Les sessions ajoutées apparaîtront ici",
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête de date
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(width: 12),
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
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    session.matiereName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Coeff: ${session.coefficient}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  '${session.startTime} - ${session.endTime}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
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

    if (dateOnly == todayOnly) {
      return "Aujourd'hui - ${_formatDate(date)}";
    } else {
      return _formatDate(date);
    }
  }
}