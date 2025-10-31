import 'package:flutter/material.dart';
import '../models/planning_model.dart';
import '../services/planning_service.dart';
import 'planning_details_screen.dart';

class PlanningScreen extends StatefulWidget {
  final String classeId;

  const PlanningScreen({super.key, required this.classeId});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  final PlanningService _planningService = PlanningService();
  List<Planning> _allPlannings = [];
  List<Planning> _filteredPlannings = [];
  bool _isLoading = true;
  String? _error;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadPlannings();
  }

  Future<void> _loadPlannings() async {
    try {
      final plannings = await _planningService.getPlanningsForClasse(widget.classeId).first;
      setState(() {
        _allPlannings = plannings;
        _filteredPlannings = plannings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur de chargement: $e';
        _isLoading = false;
      });
    }
  }

  void _filterByDate(DateTime? date) {
    setState(() {
      _selectedDate = date;
      if (date == null) {
        _filteredPlannings = _allPlannings;
      } else {
        _filteredPlannings = _allPlannings.where((planning) {
          return planning.startDate.isBefore(date) && planning.endDate.isAfter(date) ||
                 _isSameDay(planning.startDate, date) ||
                 _isSameDay(planning.endDate, date);
        }).toList();
      }
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Planning des cours"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filtrer par date',
          ),
          if (_selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => _filterByDate(null),
              tooltip: 'Effacer le filtre',
            ),
        ],
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
            Text('Chargement de votre planning...'),
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
              onPressed: _loadPlannings,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_filteredPlannings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _selectedDate == null 
                  ? "Aucun planning disponible"
                  : "Aucun planning pour cette date",
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedDate == null
                  ? "Vos plannings apparaîtront ici"
                  : "Aucun planning ne couvre cette date",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredPlannings.length,
      itemBuilder: (context, index) {
        final planning = _filteredPlannings[index];
        return _buildPlanningCard(context, planning);
      },
    );
  }

  Widget _buildPlanningCard(BuildContext context, Planning planning) {
    final isCurrent = _isCurrentPlanning(planning);
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isCurrent ? Colors.deepPurple.shade50 : null,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlanningDetailsScreen(planning: planning),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec badge si planning actuel
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Planning du ${_formatDate(planning.startDate)} au ${_formatDate(planning.endDate)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Actuel',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // Période
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${_formatDate(planning.startDate)} - ${_formatDate(planning.endDate)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Statut
              Row(
                children: [
                  const Icon(Icons.info, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    _getPlanningStatus(planning),
                    style: TextStyle(
                      color: _getStatusColor(planning),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Indicateur "Voir détails"
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Voir le planning",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: Colors.deepPurple,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isCurrentPlanning(Planning planning) {
    final now = DateTime.now();
    return planning.startDate.isBefore(now) && planning.endDate.isAfter(now);
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

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrer par date'),
        content: SizedBox(
          height: 300,
          child: CalendarDatePicker(
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            onDateChanged: (date) {
              Navigator.pop(context);
              _filterByDate(date);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }
}