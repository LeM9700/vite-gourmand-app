import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/utils/responsive.dart';
import '../models/menu_model.dart';
import '../menu_detail_page.dart';
import '../../auth/auth_page.dart';
import '../../orders/order_page.dart';
import '../../../core/storage/secure_storage.dart';

class MenuCard extends StatelessWidget {
  final MenuModel menu;

  const MenuCard({
    super.key,
    required this.menu,
  });

  Future<void> _handleOrderClick(BuildContext context) async {
    final storage = SecureStorage();
    var token = await storage.readToken();

    if (!context.mounted) return;

    if (token != null && token.isNotEmpty) {
      // User is logged in, go to Order Page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderPage(selectedMenu: menu),
        ),
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
    // Calcul fluide des dimensions basé sur la largeur d'écran
    final scale = context.scaleFactor;
    final screenWidth = context.screenWidth;
    
    // Hauteur d'image proportionnelle
    final imageHeight = context.fluidValue(minValue: 120, maxValue: 180);
    
    // Tailles de texte fluides
    final titleSize = context.fluidValue(minValue: 14, maxValue: 18);
    final descriptionSize = context.fluidValue(minValue: 11, maxValue: 14);
    final badgeSize = context.fluidValue(minValue: 10, maxValue: 13);
    final priceSize = context.fluidValue(minValue: 12, maxValue: 15);
    final metaSize = context.fluidValue(minValue: 10, maxValue: 13);
    
    // Padding et espacements fluides
    final cardPadding = context.fluidValue(minValue: 10, maxValue: 16);
    final spacing = context.fluidValue(minValue: 6, maxValue: 12);
    final smallSpacing = context.fluidValue(minValue: 4, maxValue: 8);
    
    // Taille des boutons et icônes
    final buttonSize = context.fluidValue(minValue: 32, maxValue: 44);
    final iconSize = context.fluidValue(minValue: 14, maxValue: 18);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image du menu
          GestureDetector(
             onTap: () async {
               final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MenuDetailPage(menu: menu),
                ),
              );
              
              if (result == 'order' && context.mounted) {
                _handleOrderClick(context);
              }
             },
             child: Container(
            height: imageHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              color: AppColors.surface,
              image: menu.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(menu.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: menu.imageUrl == null
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.3),
                          AppColors.accent.withValues(alpha: 0.2),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.restaurant_menu,
                        size: context.fluidValue(minValue: 32, maxValue: 48),
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : null,
          ),
          ),
          
          // Contenu de la carte
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre du menu
                  Text(
                    menu.title,
                    style: AppTextStyles.cardTitle.copyWith(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: smallSpacing),
                  
                  // Description
                  Text(
                    menu.description,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: descriptionSize,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: spacing),
                  
                  // Thème et régime
                  Wrap(
                    spacing: smallSpacing,
                    runSpacing: smallSpacing,
                    children: [
                      if (menu.theme.isNotEmpty)
                        _buildBadge(menu.theme, AppColors.accent, badgeSize),
                      if (menu.regime.isNotEmpty)
                        _buildBadge(menu.regime, AppColors.success, badgeSize),
                    ],
                  ),
                  
                  SizedBox(height: spacing),
                  
                  // Prix
                  if (menu.basePrice > 0)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.fluidValue(minValue: 8, maxValue: 12),
                        vertical: context.fluidValue(minValue: 4, maxValue: 6),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${menu.basePrice.toStringAsFixed(0)}€',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: priceSize,
                        ),
                      ),
                    ),
                  
                  const Spacer(),
                  
                  // Informations personnes et plats
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: iconSize,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: smallSpacing),
                      Flexible(
                        child: Text(
                          'Min ${menu.minPeople} pers.',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: metaSize,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: smallSpacing),
                  
                  if (menu.dishes.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.restaurant,
                          size: iconSize,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: smallSpacing),
                        Text(
                          '${menu.dishes.length} plat${menu.dishes.length > 1 ? 's' : ''}',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: metaSize,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  
                  SizedBox(height: spacing),
                  
                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ActionButton(
                        icon: Icons.visibility,
                        size: buttonSize,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MenuDetailPage(menu: menu),
                            ),
                          );
                        },
                      ),
                      _ActionButton(
                        icon: Icons.shopping_cart,
                        size: buttonSize,
                        onTap: () => _handleOrderClick(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color, double fontSize) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.6,
        vertical: fontSize * 0.25,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          fontSize: fontSize,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(size / 2),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: size * 0.5,
          color: AppColors.primary,
        ),
      ),
    );
  }
}