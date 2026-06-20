import 'package:flutter/material.dart';
import '../widgets/responsive_container.dart';
import 'login_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Platef de Soutenance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // mes coleurs (Bleu et Gris)
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(
          0xFFF0F4F8,
        ), // Fond gris très clair
      ),
      home: const HomePage(),
    );
  }
}

const Color sudocolor = Color(0xFF90FF90); // Gris bleu clair

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ResponsivePageContainer(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icone ou Logo de l'application
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: sudocolor,
                    //color: Colors.blue.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school_outlined,
                    size: 80,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 24),

                // Titres de bienvenue
                const Text(
                  'Plateforme de Soutenance',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Veuillez sélectionner votre profil pour continuer',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 35),

                // ETUDIANT
                _buildRoleCard(
                  context: context,
                  title: 'Je suis Étudiant',
                  description:
                      'Accédez au programme, déposez votre rapport et suivez vos notes.',
                  icon: Icons.person_outline,
                  role: 'etudiant',
                ),
                const SizedBox(height: 20),

                // ADMINISTRATEUR
                _buildRoleCard(
                  context: context,
                  title: 'Je suis Administrateur',
                  description:
                      'Gérez les plannings, attribuez les jurys et validez les soutenances.',
                  icon: Icons.admin_panel_settings_outlined,
                  role: 'admin',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // SELECTEUR DE RÔLE ETUDIANT/ ADMIN
  Widget _buildRoleCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required String role,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Navigation vers la page d'authentification en passant le rôle choisi
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage(role: role)),
          );
        },

        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              // Icône du rôle en bleu gris
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF90FF90), // Gris bleu clair
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: const Color(0xFF334155)),
              ),
              const SizedBox(width: 20),

              // Textes explicatifs
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              // Petite flèche vers la droite
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// Écran d'authentification temporaire pour recevoir le rôle et tester la navigation
/*class AuthPage extends StatelessWidget {
  final String role;

  const AuthPage({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          role == 'admin' ? 'Connexion Administration' : 'Connexion Étudiant',
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'Formulaire de connexion pour le rôle : ${role.toUpperCase()}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}*/
