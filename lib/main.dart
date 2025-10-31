import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Importation des écrans
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'admin/admin_dashboard.dart';
import 'admin/add_student_screen.dart';
import 'admin/student_list_screen.dart';
import 'pages/evenements_screen.dart';
import 'pages/devoirs_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduApp',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[100],
      ),

      // Déclaration des routes de l’application
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/admin': (context) => const AdminDashboard(),
        '/admin/add_student': (context) => const AddStudentScreen(),
        '/admin/students': (context) => const StudentListScreen(),
        '/evenements': (context) => const EvenementsScreen(),
        '/devoirs': (context) => const DevoirsScreen(), 
      },

      // Page d’accueil par défaut
      initialRoute: '/',
    );
  }
}
