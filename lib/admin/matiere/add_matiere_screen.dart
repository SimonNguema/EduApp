import 'package:flutter/material.dart';
import '../../services/matiere_service.dart';

class AddMatiereScreen extends StatefulWidget {
  const AddMatiereScreen({super.key});
  @override State<AddMatiereScreen> createState() => _AddMatiereScreenState();
}

class _AddMatiereScreenState extends State<AddMatiereScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _coef = TextEditingController();
  final MatiereService _service = MatiereService();
  bool _loading = false;

  void _save() async {
    final name = _name.text.trim();
    final coef = double.tryParse(_coef.text.trim()) ?? 0.0;
    if (name.isEmpty) return;
    setState(() => _loading = true);
    await _service.addMatiere(name, coef);
    setState(() => _loading = false);
    Navigator.pop(context);
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter Matière")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nom')),
          TextField(controller: _coef, decoration: const InputDecoration(labelText: 'Coefficient'), keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          _loading ? const CircularProgressIndicator() : ElevatedButton(onPressed: _save, child: const Text('Enregistrer'))
        ]),
      ),
    );
  }
}
