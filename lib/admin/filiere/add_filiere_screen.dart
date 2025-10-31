import 'package:flutter/material.dart';
import '../../services/filiere_service.dart';

class AddFiliereScreen extends StatefulWidget {
  const AddFiliereScreen({super.key});

  @override
  State<AddFiliereScreen> createState() => _AddFiliereScreenState();
}

class _AddFiliereScreenState extends State<AddFiliereScreen> {
  final TextEditingController _name = TextEditingController();
  final FiliereService _service = FiliereService();

  void _save() async {
    if (_name.text.trim().isEmpty) return;
    await _service.addFiliere(_name.text.trim());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter une filière")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nom de la filière')),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _save, child: const Text("Enregistrer"))
        ]),
      ),
    );
  }
}
