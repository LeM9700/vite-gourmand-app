import 'package:flutter/material.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../menus/menus_list_page.dart';
import '../../auth/auth_page.dart';
import '../../contact/contact_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Sidebar desktop seulement sur grands écrans (>= 1024px)
    final isDesktopSidebar = context.isLargeDesktop;
    
    // Tailles fluides
    final titleSize = context.fluidValue(minValue: 14, maxValue: 18);
    final labelSize = context.fluidValue(minValue: 13, maxValue: 16);
    final iconSize = context.fluidValue(minValue: 20, maxValue: 24);
    final padding = context.fluidValue(minValue: 12, maxValue: 20);
    
    // Sur desktop, c'est une sidebar permanente
    if (isDesktopSidebar) {
      return Container(
        color: Colors.black.withOpacity(0.85),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo ou titre
                Center(
                  child: Container(
                    padding: EdgeInsets.all(padding),
                    child: Text(
                      'Vite & Gourmand',
                      style: AppTextStyles.sectionTitle.copyWith(
                        color: Colors.white,
                        fontSize: titleSize,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: padding),
                const Divider(color: Colors.white24),
                SizedBox(height: padding * 0.8),
                
                _DesktopNavItem(
                  icon: Icons.home,
                  label: 'Accueil',
                  isSelected: true,
                  iconSize: iconSize,
                  labelSize: labelSize,
                  onTap: () {},
                ),
                _DesktopNavItem(
                  icon: Icons.restaurant_menu,
                  label: 'Nos Menus',
                  iconSize: iconSize,
                  labelSize: labelSize,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MenusListPage(),
                      ),
                    );
                  },
                ),
                _DesktopNavItem(
                  icon: Icons.login,
                  label: 'Connexion',
                  iconSize: iconSize,
                  labelSize: labelSize,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AuthPage(initialLoginTab: true),
                      ),
                    );
                  },
                ),
                _DesktopNavItem(
                  icon: Icons.mail,
                  label: 'Contact',
                  iconSize: iconSize,
                  labelSize: labelSize,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ContactPage(),
                      ),
                    );
                  },
                ),

                const Spacer(),
                const Divider(color: Colors.white24),
                SizedBox(height: padding * 0.6),
                Center(
                  child: Text(
                    '© 2026 Vite & Gourmand',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white54,
                      fontSize: context.fluidValue(minValue: 10, maxValue: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Version mobile/tablet : Drawer classique avec tailles fluides
    return Drawer(
      backgroundColor: Colors.black.withOpacity(0.65),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Menu',
                  style: AppTextStyles.sectionTitle.copyWith(
                    fontSize: context.fluidValue(minValue: 18, maxValue: 24),
                  ),
                ),
                SizedBox(height: padding),

                _Item(
                  icon: Icons.home,
                  label: 'Accueil',
                  iconSize: iconSize,
                  labelSize: labelSize,
                  onTap: () => Navigator.pop(context),
                ),
                _Item(
                  icon: Icons.restaurant_menu,
                  label: 'Menus',
                  iconSize: iconSize,
                  labelSize: labelSize,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MenusListPage(),
                      ),
                    );
                  },
                ),
                _Item(
                  icon: Icons.login,
                  label: 'Connexion',
                  iconSize: iconSize,
                  labelSize: labelSize,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AuthPage(initialLoginTab: true),
                      ),
                    );
                  },
                ),
                _Item(
                  icon: Icons.mail,
                  label: 'Contact',
                  iconSize: iconSize,
                  labelSize: labelSize,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ContactPage(),
                      ),
                    );
                  },
                ),

                const Spacer(),
                Text('© Vite & Gourmand', style: AppTextStyles.caption),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;
  final double iconSize;
  final double labelSize;
  final double padding;

  const _DesktopNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.iconSize = 22,
    this.labelSize = 14,
    this.padding = 12,
  });

  @override
  State<_DesktopNavItem> createState() => _DesktopNavItemState();
}

class _DesktopNavItemState extends State<_DesktopNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(bottom: widget.padding * 0.5),
          padding: EdgeInsets.symmetric(
            horizontal: widget.padding * 1.2,
            vertical: widget.padding,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.primary.withOpacity(0.2)
                : _isHovered
                    ? Colors.white.withOpacity(0.1)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: widget.isSelected
                ? Border.all(color: AppColors.primary.withOpacity(0.5))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: widget.isSelected ? AppColors.primary : Colors.white70,
                size: widget.iconSize,
              ),
              SizedBox(width: widget.padding),
              Text(
                widget.label,
                style: AppTextStyles.body.copyWith(
                  fontSize: widget.labelSize,
                  color: widget.isSelected ? Colors.white : Colors.white70,
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double iconSize;
  final double labelSize;

  const _Item({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconSize = 22,
    this.labelSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.white, size: iconSize),
      title: Text(
        label,
        style: AppTextStyles.body.copyWith(fontSize: labelSize),
      ),
      onTap: onTap,
    );
  }
}
