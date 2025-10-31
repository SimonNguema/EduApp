import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/classe_service.dart';
import '../../services/matiere_service.dart';
import '../../services/planning_service.dart';
import '../../models/classe_model.dart';
import '../../models/matiere_model.dart';
import '../../models/session_model.dart';

class AddPlanningScreen extends StatefulWidget {
  const AddPlanningScreen({super.key});
  @override State<AddPlanningScreen> createState() => _AddPlanningScreenState();
}

class _AddPlanningScreenState extends State<AddPlanningScreen> {
  final ClasseService _classeService = ClasseService();
  final MatiereService _matiereService = MatiereService();
  final PlanningService _planningService = PlanningService();

  DateTimeRange? _range;
  String? _selectedClasseId;
  List<Session> _sessions = [];
  List<Matiere> _matieres = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _matiereService.getMatieres().first.then((m) {
      setState(() => _matieres = m);
    });
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) setState(() => _range = picked);
  }

  // Util pour afficher TimePicker et retourner "HH:mm"
  Future<String?> _pickTime(TimeOfDay initial) async {
    final t = await showTimePicker(context: context, initialTime: initial);
    if (t == null) return null;
    final h = t.hour.toString().padLeft(2,'0');
    final m = t.minute.toString().padLeft(2,'0');
    return '$h:$m';
  }

  // Ajouter une session temporaire (par défaut sur le premier jour)
  void _addSession() {
    if (_range == null || _selectedClasseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sélectionner période et classe d'abord")));
      return;
    }
    final day = _range!.start;
    final dayName = DateFormat.EEEE().format(day); // ex: Monday -> "Lundi" selon locale
    final newSession = Session(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: day,
      dayName: dayName,
      matiereId: _matieres.isNotEmpty ? _matieres.first.id : '',
      matiereName: _matieres.isNotEmpty ? _matieres.first.name : '',
      startTime: '09:00',
      endTime: '10:00',
      coefficient: _matieres.isNotEmpty ? _matieres.first.coefficient : 0.0,
    );
    setState(() => _sessions.add(newSession));
  }

  // Sauvegarder planning + sessions
  Future<void> _saveAll() async {
    if (_range == null || _selectedClasseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Période ou classe manquante")));
      return;
    }
    setState(() => _loading = true);
    try {
      final planningId = await _planningService.createPlanning(
        classeId: _selectedClasseId!,
        startDate: _range!.start,
        endDate: _range!.end,
      );
      for (final s in _sessions) {
        await _planningService.addSession(planningId, s);
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Planning enregistré")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créer Planning")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            ListTile(
              title: Text(_range == null ? 'Sélectionner une période' : 'Période: ${DateFormat.yMMMd().format(_range!.start)} - ${DateFormat.yMMMd().format(_range!.end)}'),
              trailing: ElevatedButton(onPressed: _pickRange, child: const Text("Choisir")),
            ),
            const SizedBox(height: 8),
            StreamBuilder<List<Classe>>(
              stream: _classeService.getAllClasses(),
              builder: (c, snap) {
                final classes = snap.data ?? [];
                return DropdownButtonFormField<String>(
                  value: _selectedClasseId,
                  hint: const Text("Sélectionner une classe"),
                  items: classes.map((cl) => DropdownMenuItem(value: cl.id, child: Text(cl.name))).toList(),
                  onChanged: (v) => setState(() => _selectedClasseId = v),
                );
              }
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Sessions", style: TextStyle(fontWeight: FontWeight.bold)),
                ElevatedButton(onPressed: _addSession, child: const Text("Ajouter une session")),
              ],
            ),
            const SizedBox(height: 8),

            // Liste des sessions ajoutées (édition simple)
            ..._sessions.asMap().entries.map((entry) {
              final idx = entry.key;
              final s = entry.value;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("Session ${idx+1} - ${DateFormat.yMMMd().format(s.date)} (${s.dayName})", style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),

                    // Matiere dropdown
                    DropdownButtonFormField<String>(
                      value: s.matiereId.isEmpty ? null : s.matiereId,
                      items: _matieres.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))).toList(),
                      onChanged: (v) {
                        final m = _matieres.firstWhere((x) => x.id == v);
                        setState(() {
                          _sessions[idx] = Session(
                            id: s.id,
                            date: s.date,
                            dayName: s.dayName,
                            matiereId: m.id,
                            matiereName: m.name,
                            startTime: s.startTime,
                            endTime: s.endTime,
                            coefficient: m.coefficient,
                          );
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Matière'),
                    ),

                    const SizedBox(height: 8),

                    // Heure début / fin
                    Row(children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await _pickTime(TimeOfDay(hour: int.parse(s.startTime.split(':')[0]), minute: int.parse(s.startTime.split(':')[1])));
                            if (picked != null) {
                              setState(() {
                                _sessions[idx] = Session(
                                  id: s.id,
                                  date: s.date,
                                  dayName: s.dayName,
                                  matiereId: s.matiereId,
                                  matiereName: s.matiereName,
                                  startTime: picked,
                                  endTime: s.endTime,
                                  coefficient: s.coefficient,
                                );
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'Début'),
                            child: Text(s.startTime),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await _pickTime(TimeOfDay(hour: int.parse(s.endTime.split(':')[0]), minute: int.parse(s.endTime.split(':')[1])));
                            if (picked != null) {
                              setState(() {
                                _sessions[idx] = Session(
                                  id: s.id,
                                  date: s.date,
                                  dayName: s.dayName,
                                  matiereId: s.matiereId,
                                  matiereName: s.matiereName,
                                  startTime: s.startTime,
                                  endTime: picked,
                                  coefficient: s.coefficient,
                                );
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'Fin'),
                            child: Text(s.endTime),
                          ),
                        ),
                      ),
                    ]),

                    const SizedBox(height: 8),

                    // Supprimer session
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => setState(() => _sessions.removeAt(idx)),
                        child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ]),
                ),
              );
            }).toList(),

            const SizedBox(height: 20),
            _loading ? const CircularProgressIndicator() : ElevatedButton(onPressed: _saveAll, child: const Text('Enregistrer Planning')),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
