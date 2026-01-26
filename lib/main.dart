import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'features/splash/splash_page.dart';
import 'features/auth/reset_password_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _linkSubscription;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initDeepLinks();
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    // Gérer le deep link initial (app fermée puis ouverte via lien)
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération du lien initial: $e');
    }

    // Écouter les deep links pendant que l'app est ouverte
    _linkSubscription = linkStream.listen(
      (String? link) {
        if (link != null) {
          _handleDeepLink(link);
        }
      },
      onError: (err) {
        debugPrint('Erreur lors de l\'écoute des liens: $err');
      },
    );
  }

  void _handleDeepLink(String link) {
    final uri = Uri.parse(link);

    // Vérifier si c'est un lien de réinitialisation de mot de passe
    // Format attendu: vitegourmand://reset-password?token=xxx
    // ou https://votredomaine.com/reset-password?token=xxx
    if (uri.path.contains('reset-password') || uri.host == 'reset-password') {
      final token = uri.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        // Naviguer vers la page de réinitialisation
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => ResetPasswordPage(token: token)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: const SplashPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
