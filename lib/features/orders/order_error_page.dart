import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/utils/responsive.dart';

class OrderErrorPage extends StatefulWidget {
  final String errorMessage;
  final String? errorCode;
  final VoidCallback? onRetry;

  const OrderErrorPage({
    super.key,
    required this.errorMessage,
    this.errorCode,
    this.onRetry,
  });

  @override
  State<OrderErrorPage> createState() => _OrderErrorPageState();
}

class _OrderErrorPageState extends State<OrderErrorPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticIn),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = context.fluidValue(minValue: 20, maxValue: 48);
    final iconSize = context.fluidValue(minValue: 80, maxValue: 120);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: context.isDesktop ? 550 : 450,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icône d'erreur animée
                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      final shake = _shakeAnimation.value < 0.5
                          ? _shakeAnimation.value * 10
                          : (1 - _shakeAnimation.value) * 10;
                      return Transform.translate(
                        offset: Offset(shake * (shake.isFinite ? 1 : 0), 0),
                        child: Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.red.shade400,
                                Colors.red.shade600,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: iconSize * 0.5,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(
                    height: context.fluidValue(minValue: 24, maxValue: 32),
                  ),

                  // Titre
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Oups, une erreur est survenue',
                      style: AppTextStyles.sectionTitle.copyWith(
                        fontSize: context.fluidValue(
                          minValue: 20,
                          maxValue: 26,
                        ),
                        color: Colors.red.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(
                    height: context.fluidValue(minValue: 12, maxValue: 16),
                  ),

                  // Message d'erreur
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Nous n\'avons pas pu traiter votre commande.',
                      style: AppTextStyles.body.copyWith(
                        fontSize: context.fluidValue(
                          minValue: 14,
                          maxValue: 16,
                        ),
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(
                    height: context.fluidValue(minValue: 24, maxValue: 32),
                  ),

                  // Détails de l'erreur
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildErrorDetails(context),
                  ),

                  SizedBox(
                    height: context.fluidValue(minValue: 24, maxValue: 32),
                  ),

                  // Suggestions
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildSuggestions(context),
                  ),

                  SizedBox(
                    height: context.fluidValue(minValue: 32, maxValue: 40),
                  ),

                  // Boutons d'action
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildActions(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorDetails(BuildContext context) {
    final spacing = context.fluidValue(minValue: 12, maxValue: 16);

    return GlassCard(
      padding: EdgeInsets.all(context.fluidValue(minValue: 16, maxValue: 20)),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.danger,
                size: context.fluidValue(minValue: 20, maxValue: 24),
              ),
              SizedBox(width: spacing * 0.75),
              Expanded(
                child: Text(
                  'Détail de l\'erreur',
                  style: AppTextStyles.cardTitle.copyWith(
                    fontSize: context.fluidValue(minValue: 14, maxValue: 16),
                    color: AppColors.danger,
                  ),
                ),
              ),
              if (widget.errorCode != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing * 0.75,
                    vertical: spacing * 0.25,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.errorCode!,
                    style: TextStyle(
                      fontSize: context.fluidValue(minValue: 10, maxValue: 12),
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: spacing),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(spacing),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade100),
            ),
            child: Text(
              widget.errorMessage,
              style: AppTextStyles.body.copyWith(
                fontSize: context.fluidValue(minValue: 13, maxValue: 14),
                color: Colors.red.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    final spacing = context.fluidValue(minValue: 12, maxValue: 16);

    return GlassCard(
      padding: EdgeInsets.all(context.fluidValue(minValue: 16, maxValue: 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.info,
                size: context.fluidValue(minValue: 20, maxValue: 24),
              ),
              SizedBox(width: spacing * 0.75),
              Text(
                'Que faire ?',
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: context.fluidValue(minValue: 14, maxValue: 16),
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing),
          _buildSuggestionItem(
            context,
            icon: Icons.refresh,
            text: 'Réessayez dans quelques instants',
          ),
          SizedBox(height: spacing * 0.75),
          _buildSuggestionItem(
            context,
            icon: Icons.wifi,
            text: 'Vérifiez votre connexion internet',
          ),
          SizedBox(height: spacing * 0.75),
          _buildSuggestionItem(
            context,
            icon: Icons.edit,
            text: 'Vérifiez les informations saisies',
          ),
          SizedBox(height: spacing * 0.75),
          _buildSuggestionItem(
            context,
            icon: Icons.support_agent,
            text: 'Contactez-nous si le problème persiste',
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: context.fluidValue(minValue: 16, maxValue: 18),
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body.copyWith(
              fontSize: context.fluidValue(minValue: 13, maxValue: 14),
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final buttonHeight = context.fluidValue(minValue: 48, maxValue: 56);

    return Column(
      children: [
        // Bouton réessayer
        if (widget.onRetry != null) ...[
          SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                widget.onRetry?.call();
              },
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: Text(
                'Réessayer',
                style: TextStyle(
                  fontSize: context.fluidValue(minValue: 14, maxValue: 16),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(height: context.fluidValue(minValue: 12, maxValue: 16)),
        ],

        // Bouton retour
        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: AppColors.primary),
            label: Text(
              'Modifier ma commande',
              style: TextStyle(
                fontSize: context.fluidValue(minValue: 14, maxValue: 16),
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        SizedBox(height: context.fluidValue(minValue: 12, maxValue: 16)),

        // Lien contact
        TextButton.icon(
          onPressed: () {},
          icon: Icon(
            Icons.mail_outline,
            color: AppColors.textSecondary,
            size: context.fluidValue(minValue: 18, maxValue: 20),
          ),
          label: Text(
            'Contacter le support',
            style: AppTextStyles.body.copyWith(
              fontSize: context.fluidValue(minValue: 13, maxValue: 14),
              color: AppColors.textSecondary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
