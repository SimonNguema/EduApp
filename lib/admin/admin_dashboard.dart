import 'package:flutter/material.dart';
import '../models/filiere_model.dart';
import '../models/classe_model.dart';
import '../models/student_model.dart';
import '../models/matiere_model.dart';
import '../models/planning_model.dart';
import '../services/filiere_service.dart';
import '../services/classe_service.dart';
import '../services/student_service.dart';
import '../services/matiere_service.dart';
import '../services/planning_service.dart';

import '../models/evenement_model.dart';
import '../services/evenement_service.dart';
import '../admin/evenement/add_evenement_screen.dart';
import '../admin/evenement/evenement_details_screen.dart';


// Écrans d’ajout
import '../admin/filiere/add_filiere_screen.dart';
import '../admin/classe/add_classe_screen.dart';
import '../admin/add_student_screen.dart';
import '../admin/matiere/add_matiere_screen.dart';
import '../admin/planning/add_planning_screen.dart';
import '../admin/planning/planning_details_screen.dart';
import '../services/devoir_service.dart';
import '../models/devoir_model.dart';
import '../admin/devoir/devoir_details_screen.dart';
import '../admin/devoir/add_devoir_screen.dart';




class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Services
  final FiliereService _filiereService = FiliereService();
  final ClasseService _classeService = ClasseService();
  final StudentService _studentService = StudentService();
  final MatiereService _matiereService = MatiereService();
  final PlanningService _planningService = PlanningService();
  final EvenementService _evenementService = EvenementService();
  final DevoirService _devoirService = DevoirService();


  final Map<String, String> _filiereNames = {};
  final Map<String, String> _classeNames = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _loadFiliereNames();
    _loadClasseNames();
  }

  Future<void> _loadFiliereNames() async {
    final filieres = await _filiereService.getFilieres().first;
    setState(() {
      for (var f in filieres) {
        _filiereNames[f.id] = f.name;
      }
    });
  }

  Future<void> _loadClasseNames() async {
    final classes = await _classeService.getAllClasses().first;
    setState(() {
      for (var c in classes) {
        _classeNames[c.id] = c.name;
      }
    });
  }

  void _navigateToAdd(BuildContext context) {
    switch (_tabController.index) {
      case 0:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddFiliereScreen()));
        break;
      case 1:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddClasseScreen()));
        break;
      case 2:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddStudentScreen()));
        break;
      case 3:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddMatiereScreen()));
        break;
      case 4:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddPlanningScreen()));
        break;
      case 5:
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AddEvenementScreen()));
        break;
      case 6:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddDevoirScreen()));
        break;
        
    }
  }

  Widget _buildCountHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        "$title ($count)",
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tableau de bord Admin"),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.school), text: "Filières"),
            Tab(icon: Icon(Icons.class_), text: "Classes"),
            Tab(icon: Icon(Icons.people), text: "Étudiants"),
            Tab(icon: Icon(Icons.menu_book), text: "Matières"),
            Tab(icon: Icon(Icons.calendar_month), text: "Plannings"),
            Tab(icon: Icon(Icons.event), text: "Événements"),
            Tab(icon: Icon(Icons.assignment), text: "Devoirs"),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () => _navigateToAdd(context),
        child: const Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // --- ONGLET FILIÈRES ---
          StreamBuilder<List<Filiere>>(
            stream: _filiereService.getFilieres(),
            builder: (context, snapshot) {
              final filieres = snapshot.data ?? [];
              if (filieres.isEmpty) {
                return const Center(child: Text("Aucune filière trouvée"));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCountHeader("Filières", filieres.length),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filieres.length,
                      itemBuilder: (context, index) {
                        final f = filieres[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: ListTile(
                            leading:
                                const Icon(Icons.school, color: Colors.deepPurple),
                            title: Text(f.name),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),

          // --- ONGLET CLASSES ---
          StreamBuilder<List<Classe>>(
            stream: _classeService.getAllClasses(),
            builder: (context, snapshot) {
              final classes = snapshot.data ?? [];
              if (classes.isEmpty) {
                return const Center(child: Text("Aucune classe trouvée"));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCountHeader("Classes", classes.length),
                  Expanded(
                    child: ListView.builder(
                      itemCount: classes.length,
                      itemBuilder: (context, index) {
                        final c = classes[index];
                        final filiereName =
                            _filiereNames[c.filiereId] ?? "Filière inconnue";
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: ListTile(
                            leading:
                                const Icon(Icons.class_, color: Colors.deepPurple),
                            title: Text(c.name),
                            subtitle: Text("Filière : $filiereName"),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),

          // --- ONGLET ÉTUDIANTS ---
          StreamBuilder<List<Student>>(
            stream: _studentService.getStudents(),
            builder: (context, snapshot) {
              final students = snapshot.data ?? [];
              if (students.isEmpty) {
                return const Center(child: Text("Aucun étudiant trouvé"));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCountHeader("Étudiants", students.length),
                  Expanded(
                    child: ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final s = students[index];
                        final classeName =
                            _classeNames[s.classeId] ?? "Classe inconnue";
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: ListTile(
                            leading:
                                const Icon(Icons.person, color: Colors.deepPurple),
                            title: Text("${s.firstName} ${s.lastName}"),
                            subtitle:
                                Text("${s.email}\nClasse : $classeName"),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),

          // --- ONGLET MATIÈRES ---
          StreamBuilder<List<Matiere>>(
            stream: _matiereService.getMatieres(),
            builder: (context, snapshot) {
              final matieres = snapshot.data ?? [];
              if (matieres.isEmpty) {
                return const Center(child: Text("Aucune matière trouvée"));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCountHeader("Matières", matieres.length),
                  Expanded(
                    child: ListView.builder(
                      itemCount: matieres.length,
                      itemBuilder: (context, index) {
                        final m = matieres[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: ListTile(
                            leading: const Icon(Icons.menu_book,
                                color: Colors.deepPurple),
                            title: Text(m.name),
                            subtitle: Text("Coefficient : ${m.coefficient}"),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),

          // --- ONGLET PLANNINGS ---
StreamBuilder<List<Planning>>(
  stream: _planningService.getPlannings(),
  builder: (context, snapshot) {
    final plannings = snapshot.data ?? [];
    if (plannings.isEmpty) {
      return const Center(child: Text("Aucun planning trouvé"));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCountHeader("Plannings", plannings.length),
        Expanded(
          child: ListView.builder(
            itemCount: plannings.length,
            itemBuilder: (context, index) {
              final p = plannings[index];
              final classeName = _classeNames[p.classeId] ?? "Classe inconnue";
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.calendar_month, color: Colors.deepPurple),
                  title: Text("Planning du ${p.startDate.toLocal().toString().split(' ')[0]} au ${p.endDate.toLocal().toString().split(' ')[0]}"),
                  subtitle: Text("Classe : $classeName"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlanningDetailsScreen(planning: p),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  },
),

// --- ONGLET ÉVÉNEMENTS ---
StreamBuilder<List<Evenement>>(
  stream: _evenementService.getEvenements(),
  builder: (context, snapshot) {
    if (snapshot.hasError) {
      return Center(
        child: Text(
          'Erreur de chargement: ${snapshot.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final evenements = snapshot.data!;
    if (evenements.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Aucun événement trouvé",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCountHeader("Événements", evenements.length),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: evenements.length,
            itemBuilder: (context, index) {
              final e = evenements[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 2,
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      e.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 50,
                        height: 50,
                        color: Colors.deepPurple,
                        child: const Icon(Icons.event, color: Colors.white),
                      ),
                    ),
                  ),
                  title: Text(
                    e.title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    "Créé le ${e.createdAt.toLocal().toString().split(' ')[0]}",
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EvenementDetailsScreen(evenement: e),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  },
),

StreamBuilder<List<Devoir>>(
  stream: _devoirService.getDevoirs(),
  builder: (context, snapshot) {
    final devoirs = snapshot.data ?? [];
    if (devoirs.isEmpty) {
      return const Center(child: Text("Aucun devoir trouvé"));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCountHeader("Devoirs", devoirs.length),
        Expanded(
          child: ListView.builder(
            itemCount: devoirs.length,
            itemBuilder: (context, index) {
              final d = devoirs[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.assignment, color: Colors.deepPurple),
                  title: Text(d.title),
                  subtitle: Text("${d.classeName} - ${d.matiereName}"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DevoirDetailsScreen(devoir: d),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  },
),

        ],
      ),
    );
  }
}
