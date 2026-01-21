import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../menus/models/menu_model.dart';
import '../services/management_service.dart';
import '../widgets/menu_form_dialog.dart';

class MenusManagementPage extends StatefulWidget {
  const MenusManagementPage({super.key});

  @override
  State<MenusManagementPage> createState() => _MenusManagementPageState();
}

class _MenusManagementPageState extends State<MenusManagementPage> {
  final ManagementService _service = ManagementService();
  List<MenuModel> _menus = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMenus();
  }

  Future<void> _loadMenus() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final menus = await _service.getMenus();
      setState(() {
        _menus = menus;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteMenu(int menuId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer ce menu ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _service.deleteMenu(menuId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu supprimé'), backgroundColor: Colors.green),
      );
      _loadMenus();
    } catch (e) {
    if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
      );
    }
  }

  void _showMenuForm({MenuModel? menu}) {
    showDialog(
      context: context,
      builder: (context) => MenuFormDialog(
        menu: menu,
        onSave: (data) async {
          try {
            if (menu == null) {
              await _service.createMenu(data);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menu créé'), backgroundColor: Colors.green),
              );
            } else {
              await _service.updateMenu(menu.id, data);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menu mis à jour'), backgroundColor: Colors.green),
              );
            }
            _loadMenus();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header Premium
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  AppColors.primary.withValues(alpha: 0.05),
                ],
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: context.horizontalPadding,
              right: context.horizontalPadding,
              bottom: 16,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Text(
                  'Gestion des Menus',
                  style: AppTextStyles.displayTitle.copyWith(
                    fontSize: 28,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Contenu
          Expanded(
            child: _menus.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 64,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun menu disponible',
                          style: AppTextStyles.subtitle.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildMenusGrid(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMenuForm(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMenusGrid(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(context.horizontalPadding),
      itemCount: _menus.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final menu = _menus[index];
        return _buildMenuCard(context, menu);
      },
    );
  }

  Widget _buildMenuCard(BuildContext context, MenuModel menu) {
    final hasImage = menu.images.isNotEmpty;
    final imageUrl = hasImage ? menu.images.first.imageUrl : null;
    
    // Récupérer les plats par type
    final starter = menu.dishes.where((d) => d.dishType == 'STARTER').firstOrNull;
    final main = menu.dishes.where((d) => d.dishType == 'MAIN').firstOrNull;
    final dessert = menu.dishes.where((d) => d.dishType == 'DESSERT').firstOrNull;

    return GlassCard(
      borderColor: menu.isActive 
          ? AppColors.primary.withValues(alpha: 0.3)
          : AppColors.textMuted.withValues(alpha: 0.2),
      borderWidth: 2,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image de couverture
          if (hasImage)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  Image.network(
                    imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: AppColors.lightGrey,
                      child: const Icon(Icons.restaurant, size: 64, color: AppColors.textMuted),
                    ),
                  ),
                  // Badge actif/inactif
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: menu.isActive 
                            ? AppColors.success.withValues(alpha: 0.9)
                            : AppColors.danger.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        menu.isActive ? 'Actif' : 'Inactif',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Contenu
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre et thème
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            menu.title,
                            style: AppTextStyles.cardTitle.copyWith(fontSize: 22),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            menu.theme,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${menu.basePrice.toStringAsFixed(2)}€',
                        style: AppTextStyles.subtitle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  menu.description,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // Composition du menu
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Composition du menu',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (starter != null)
                        _buildDishItem(
                          icon: Icons.restaurant,
                          label: 'Entrée',
                          dishName: starter.name,
                          color: AppColors.success,
                        ),
                      if (starter != null && (main != null || dessert != null))
                        const SizedBox(height: 8),
                      if (main != null)
                        _buildDishItem(
                          icon: Icons.lunch_dining,
                          label: 'Plat',
                          dishName: main.name,
                          color: AppColors.primary,
                        ),
                      if (main != null && dessert != null)
                        const SizedBox(height: 8),
                      if (dessert != null)
                        _buildDishItem(
                          icon: Icons.cake,
                          label: 'Dessert',
                          dishName: dessert.name,
                          color: AppColors.accent,
                        ),
                      if (starter == null && main == null && dessert == null)
                        Text(
                          'Aucun plat associé',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Informations pratiques
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      icon: Icons.people,
                      label: 'Min. ${menu.minPeople} pers',
                    ),
                    _buildInfoChip(
                      icon: Icons.local_dining,
                      label: menu.regime,
                    ),
                    _buildInfoChip(
                      icon: Icons.inventory_2,
                      label: 'Stock: ${menu.stock}',
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showMenuForm(menu: menu),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Modifier'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => _deleteMenu(menu.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Icon(Icons.delete, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDishItem({
    required IconData icon,
    required String label,
    required String dishName,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                dishName,
                style: AppTextStyles.body.copyWith(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.textMuted.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
