import 'package:flutter/material.dart';
import 'package:vivatrack/pagesFolder/login_page.dart';
import 'firebase_auth.dart';
import 'student_page.dart';
import 'admin_page.dart';

class RedirectPage extends StatelessWidget {
  final String role;

  const RedirectPage({super.key, this.role = 'student'});

  @override
  Widget build(BuildContext context) {
    // Si un token/local email existe, on considère l'utilisateur connecté
    final isAuthenticated =
        SudoAuthService().token != null ||
        SudoAuthService().currentEmail != null;

    if (isAuthenticated) {
      final roleLower = role.toLowerCase();
      final isAdmin = roleLower == 'admin';
      return isAdmin ? AdminDashboard() : StudentDashboard();
    }

    return LoginPage(role: role);
  }
}

/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vivatrack/pagesFolder/login_page.dart';
import 'firebase_auth.dart';

class RedirectPage extends StatefulWidget {
  final String role;

  const RedirectPage({super.key, this.role = 'student'});

  @override
  State<RedirectPage> createState() => RedirectPageState();
}

class RedirectPageState extends State<RedirectPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: SudoAuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasData) {
          return RedirectPage();
        } else {
          return LoginPage(role: widget.role);
        }
      },
    );
  }
}*/

/*class RedirectPage extends StatelessWidget {
  const RedirectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: SudoAuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            return const LoginPage(role: 'student'); // Redirige vers la page de connexion
          } else {
            // Ici, tu peux ajouter une logique pour vérifier le rôle de l'utilisateur
            // Par exemple, en utilisant une base de données pour stocker les rôles
            // Pour simplifier, on suppose que tous les utilisateurs sont des étudiants
            return const HomePage(); // Redirige vers la page d'accueil
          }
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}*/
