// Alias pour la page d'authentification
export 'auth_page.dart';

// Raccourci pour accéder directement à la page de login
import 'package:flutter/material.dart';
import 'auth_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthPage(initialLoginTab: true);
  }
}
