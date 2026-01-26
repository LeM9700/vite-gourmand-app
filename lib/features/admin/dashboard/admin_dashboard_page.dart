import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/glass_card.dart';
import '../services/admin_service.dart';

/// Page d'accueil Dashboard Admin - Vue d'ensemble avec KPI
/// Affiche les indicateurs clés de performance du restaurant
class AdminDashboardPage extends StatefulWidget {
  final void Function(int pageIndex, {int? tabIndex})? onNavigateToPage;

  const AdminDashboardPage({super.key, this.onNavigateToPage});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;

  // KPI chargés depuis l'API
  Map<String, dynamic> _kpiData = {
    'total_orders_today': 0,
    'total_revenue_today': 0.0,
    'total_revenue_all_time': 0.0,
    'pending_orders': 0,
    'active_employees': 0,
    'pending_reviews': 0,
    'pending_messages': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadKpiData();
  }

  Future<void> _loadKpiData() async {
    setState(() => _isLoading = true);

    try {
      final kpiData = await _adminService.getTodayKpi();
      if (mounted) {
        setState(() {
          _kpiData = kpiData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement des KPI: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.horizontalPadding;
    final isSmallScreen = context.isSmallScreen;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadKpiData,
        child: CustomScrollView(
          slivers: [
            // App Bar Premium
            SliverAppBar(
              expandedHeight: 140,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.dark,
                        AppColors.darkGrey,
                        AppColors.primary.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 25),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primary.withValues(alpha: 0.7),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.dashboard_rounded,
                                  color: AppColors.dark,
                                  size: context.fluidValue(
                                    minValue: 28,
                                    maxValue: 36,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dashboard Admin',
                                      style: AppTextStyles.displayTitle
                                          .copyWith(
                                            fontSize: context.fluidValue(
                                              minValue: 24,
                                              maxValue: 32,
                                            ),
                                            color: AppColors.textLight,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Vue d\'ensemble',
                                      style: AppTextStyles.subtitle.copyWith(
                                        fontSize: context.fluidValue(
                                          minValue: 14,
                                          maxValue: 16,
                                        ),
                                        color: AppColors.textLight.withValues(
                                          alpha: 0.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Contenu
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Message de bienvenue
                    _buildWelcomeCard(context),

                    const SizedBox(height: 32),

                    // Section KPI aujourd'hui
                    Text(
                      '📊 Aujourd\'hui',
                      style: AppTextStyles.sectionTitle.copyWith(
                        fontSize: context.fluidValue(
                          minValue: 20,
                          maxValue: 24,
                        ),
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildKpiGrid(context, isSmallScreen),

                    const SizedBox(height: 32),

                    // Section Actions rapides
                    Text(
                      '⚡ Actions rapides',
                      style: AppTextStyles.sectionTitle.copyWith(
                        fontSize: context.fluidValue(
                          minValue: 20,
                          maxValue: 24,
                        ),
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildQuickActionsGrid(context, isSmallScreen),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      fillColor: AppColors.primary.withValues(alpha: 0.08),
      borderColor: AppColors.primary.withValues(alpha: 0.3),
      borderWidth: 2,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.7),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: AppColors.dark,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenue, José ! 👋',
                  style: AppTextStyles.cardTitle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Voici un aperçu de l\'activité de votre restaurant.',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(BuildContext context, bool isSmallScreen) {
    if (_isLoading) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Chargement des données...',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isSmallScreen ? 2 : 3,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: isSmallScreen ? 1.2 : 1.4,
      children: [
        _buildKpiCard(
          icon: Icons.shopping_bag_rounded,
          label: 'Commandes',
          value: '${_kpiData['total_orders_today']}',
          subtitle: 'aujourd\'hui',
          color: AppColors.info,
          onTap: () => widget.onNavigateToPage?.call(3, tabIndex: 0),
        ),
        _buildKpiCard(
          icon: Icons.account_balance_wallet_rounded,
          label: 'CA Total',
          value: '${_kpiData['total_revenue_all_time'].toStringAsFixed(0)}€',
          subtitle: 'toutes commandes',
          color: AppColors.primary,
          onTap: () => widget.onNavigateToPage?.call(2),
        ),
        _buildKpiCard(
          icon: Icons.schedule_rounded,
          label: 'En attente',
          value: '${_kpiData['pending_orders']}',
          subtitle: 'commandes',
          color: AppColors.warning,
          onTap: () => widget.onNavigateToPage?.call(3, tabIndex: 0),
        ),
        _buildKpiCard(
          icon: Icons.people_rounded,
          label: 'Employés',
          value: '${_kpiData['active_employees']}',
          subtitle: 'actifs',
          color: AppColors.primary,
          onTap: () => widget.onNavigateToPage?.call(1),
        ),
        _buildKpiCard(
          icon: Icons.rate_review_rounded,
          label: 'Avis',
          value: '${_kpiData['pending_reviews']}',
          subtitle: 'à modérer',
          color: Colors.orange,
          onTap: () => widget.onNavigateToPage?.call(3, tabIndex: 1),
        ),
        _buildKpiCard(
          icon: Icons.message_rounded,
          label: 'Messages',
          value: '${_kpiData['pending_messages']}',
          subtitle: 'en attente',
          color: Colors.purple,
          onTap: () => widget.onNavigateToPage?.call(3, tabIndex: 1),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderColor: color.withValues(alpha: 0.3),
        borderWidth: 2,
        fillColor: color.withValues(alpha: 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTextStyles.cardTitle.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context, bool isSmallScreen) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isSmallScreen ? 2 : 4,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: isSmallScreen ? 1.2 : 1.4,
      children: [
        _buildQuickActionCard(
          icon: Icons.person_add_rounded,
          label: 'Nouvel employé',
          onTap: () => widget.onNavigateToPage?.call(1), // Employés
        ),
        _buildQuickActionCard(
          icon: Icons.analytics_rounded,
          label: 'Voir stats',
          onTap: () => widget.onNavigateToPage?.call(2), // Stats
        ),
        _buildQuickActionCard(
          icon: Icons.restaurant_menu_rounded,
          label: 'Gérer menus',
          onTap:
              () => widget.onNavigateToPage?.call(
                3,
                tabIndex: 2,
              ), // Management > Menus
        ),
        _buildQuickActionCard(
          icon: Icons.schedule_rounded,
          label: 'Horaires',
          onTap:
              () => widget.onNavigateToPage?.call(
                3,
                tabIndex: 4,
              ), // Management > Horaires
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        hasHover: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
