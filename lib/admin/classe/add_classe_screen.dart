import 'package:flutter/material.dart';
import '../../models/filiere_model.dart';
import '../../services/filiere_service.dart';
import '../../services/classe_service.dart';

class AddClasseScreen extends StatefulWidget {
  const AddClasseScreen({super.key});

  @override
  State<AddClasseScreen> createState() => _AddClasseScreenState();
}

class _AddClasseScreenState extends State<AddClasseScreen> {
  final TextEditingController _name = TextEditingController();
  final FiliereService _filiereService = FiliereService();
  final ClasseService _classeService = ClasseService();
  String? selectedFiliereId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter une classe")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          StreamBuilder<List<Filiere>>(
            stream: _filiereService.getFilieres(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final filieres = snapshot.data!;
              return DropdownButtonFormField<String>(
                value: selectedFiliereId,
                hint: const Text("Sélectionner une filière"),
                items: filieres.map((f) => DropdownMenuItem(
                  value: f.id,
                  child: Text(f.name),
                )).toList(),
                onChanged: (v) => setState(() => selectedFiliereId = v),
              );
            },
          ),
          const SizedBox(height: 16),
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nom de la classe')),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: selectedFiliereId == null ? null : () async {
              await _classeService.addClasse(_name.text.trim(), selectedFiliereId!);
              Navigator.pop(context);
            },
            child: const Text("Enregistrer"),
          )
        ]),
      ),
    );
  }
}
