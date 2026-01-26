import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/responsive.dart';
import 'orders/employee_orders_list_page.dart';
import 'moderation/moderation_page.dart';
import 'management/management_page.dart';
import 'settings/employee_settings_page.dart';

/// Page principale avec navigation bubble pour employés
class EmployeeNavigationPage extends StatefulWidget {
  final int initialIndex;

  const EmployeeNavigationPage({super.key, this.initialIndex = 0});

  @override
  State<EmployeeNavigationPage> createState() => _EmployeeNavigationPageState();
}

class _EmployeeNavigationPageState extends State<EmployeeNavigationPage> {
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
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          EmployeeOrdersListPage(),
          ModerationPage(),
          ManagementPage(),
          EmployeeSettingsPage(),
        ],
      ),
      bottomNavigationBar: _buildBubbleNavBar(context),
    );
  }

  Widget _buildBubbleNavBar(BuildContext context) {
    // Tailles responsives
    final navHeight = context.fluidValue(minValue: 70, maxValue: 80);
    final iconSize = context.fluidValue(minValue: 24, maxValue: 28);
    final fontSize = context.fluidValue(minValue: 10, maxValue: 12);
    final bubbleSize = context.fluidValue(minValue: 56, maxValue: 64);
    final horizontalPadding = context.fluidValue(minValue: 16, maxValue: 32);

    return Container(
      height: navHeight,
      margin: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: context.fluidValue(minValue: 12, maxValue: 16),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.dark.withValues(alpha: 0.95),
            AppColors.darkGrey.withValues(alpha: 0.98),
          ],
        ),
        borderRadius: BorderRadius.circular(navHeight / 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            offset: const Offset(0, 4),
            blurRadius: 20,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context,
            icon: Icons.shopping_bag_outlined,
            activeIcon: Icons.shopping_bag,
            label: 'Commandes',
            index: 0,
            iconSize: iconSize,
            fontSize: fontSize,
            bubbleSize: bubbleSize,
          ),
          _buildNavItem(
            context,
            icon: Icons.rate_review_outlined,
            activeIcon: Icons.rate_review,
            label: 'SAV',
            index: 1,
            iconSize: iconSize,
            fontSize: fontSize,
            bubbleSize: bubbleSize,
          ),
          _buildNavItem(
            context,
            icon: Icons.restaurant_menu_outlined,
            activeIcon: Icons.restaurant_menu,
            label: 'Gestion',
            index: 2,
            iconSize: iconSize,
            fontSize: fontSize,
            bubbleSize: bubbleSize,
          ),
          _buildNavItem(
            context,
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: 'Profil',
            index: 3,
            iconSize: iconSize,
            fontSize: fontSize,
            bubbleSize: bubbleSize,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required double iconSize,
    required double fontSize,
    required double bubbleSize,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bubble avec animation
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: isSelected ? bubbleSize : bubbleSize * 0.7,
                height: isSelected ? bubbleSize : bubbleSize * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient:
                      isSelected
                          ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.8),
                            ],
                          )
                          : null,
                  color: isSelected ? null : Colors.transparent,
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              offset: const Offset(0, 4),
                              blurRadius: 12,
                              spreadRadius: 0,
                            ),
                          ]
                          : null,
                ),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  color:
                      isSelected
                          ? AppColors.dark
                          : AppColors.textLight.withValues(alpha: 0.6),
                  size: isSelected ? iconSize : iconSize * 0.85,
                ),
              ),
              SizedBox(height: context.fluidValue(minValue: 4, maxValue: 6)),
              // Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                style: AppTextStyles.caption.copyWith(
                  fontSize: fontSize,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color:
                      isSelected
                          ? AppColors.primary
                          : AppColors.textLight.withValues(alpha: 0.6),
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
