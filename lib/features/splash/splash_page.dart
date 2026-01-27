import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/typography.dart';
import '../../core/theme/colors.dart';
import '../../core/api/dio_client.dart';
import '../navigation/main_navigation_page.dart';
import '../home/home_page.dart';
import '../auth/services/auth_service.dart';
import '../admin/admin_navigation_page.dart';
import '../employee/employee_navigation_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _subtitleController;
  late AnimationController _particleController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _subtitleOpacity;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _subtitleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _subtitleController, curve: Curves.easeInOut),
    );

    _startAnimations();
    _navigateToHome();
  }

  _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _subtitleController.forward();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // Vérifier si l'utilisateur est connecté
    try {
      final dioClient = await DioClient.create();
      final hasToken = await dioClient.hasValidToken();

      if (!mounted) return;

      if (hasToken) {
        // Token valide -> Récupérer le rôle de l'utilisateur
        try {
          final authService = AuthService();
          final userData = await authService.getCurrentUser();

          if (!mounted) return;

          // Rediriger selon le rôle
          Widget destination;
          switch (userData.role) {
            case 'ADMIN':
              destination = AdminNavigationPage(initialIndex: 0);
              break;
            case 'EMPLOYEE':
              destination = EmployeeNavigationPage(initialIndex: 0);
              break;
            case 'USER':
            default:
              destination = const MainNavigationPage();
              break;
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => destination),
          );
        } catch (e) {
          // Erreur lors de la récupération du profil -> Token invalide
          debugPrint('❌ Erreur récupération profil: $e');
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          }
        }
      } else {
        // Utilisateur non connecté -> Page d'accueil publique
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      // En cas d'erreur, rediriger vers la page d'accueil
      debugPrint('❌ Erreur navigation: $e');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _subtitleController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background sophistiqué
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.dark, AppColors.truffle, AppColors.caviar],
              ),
            ),
          ),

          // Particules dorées flottantes
          ...List.generate(12, (index) => _buildFloatingParticle(index)),

          // Overlay élégant
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Colors.transparent,
                  AppColors.dark.withValues(alpha: 0.3),
                  AppColors.dark.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),

          // Contenu principal
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Logo animé sophistiqué
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScale.value,
                      child: Opacity(
                        opacity: _logoOpacity.value,
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.1),
                                AppColors.saffron.withValues(alpha: 0.05),
                              ],
                            ),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                blurRadius: 40,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Titre principal élégant
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Vite',
                                      style: AppTextStyles.heroTitle.copyWith(
                                        fontSize: 52,
                                        color: AppColors.champagne,
                                        fontWeight: FontWeight.w300,
                                        letterSpacing: 3.0,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' & ',
                                      style: AppTextStyles.heroTitle.copyWith(
                                        fontSize: 32,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Gourmand',
                                      style: AppTextStyles.heroTitle.copyWith(
                                        fontSize: 52,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 3.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Séparateur décoratif
                              Container(
                                width: 120,
                                height: 2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      AppColors.primary,
                                      AppColors.saffron,
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Sous-titre élégant
                              Text(
                                'L\'Art de Recevoir depuis 2001',
                                style: AppTextStyles.subtitle.copyWith(
                                  color: AppColors.champagne,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const Spacer(),

                // Indicateur sophistiqué
                AnimatedBuilder(
                  animation: _subtitleController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _subtitleOpacity.value,
                      child: Column(
                        children: [
                          // Loading indicator premium
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.2),
                                  AppColors.saffron.withValues(alpha: 0.1),
                                ],
                              ),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Text(
                            'Préparation de votre expérience...',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.champagne.withValues(alpha: 0.9),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    final random = math.Random(index);
    final size = random.nextDouble() * 6 + 2;
    final startX = random.nextDouble();
    final startY = random.nextDouble();
    final duration = random.nextInt(3000) + 2000;

    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        final progress = (_particleController.value + (index * 0.1)) % 1.0;
        final x = startX + (math.sin(progress * 2 * math.pi + index) * 0.1);
        final y = startY + (progress * 0.2);

        return Positioned(
          left: MediaQuery.of(context).size.width * x,
          top: MediaQuery.of(context).size.height * (y % 1.0),
          child: Opacity(
            opacity: (0.3 + (math.sin(progress * math.pi * 2) * 0.3)).clamp(
              0.0,
              1.0,
            ),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size / 2),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.8),
                    AppColors.saffron.withValues(alpha: 0.6),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: size * 2,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
