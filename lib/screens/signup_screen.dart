// import 'package:flutter/material.dart';
// import '../services/auth_service.dart';
// import 'login_screen.dart';
// import 'home_screen.dart';

// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});

//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final AuthService _authService = AuthService();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isLoading = false;

//   Future<void> _signup() async {
//     setState(() => _isLoading = true);
//     final user = await _authService.signUp(
//       _emailController.text.trim(),
//       _passwordController.text.trim(),
//     );
//     setState(() => _isLoading = false);

//     if (user != null) {
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (_) => const HomeScreen()));
//     } else {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("Erreur lors de l'inscription")));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Créer un compte")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
//             const SizedBox(height: 10),
//             TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: "Mot de passe")),
//             const SizedBox(height: 20),
//             _isLoading
//                 ? const CircularProgressIndicator()
//                 : ElevatedButton(onPressed: _signup, child: const Text("S'inscrire")),
//             TextButton(
//               onPressed: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const LoginScreen()),
//               ),
//               child: const Text("Déjà un compte ? Se connecter"),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
