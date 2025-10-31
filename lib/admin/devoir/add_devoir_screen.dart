import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/devoir_service.dart';
import '../../services/classe_service.dart';
import '../../services/matiere_service.dart';
import '../../models/classe_model.dart';
import '../../models/matiere_model.dart';

class AddDevoirScreen extends StatefulWidget {
  const AddDevoirScreen({super.key});

  @override
  State<AddDevoirScreen> createState() => _AddDevoirScreenState();
}

class _AddDevoirScreenState extends State<AddDevoirScreen> {
  final _formKey = GlobalKey<FormState>();
  final _devoirService = DevoirService();
  final _classeService = ClasseService();
  final _matiereService = MatiereService();

  // Contrôleurs
  String? _selectedClasseId;
  String? _selectedMatiereId;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dureeController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  List<Classe> _classes = [];
  List<Matiere> _matieres = [];

  @override
  void initState() {
    super.initState();
    _loadClasses();
    _loadMatieres();
  }

  Future<void> _loadClasses() async {
    try {
      final classes = await _classeService.getAllClasses().first;
      setState(() => _classes = classes);
    } catch (e) {
      _showError('Erreur chargement classes: $e');
    }
  }

  Future<void> _loadMatieres() async {
    try {
      final matieres = await _matiereService.getMatieres().first;
      setState(() => _matieres = matieres);
    } catch (e) {
      _showError('Erreur chargement matières: $e');
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedClasseId == null) {
      _showError('Veuillez sélectionner une classe');
      return;
    }

    if (_selectedMatiereId == null) {
      _showError('Veuillez sélectionner une matière');
      return;
    }

    if (_selectedDate == null) {
      _showError('Veuillez sélectionner une date');
      return;
    }

    if (_selectedTime == null) {
      _showError('Veuillez sélectionner une heure');
      return;
    }

    final selectedClasse = _classes.firstWhere((c) => c.id == _selectedClasseId);
    final selectedMatiere = _matieres.firstWhere((m) => m.id == _selectedMatiereId);

    setState(() => _isLoading = true);

    try {
      await _devoirService.addDevoir(
        title: _titleController.text,
        description: _descriptionController.text,
        classeId: _selectedClasseId!,
        classeName: selectedClasse.name,
        matiereId: _selectedMatiereId!,
        matiereName: selectedMatiere.name,
        dateDevoir: _selectedDate!,
        heureDevoir: _formatTime(_selectedTime!),
        duree: _dureeController.text,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Devoir créé avec succès')),
        );
      }
    } catch (e) {
      _showError('Erreur création devoir: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter un devoir"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Sélection de la classe
              DropdownButtonFormField<String>(
                value: _selectedClasseId,
                decoration: const InputDecoration(
                  labelText: 'Classe concernée *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.class_),
                ),
                items: _classes.map((classe) {
                  return DropdownMenuItem(
                    value: classe.id,
                    child: Text(classe.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedClasseId = value);
                },
                validator: (value) {
                  if (value == null) return 'Sélectionnez une classe';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Sélection de la matière
              DropdownButtonFormField<String>(
                value: _selectedMatiereId,
                decoration: const InputDecoration(
                  labelText: 'Matière concernée *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.menu_book),
                ),
                items: _matieres.map((matiere) {
                  return DropdownMenuItem(
                    value: matiere.id,
                    child: Text('${matiere.name} (coeff: ${matiere.coefficient})'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedMatiereId = value);
                },
                validator: (value) {
                  if (value == null) return 'Sélectionnez une matière';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Titre du devoir
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre du devoir *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le titre est obligatoire';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La description est obligatoire';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Date et heure
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date du devoir *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _selectedDate == null
                              ? 'Sélectionner une date'
                              : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Heure *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(
                          _selectedTime == null
                              ? 'Sélectionner une heure'
                              : _formatTime(_selectedTime!),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Durée
              TextFormField(
                controller: _dureeController,
                decoration: const InputDecoration(
                  labelText: 'Durée estimée',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                  hintText: 'Ex: 2 heures, 30 minutes',
                ),
              ),

              const SizedBox(height: 32),

              // Bouton de soumission
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _isLoading ? "Création..." : "Créer le devoir",
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dureeController.dispose();
    super.dispose();
  }
}