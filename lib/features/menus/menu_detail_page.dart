import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/price_formatter.dart';
import '../../core/widgets/glass_card.dart';
import 'models/menu_model.dart';
import '../auth/auth_page.dart';
import '../orders/order_page.dart';
import '../../core/storage/secure_storage.dart';

class MenuDetailPage extends StatelessWidget {
  final MenuModel menu;

  const MenuDetailPage({super.key, required this.menu});

  Future<void> _handleOrderClick(BuildContext context) async {
    final storage = SecureStorage();
    var token = await storage.readToken();

    if (!context.mounted) return;

    if (token != null && token.isNotEmpty) {
      // User is logged in, go to Order Page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OrderPage(selectedMenu: menu)),
      );
    } else {
      // User is not logged in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez vous connecter pour commander'),
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate to Auth Page and wait for result
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthPage(initialLoginTab: true),
        ),
      );

      // Check token again after returning from Auth Page
      if (!context.mounted) return;
      token = await storage.readToken();

      if (token != null && token.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderPage(selectedMenu: menu),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Valeurs responsive
    final heroHeight = responsiveValue<double>(
      context,
      mobile: 280,
      tablet: 350,
      desktop: 400,
    );

    final contentPadding = responsiveValue<double>(
      context,
      mobile: 20,
      tablet: 32,
      desktop: 48,
    );

    // Layout desktop : deux colonnes
    if (context.isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            // Image à gauche (40%)
            Expanded(
              flex: 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  menu.imageUrl != null
                      ? Image.network(menu.imageUrl!, fit: BoxFit.cover)
                      : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary.withValues(alpha: 0.8),
                              AppColors.accent.withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.restaurant_menu,
                            size: 120,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  // Bouton retour
                  Positioned(
                    top: 24,
                    left: 24,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Contenu à droite (60%)
            Expanded(
              flex: 6,
              child: Container(
                color: AppColors.background,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(contentPadding),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 700),
                          child: _buildContent(context),
                        ),
                      ),
                    ),
                    _buildBottomBar(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Layout mobile/tablet
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Hero Image App Bar
          SliverAppBar(
            expandedHeight: heroHeight,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  menu.imageUrl != null
                      ? Image.network(menu.imageUrl!, fit: BoxFit.cover)
                      : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary.withValues(alpha: 0.8),
                              AppColors.accent.withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.restaurant_menu,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  // Gradient Overlay for text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                menu.title,
                style: AppTextStyles.sectionTitle.copyWith(color: Colors.white),
              ),
              centerTitle: true,
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: ResponsiveContainer(
              maxWidth: 800,
              padding: EdgeInsets.all(contentPadding),
              child: _buildContent(context),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final spacing = context.fluidValue(minValue: 16, maxValue: 24);
    final titleSize = context.fluidValue(minValue: 16, maxValue: 18);

    // Grouper les plats par type
    final starters = menu.dishes.where((d) => d.dishType == 'STARTER').toList();
    final mains = menu.dishes.where((d) => d.dishType == 'MAIN').toList();
    final desserts = menu.dishes.where((d) => d.dishType == 'DESSERT').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre (desktop uniquement)
        if (context.isDesktop) ...[
          Text(
            menu.title,
            style: AppTextStyles.heroTitle.copyWith(
              fontSize: 32,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: spacing),
        ],

        // Meta Tags (Theme, Regime, People)
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (menu.theme.isNotEmpty)
                  _buildTag(context, menu.theme, AppColors.accent),
                if (menu.theme.isNotEmpty) const SizedBox(width: 8),
                if (menu.regime.isNotEmpty)
                  _buildTag(context, menu.regime, AppColors.success),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.people,
                  size: context.fluidValue(minValue: 14, maxValue: 16),
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Min ${menu.minPeople} pers.',
                  style: AppTextStyles.body.copyWith(
                    fontSize: context.fluidValue(minValue: 12, maxValue: 14),
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),

        SizedBox(height: spacing),

        // Description
        Text(
          'À propos',
          style: AppTextStyles.sectionTitle.copyWith(fontSize: titleSize),
        ),
        SizedBox(height: spacing * 0.5),
        Text(
          menu.description,
          style: AppTextStyles.body.copyWith(
            fontSize: context.fluidValue(minValue: 13, maxValue: 15),
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),

        SizedBox(height: spacing),

        // Composition du Menu - Titre
        Text(
          'Composition du Menu',
          style: AppTextStyles.sectionTitle.copyWith(fontSize: titleSize),
        ),
        SizedBox(height: spacing),

        if (menu.dishes.isEmpty)
          Text(
            'Aucun plat spécifié pour ce menu.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          )
        else ...[
          // Entrées
          if (starters.isNotEmpty) ...[
            _buildDishCategory(
              context,
              title: 'Entrées',
              icon: Icons.soup_kitchen_rounded,
              color: AppColors.success,
              dishes: starters,
            ),
            SizedBox(height: spacing * 0.75),
          ],

          // Plats
          if (mains.isNotEmpty) ...[
            _buildDishCategory(
              context,
              title: 'Plats',
              icon: Icons.restaurant_rounded,
              color: AppColors.primary,
              dishes: mains,
            ),
            SizedBox(height: spacing * 0.75),
          ],

          // Desserts
          if (desserts.isNotEmpty) ...[
            _buildDishCategory(
              context,
              title: 'Desserts',
              icon: Icons.cake_rounded,
              color: AppColors.accent,
              dishes: desserts,
            ),
            SizedBox(height: spacing * 0.75),
          ],
        ],

        SizedBox(height: spacing),

        // Conditions
        if (menu.conditionsText.isNotEmpty) ...[
          Text(
            'Conditions',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: titleSize),
          ),
          SizedBox(height: spacing * 0.5),
          GlassCard(
            padding: EdgeInsets.all(
              context.fluidValue(minValue: 12, maxValue: 16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.info,
                  size: context.fluidValue(minValue: 18, maxValue: 22),
                ),
                SizedBox(width: spacing * 0.5),
                Expanded(
                  child: Text(
                    menu.conditionsText,
                    style: AppTextStyles.body.copyWith(
                      fontSize: context.fluidValue(minValue: 12, maxValue: 14),
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        SizedBox(height: spacing * 2),
      ],
    );
  }

  Widget _buildDishCategory(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<Dish> dishes,
  }) {
    final padding = context.fluidValue(minValue: 12, maxValue: 16);
    final iconSize = context.fluidValue(minValue: 20, maxValue: 26);
    final titleSize = context.fluidValue(minValue: 14, maxValue: 16);
    final nameSize = context.fluidValue(minValue: 13, maxValue: 15);
    final descSize = context.fluidValue(minValue: 11, maxValue: 13);
    final allergenSize = context.fluidValue(minValue: 9, maxValue: 11);
    final spacing = context.fluidValue(minValue: 8, maxValue: 12);

    return GlassCard(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la catégorie
          Row(
            children: [
              Container(
                width: iconSize * 1.5,
                height: iconSize * 1.5,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(iconSize * 0.4),
                ),
                child: Icon(icon, color: color, size: iconSize),
              ),
              SizedBox(width: spacing),
              Text(
                title,
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: titleSize,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.fluidValue(minValue: 8, maxValue: 10),
                  vertical: context.fluidValue(minValue: 3, maxValue: 4),
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${dishes.length}',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: allergenSize + 1,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: spacing),
          Divider(color: color.withValues(alpha: 0.2), height: 1),
          SizedBox(height: spacing),

          // Liste des plats
          ...dishes.asMap().entries.map((entry) {
            final index = entry.key;
            final dish = entry.value;
            final isLast = index == dishes.length - 1;

            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : spacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom du plat
                  Text(
                    dish.name,
                    style: AppTextStyles.body.copyWith(
                      fontSize: nameSize,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  // Description
                  if (dish.description.isNotEmpty) ...[
                    SizedBox(height: spacing * 0.3),
                    Text(
                      dish.description,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: descSize,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],

                  // Allergènes
                  if (dish.allergens.isNotEmpty) ...[
                    SizedBox(height: spacing * 0.4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: allergenSize + 2,
                          color: AppColors.danger.withValues(alpha: 0.7),
                        ),
                        ...dish.allergens.map(
                          (a) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.fluidValue(
                                minValue: 5,
                                maxValue: 6,
                              ),
                              vertical: context.fluidValue(
                                minValue: 2,
                                maxValue: 3,
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.danger.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              a.allergen,
                              style: AppTextStyles.caption.copyWith(
                                fontSize: allergenSize,
                                color: AppColors.danger,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Séparateur entre les plats (sauf le dernier)
                  if (!isLast) ...[
                    SizedBox(height: spacing),
                    Divider(
                      color: AppColors.glassBorder.withValues(alpha: 0.5),
                      height: 1,
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final buttonPadding = responsiveValue<EdgeInsets>(
      context,
      mobile: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      tablet: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      desktop: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
    );

    return Container(
      padding: EdgeInsets.all(context.isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prix par personne',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  PriceFormatter.formatPriceCompact(menu.basePrice),
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: AppColors.primary,
                    fontSize: context.isMobile ? 22 : 28,
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => _handleOrderClick(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: buttonPadding,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Commander',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: context.isMobile ? 14 : 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.fluidValue(minValue: 8, maxValue: 12),
        vertical: context.fluidValue(minValue: 4, maxValue: 6),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          fontSize: context.fluidValue(minValue: 10, maxValue: 12),
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
