import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/skeleton_box.dart';
import '../../core/utils/responsive.dart';
import '../../core/api/dio_client.dart';
import '../orders/models/user_info_model.dart';
import '../orders/edit_delivery_info_page.dart';
import '../auth/login_page.dart';
import '../home/home_page.dart';

/// Page des paramètres utilisateur
class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  UserInfoModel? _userInfo;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dioClient = await DioClient.create();
      final response = await dioClient.dio.get('/auth/me');

      if (!mounted) return;

      setState(() {
        _userInfo = UserInfoModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      // Si erreur 401, rediriger vers login
      if (e.toString().contains('401')) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
        return;
      }

      setState(() {
        _errorMessage = 'Impossible de charger vos informations';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = context.fluidValue(minValue: 16, maxValue: 32);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Paramètres',
          style: AppTextStyles.sectionTitle.copyWith(
            fontSize: context.fluidValue(minValue: 20, maxValue: 24),
          ),
        ),
        centerTitle: context.isMobile,
      ),
      body:
          _isLoading
              ? _buildLoadingSkeleton(context, padding)
              : _errorMessage != null
              ? _buildErrorState(context, padding)
              : _buildContent(context, padding),
    );
  }

  Widget _buildContent(BuildContext context, double padding) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.isDesktop ? 800 : double.infinity,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profil utilisateur
              _buildProfileCard(context),

              SizedBox(height: context.fluidValue(minValue: 16, maxValue: 20)),

              // Informations personnelles
              _buildPersonalInfoCard(context),

              SizedBox(height: context.fluidValue(minValue: 16, maxValue: 20)),

              // Préférences
              _buildPreferencesCard(context),

              SizedBox(height: context.fluidValue(minValue: 16, maxValue: 20)),

              // Sécurité
              _buildSecurityCard(context),

              SizedBox(height: context.fluidValue(minValue: 16, maxValue: 20)),

              // À propos
              _buildAboutCard(context),

              SizedBox(height: context.fluidValue(minValue: 16, maxValue: 20)),

              // Déconnexion
              _buildLogoutButton(context),

              SizedBox(height: context.fluidValue(minValue: 20, maxValue: 32)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          // Avatar
          Container(
            width: context.fluidValue(minValue: 60, maxValue: 80),
            height: context.fluidValue(minValue: 60, maxValue: 80),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Center(
              child: Text(
                _userInfo!.firstname[0].toUpperCase() +
                    _userInfo!.lastname[0].toUpperCase(),
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: context.fluidValue(minValue: 24, maxValue: 32),
                  color: AppColors.dark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SizedBox(width: context.fluidValue(minValue: 16, maxValue: 20)),

          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userInfo!.fullName,
                  style: AppTextStyles.cardTitle.copyWith(
                    fontSize: context.fluidValue(minValue: 18, maxValue: 22),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userInfo!.email,
                  style: AppTextStyles.body.copyWith(
                    fontSize: context.fluidValue(minValue: 13, maxValue: 15),
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                // Badge rôle
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _userInfo!.role == 'ADMIN'
                        ? '👑 Administrateur'
                        : '👤 Client',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Informations personnelles',
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: context.fluidValue(minValue: 16, maxValue: 18),
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: AppColors.primary),
                onPressed: () => _navigateToEdit(),
                tooltip: 'Modifier',
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          _buildInfoItem(
            icon: Icons.person,
            label: 'Nom complet',
            value: _userInfo!.fullName,
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            icon: Icons.email,
            label: 'Email',
            value: _userInfo!.email,
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            icon: Icons.phone,
            label: 'Téléphone',
            value: _userInfo!.phone ?? 'Non renseigné',
            isEmpty: _userInfo!.phone == null,
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            icon: Icons.location_on,
            label: 'Adresse',
            value: _userInfo!.address ?? 'Non renseignée',
            isEmpty: _userInfo!.address == null,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    bool isEmpty = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: isEmpty ? AppColors.textMuted : AppColors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w500,
                  fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                  color: isEmpty ? AppColors.textMuted : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesCard(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Préférences',
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: context.fluidValue(minValue: 16, maxValue: 18),
            ),
          ),
          const SizedBox(height: 16),

          _buildSwitchItem(
            icon: Icons.notifications,
            label: 'Notifications par email',
            subtitle: 'Recevoir les mises à jour de commandes',
            value: true,
            onChanged: (value) {},
          ),

          const SizedBox(height: 12),

          _buildSwitchItem(
            icon: Icons.sms,
            label: 'Notifications SMS',
            subtitle: 'Alertes importantes par SMS',
            value: false,
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, size: 24, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
              ),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildSecurityCard(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sécurité',
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: context.fluidValue(minValue: 16, maxValue: 18),
            ),
          ),
          const SizedBox(height: 16),

          _buildActionItem(
            icon: Icons.lock,
            label: 'Changer le mot de passe',
            onTap: () {
              _showChangePasswordDialog(context);
            },
          ),

          const SizedBox(height: 12),

          _buildActionItem(
            icon: Icons.security,
            label: 'Authentification à deux facteurs',
            badge: 'Bientôt',
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    String? badge,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 24, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              )
            else
              Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'À propos',
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: context.fluidValue(minValue: 16, maxValue: 18),
            ),
          ),
          const SizedBox(height: 16),

          _buildActionItem(
            icon: Icons.help_outline,
            label: 'Aide & Support',
            onTap: () {},
          ),

          const SizedBox(height: 12),

          _buildActionItem(
            icon: Icons.privacy_tip_outlined,
            label: 'Politique de confidentialité',
            onTap: () {},
          ),

          const SizedBox(height: 12),

          _buildActionItem(
            icon: Icons.description_outlined,
            label: 'Conditions d\'utilisation',
            onTap: () {},
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          Center(
            child: Text(
              'Version 1.0.0',
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _logout(context),
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text('Déconnexion'),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Future<void> _navigateToEdit() async {
    if (_userInfo == null) return;

    final result = await Navigator.push<UserInfoModel>(
      context,
      MaterialPageRoute(
        builder: (context) => EditDeliveryInfoPage(userInfo: _userInfo!),
      ),
    );

    if (result != null && mounted) {
      setState(() => _userInfo = result);
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Changer le mot de passe'),
            content: const Text(
              'Cette fonctionnalité sera bientôt disponible. Vous recevrez un email pour réinitialiser votre mot de passe.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Déconnexion'),
            content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Déconnexion'),
              ),
            ],
          ),
    );

    if (confirm == true && mounted) {
      // Effacer le token
      final dioClient = await DioClient.create();
      await dioClient.clearToken();

      if (mounted) {
        // Retour à la page de login
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      }
    }
  }

  Widget _buildLoadingSkeleton(BuildContext context, double padding) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: [
          const GlassCard(child: SkeletonBox(height: 80)),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              children: List.generate(4, (index) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: SkeletonBox(height: 40),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, double padding) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.danger),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: AppTextStyles.body.copyWith(color: AppColors.danger),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadUserInfo,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.dark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
