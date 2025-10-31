import 'package:flutter/material.dart';
import '../models/classe_model.dart';
import '../services/auth_service.dart';
import '../services/classe_service.dart';
import '../services/student_service.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final StudentService _studentService = StudentService();
  final ClasseService _classeService = ClasseService();
  final AuthService _authService = AuthService();

  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();

  String? selectedClasseId;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || selectedClasseId == null) return;
    setState(() => _isLoading = true);

    try {
      // 1️⃣ Crée un compte utilisateur étudiant
      final userId = await _authService.createStudentAccount(
        email: _email.text.trim(),
        password: "passer123",
        name: "${_firstName.text} ${_lastName.text}",
        phone: _phone.text,
      );

      if (userId == null) throw Exception("Échec de création du compte utilisateur.");

      // 2️⃣ Ajoute l'étudiant dans la collection students
      await _studentService.addStudent(
        firstName: _firstName.text,
        lastName: _lastName.text,
        email: _email.text,
        phone: _phone.text,
        classeId: selectedClasseId!,
        userId: userId,
      );

      // 3️⃣ Retour à la page précédente
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Étudiant ajouté avec succès !")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter un étudiant")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _firstName, decoration: const InputDecoration(labelText: 'Prénom'), validator: (v) => v!.isEmpty ? 'Requis' : null),
              TextFormField(controller: _lastName, decoration: const InputDecoration(labelText: 'Nom'), validator: (v) => v!.isEmpty ? 'Requis' : null),
              TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email'), validator: (v) => v!.isEmpty ? 'Requis' : null),
              TextFormField(controller: _phone, decoration: const InputDecoration(labelText: 'Téléphone')),

              const SizedBox(height: 16),
              StreamBuilder<List<Classe>>(
                stream: _classeService.getAllClasses(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  final classes = snapshot.data!;
                  return DropdownButtonFormField<String>(
                    value: selectedClasseId,
                    hint: const Text("Sélectionner une classe"),
                    items: classes.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name),
                    )).toList(),
                    onChanged: (v) => setState(() => selectedClasseId = v),
                  );
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Ajouter'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
