import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
//import 'signup_screen.dart';
import '/admin/admin_dashboard.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    
    try {
      final user = await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      setState(() => _isLoading = false);

      if (user != null) {
        // Récupérer le profil utilisateur depuis Firestore
        final profile = await _authService.getProfile(user.uid);
        
        if (profile != null && profile.role == 'admin') {
          // Rediriger vers le dashboard admin
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (_) => const AdminDashboard())
          );
        } else {
          // Rediriger vers l'écran principal pour les utilisateurs normaux
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (_) => const HomeScreen())
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email ou mot de passe invalide"))
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de connexion: $e"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                
                // Logo et titre
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/eduapp.png',
                        width: 120,
                        height: 120,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'EduApp',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Votre plateforme éducative',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // Titre de connexion
                const Text(
                  'Connexion',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connectez-vous à votre compte',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 32),

                // Champ Email
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Adresse email",
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.email, color: Colors.deepPurple),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),

                const SizedBox(height: 20),

                // Champ Mot de passe
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Mot de passe",
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.lock, color: Colors.deepPurple),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Lien mot de passe oublié
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implémenter la récupération de mot de passe
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fonctionnalité à venir')),
                      );
                    },
                    child: const Text(
                      'Mot de passe oublié ?',
                      style: TextStyle(color: Colors.deepPurple),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Bouton de connexion
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            shadowColor: Colors.deepPurple.withOpacity(0.3),
                          ),
                          child: const Text(
                            "Se connecter",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),

                const SizedBox(height: 24),

                // Séparateur
                // Row(
                //   children: [
                //     Expanded(
                //       child: Divider(color: Colors.grey.shade300),
                //     ),
                //     Padding(
                //       padding: const EdgeInsets.symmetric(horizontal: 16),
                //       child: Text(
                //         'Ou',
                //         style: TextStyle(
                //           color: Colors.grey.shade600,
                //         ),
                //       ),
                //     ),
                //     Expanded(
                //       child: Divider(color: Colors.grey.shade300),
                //     ),
                //   ],
                // ),

                // const SizedBox(height: 24),

                // Bouton création de compte
                // Center(
                //   child: TextButton(
                //     onPressed: () => Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (_) => const SignupScreen()),
                //     ),
                //     child: RichText(
                //       text: const TextSpan(
                //         text: "Nouveau sur EduApp ? ",
                //         style: TextStyle(color: Colors.grey),
                //         children: [
                //           TextSpan(
                //             text: "Créer un compte",
                //             style: TextStyle(
                //               color: Colors.deepPurple,
                //               fontWeight: FontWeight.bold,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),

                const SizedBox(height: 40),

                // Footer
                const Center(
                  child: Text(
                    '© 2025 EduApp. Tous droits réservés.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}