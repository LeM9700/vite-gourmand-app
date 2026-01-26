import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/utils/responsive.dart';
import 'package:intl/intl.dart';

class OrderConfirmationPage extends StatefulWidget {
  final int orderId;
  final String menuTitle;
  final DateTime eventDate;
  final TimeOfDay eventTime;
  final int guestsCount;
  final double totalPrice;
  final String deliveryCity;

  const OrderConfirmationPage({
    super.key,
    required this.orderId,
    required this.menuTitle,
    required this.eventDate,
    required this.eventTime,
    required this.guestsCount,
    required this.totalPrice,
    required this.deliveryCity,
  });

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
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
                maxWidth: context.isDesktop ? 600 : 500,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icône de succès animée
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.green.shade400,
                                Colors.green.shade600,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.check_rounded,
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
                      'Commande confirmée !',
                      style: AppTextStyles.sectionTitle.copyWith(
                        fontSize: context.fluidValue(
                          minValue: 22,
                          maxValue: 28,
                        ),
                        color: Colors.green.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(
                    height: context.fluidValue(minValue: 8, maxValue: 12),
                  ),

                  // Sous-titre
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Merci pour votre confiance ! Notre équipe va étudier votre demande.',
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
                    height: context.fluidValue(minValue: 32, maxValue: 40),
                  ),

                  // Récapitulatif
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildOrderSummary(context),
                  ),

                  SizedBox(
                    height: context.fluidValue(minValue: 24, maxValue: 32),
                  ),

                  // Info prochaines étapes
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildNextSteps(context),
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

  Widget _buildOrderSummary(BuildContext context) {
    final spacing = context.fluidValue(minValue: 12, maxValue: 16);
    final labelSize = context.fluidValue(minValue: 13, maxValue: 15);

    return GlassCard(
      padding: EdgeInsets.all(context.fluidValue(minValue: 16, maxValue: 24)),
      child: Column(
        children: [
          // Numéro de commande
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: spacing,
              vertical: spacing * 0.5,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Commande #${widget.orderId}',
              style: AppTextStyles.cardTitle.copyWith(
                fontSize: context.fluidValue(minValue: 14, maxValue: 16),
                color: AppColors.primary,
              ),
            ),
          ),

          SizedBox(height: spacing * 1.5),
          Divider(height: 1, color: Colors.grey.shade200),
          SizedBox(height: spacing * 1.5),

          // Détails
          _buildDetailRow(
            context,
            icon: Icons.restaurant_menu,
            label: 'Menu',
            value: widget.menuTitle,
            labelSize: labelSize,
          ),
          SizedBox(height: spacing),
          _buildDetailRow(
            context,
            icon: Icons.calendar_today,
            label: 'Date',
            value: DateFormat(
              'EEEE d MMMM yyyy',
              'fr_FR',
            ).format(widget.eventDate),
            labelSize: labelSize,
          ),
          SizedBox(height: spacing),
          _buildDetailRow(
            context,
            icon: Icons.access_time,
            label: 'Heure',
            value: widget.eventTime.format(context),
            labelSize: labelSize,
          ),
          SizedBox(height: spacing),
          _buildDetailRow(
            context,
            icon: Icons.people,
            label: 'Invités',
            value: '${widget.guestsCount} personnes',
            labelSize: labelSize,
          ),
          SizedBox(height: spacing),
          _buildDetailRow(
            context,
            icon: Icons.location_on,
            label: 'Livraison',
            value: widget.deliveryCity,
            labelSize: labelSize,
          ),

          SizedBox(height: spacing * 1.5),
          Divider(height: 1, color: Colors.grey.shade300),
          SizedBox(height: spacing * 1.5),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total estimé',
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: context.fluidValue(minValue: 16, maxValue: 18),
                ),
              ),
              Text(
                '${widget.totalPrice.toStringAsFixed(2)}€',
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: context.fluidValue(minValue: 18, maxValue: 22),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required double labelSize,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: context.fluidValue(minValue: 18, maxValue: 22),
          color: AppColors.textSecondary,
        ),
        SizedBox(width: context.fluidValue(minValue: 10, maxValue: 12)),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: labelSize - 1,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Flexible(
          flex: 2,
          child: Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontSize: labelSize,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildNextSteps(BuildContext context) {
    final spacing = context.fluidValue(minValue: 12, maxValue: 16);

    return GlassCard(
      padding: EdgeInsets.all(context.fluidValue(minValue: 16, maxValue: 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.info,
                size: context.fluidValue(minValue: 20, maxValue: 24),
              ),
              SizedBox(width: spacing * 0.75),
              Text(
                'Prochaines étapes',
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: context.fluidValue(minValue: 14, maxValue: 16),
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing),
          _buildStep(context, '1', 'Notre équipe examine votre demande'),
          SizedBox(height: spacing * 0.75),
          _buildStep(context, '2', 'Vous recevrez un email de confirmation'),
          SizedBox(height: spacing * 0.75),
          _buildStep(context, '3', 'Nous vous contacterons pour finaliser'),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
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
        // Bouton principal
        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: ElevatedButton.icon(
            onPressed: () {
              // Retour à l'accueil et vider la navigation
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.home, color: Colors.white),
            label: Text(
              'Retour à l\'accueil',
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

        // Bouton secondaire
        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: Icon(Icons.receipt_long, color: AppColors.primary),
            label: Text(
              'Voir mes commandes',
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
      ],
    );
  }
}
