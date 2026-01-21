import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/responsive.dart';
import 'dashboard/admin_dashboard_page.dart';
import 'employees/employees_management_page.dart';
import 'stats/admin_stats_page.dart';
import 'management/admin_management_page.dart';
import 'settings/admin_settings_page.dart';

/// Page principale avec navigation bubble PREMIUM pour administrateurs
/// Navigation ultra classe avec 5 sections : Dashboard, Employés, Stats, Management, Paramètres
class AdminNavigationPage extends StatefulWidget {
  final int initialIndex;

  const AdminNavigationPage({super.key, this.initialIndex = 0});

  @override
  State<AdminNavigationPage> createState() => _AdminNavigationPageState();
}

class _AdminNavigationPageState extends State<AdminNavigationPage> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }
  /// Navigate to a specific page, optionally with a tab index for Management page
  void _navigateToPage(int pageIndex, {int? tabIndex}) {
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    
    // Si on navigue vers la page Management (index 3) avec un tabIndex spécifique
    // on doit recréer la page avec le bon initialTabIndex
    // Pour l'instant on utilise setState pour forcer le rebuild
    if (pageIndex == 3 && tabIndex != null) {
      setState(() {
        _managementTabIndex = tabIndex;
      });
    }
  }

  int _managementTabIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          AdminDashboardPage(
            onNavigateToPage: _navigateToPage,
          ),
          const EmployeesManagementPage(),
          const AdminStatsPage(),
          AdminManagementPage(
            key: ValueKey('management_tab_$_managementTabIndex'),
            initialTabIndex: _managementTabIndex,
          ),
          const AdminSettingsPage(),
        ],
      ),
      bottomNavigationBar: _buildBubbleNavBar(context),
    );
  }

  Widget _buildBubbleNavBar(BuildContext context) {
    final isMobile = context.isMobile;
    
    // Tailles responsives PREMIUM
    final navHeight = context.fluidValue(minValue: 95, maxValue: 110); // Plus grand pour accommoder labels
    final iconSize = context.fluidValue(minValue: 26, maxValue: 32); // Icônes plus grandes
    final bubbleSize = context.fluidValue(minValue: 60, maxValue: 72); // Bulles XL

    return Container(
      height: navHeight,
      margin: EdgeInsets.all(isMobile ? 12 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.dark,
            AppColors.darkGrey,
            AppColors.dark.withValues(alpha: 0.95),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(navHeight / 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 24,
          vertical: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context: context,
              icon: Icons.dashboard_rounded,
              label: 'Dashboard',
              index: 0,
              iconSize: iconSize,
              bubbleSize: bubbleSize,
            ),
            _buildNavItem(
              context: context,
              icon: Icons.people_alt_rounded,
              label: 'Employés',
              index: 1,
              iconSize: iconSize,
              bubbleSize: bubbleSize,
            ),
            _buildNavItem(
              context: context,
              icon: Icons.analytics_rounded,
              label: 'Stats',
              index: 2,
              iconSize: iconSize,
              bubbleSize: bubbleSize,
            ),
            _buildNavItem(
              context: context,
              icon: Icons.admin_panel_settings_rounded,
              label: 'Gestion',
              index: 3,
              iconSize: iconSize,
              bubbleSize: bubbleSize,
            ),
            _buildNavItem(
              context: context,
              icon: Icons.settings_rounded,
              label: 'Réglages',
              index: 4,
              iconSize: iconSize,
              bubbleSize: bubbleSize,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required double iconSize,
    required double bubbleSize,
  }) {
    final isSelected = _currentIndex == index;
    final isMobile = context.isMobile;
    
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bubble ULTRA PREMIUM avec effet de profondeur
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              width: isSelected ? bubbleSize * 1.15 : bubbleSize,
              height: isSelected ? bubbleSize * 1.15 : bubbleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.95),
                          AppColors.primary,
                          const Color(0xFFC5A028),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.glassFill.withValues(alpha: 0.3),
                          AppColors.glassFill.withValues(alpha: 0.15),
                        ],
                      ),
                border: Border.all(
                  color: isSelected
                      ? AppColors.champagne.withValues(alpha: 0.6)
                      : AppColors.glassBorder.withValues(alpha: 0.3),
                  width: isSelected ? 2.5 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: AppColors.champagne.withValues(alpha: 0.3),
                          blurRadius: 12,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: isSelected ? iconSize * 1.1 : iconSize,
                    color: isSelected ? AppColors.dark : AppColors.textLight.withValues(alpha: 0.7),
                  ),
                  child: Icon(
                    icon,
                    size: isSelected ? iconSize * 1.1 : iconSize,
                    color: isSelected ? AppColors.dark : AppColors.textLight.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Label avec animation fluide
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              style: AppTextStyles.caption.copyWith(
                fontSize: isMobile ? 10 : 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected 
                    ? AppColors.primary 
                    : AppColors.textLight.withValues(alpha: 0.6),
                letterSpacing: isSelected ? 0.8 : 0.3,
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
