import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/utils/responsive.dart';

class MenuFiltersOverlay extends StatefulWidget {
  final double? maxPrice;
  final String? theme;
  final String? regime;
  final int? minPeopleMax;
  final List<String> availableThemes;
  final List<String> availableRegimes;
  final ValueChanged<MenuFilters> onApply;
  final VoidCallback onReset;

  const MenuFiltersOverlay({
    super.key,
    this.maxPrice,
    this.theme,
    this.regime,
    this.minPeopleMax,
    required this.availableThemes,
    required this.availableRegimes,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<MenuFiltersOverlay> createState() => _MenuFiltersOverlayState();
}

class _MenuFiltersOverlayState extends State<MenuFiltersOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late double _maxPrice;
  late String? _selectedTheme;
  late String? _selectedRegime;
  late int _minPeopleMax;

  @override
  void initState() {
    super.initState();

    // Initialiser les valeurs
    _maxPrice = widget.maxPrice ?? 100.0;
    _selectedTheme = widget.theme;
    _selectedRegime = widget.regime;
    _minPeopleMax = widget.minPeopleMax ?? 10;

    // Configuration des animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Démarrer l'animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await _controller.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _apply() {
    widget.onApply(
      MenuFilters(
        maxPrice: _maxPrice,
        theme: _selectedTheme,
        regime: _selectedRegime,
        minPeopleMax: _minPeopleMax,
      ),
    );
    _close();
  }

  void _reset() {
    setState(() {
      _maxPrice = 100.0;
      _selectedTheme = null;
      _selectedRegime = null;
      _minPeopleMax = 10;
    });
    widget.onReset();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.horizontalPadding;
    final isSmallScreen = context.isSmallScreen;
    final maxContentWidth = context.maxContentWidth.clamp(0, 700).toDouble();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: _close,
        child: Container(
          color: Colors.black.withValues(alpha: 0.5),
          child: GestureDetector(
            onTap: () {}, // Empêche la fermeture au clic sur le contenu
            child: SlideTransition(
              position: _slideAnimation,
              child: Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.only(
                      left: horizontalPadding,
                      right: horizontalPadding,
                      top: MediaQuery.of(context).padding.top + 16,
                    ),
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppColors.glassBorder,
                                width: 1,
                              ),
                              boxShadow: AppShadows.dramatic,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // En-tête
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: AppColors.glassBorder,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.tune,
                                          color: AppColors.primary,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          'Filtrer les menus',
                                          style: AppTextStyles.sectionTitle
                                              .copyWith(fontSize: 22),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        color: AppColors.textSecondary,
                                        onPressed: _close,
                                      ),
                                    ],
                                  ),
                                ),

                                // Contenu des filtres
                                Container(
                                  padding: EdgeInsets.all(
                                    isSmallScreen ? 20 : 24,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Prix maximum
                                      _buildFilterSection(
                                        icon: Icons.euro,
                                        title: 'Prix maximum',
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 8),
                                            Text(
                                              '${_maxPrice.toInt()}€ par personne',
                                              style: AppTextStyles.cardTitle
                                                  .copyWith(
                                                    color: AppColors.primary,
                                                    fontSize: 18,
                                                  ),
                                            ),
                                            const SizedBox(height: 12),
                                            SliderTheme(
                                              data: SliderThemeData(
                                                activeTrackColor:
                                                    AppColors.primary,
                                                inactiveTrackColor:
                                                    AppColors.lightGrey,
                                                thumbColor: AppColors.primary,
                                                overlayColor: AppColors.primary
                                                    .withValues(alpha: 0.2),
                                                trackHeight: 4,
                                              ),
                                              child: Slider(
                                                value: _maxPrice,
                                                min: 20,
                                                max: 200,
                                                divisions: 36,
                                                onChanged: (value) {
                                                  setState(
                                                    () => _maxPrice = value,
                                                  );
                                                },
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  '20€',
                                                  style: AppTextStyles.caption,
                                                ),
                                                Text(
                                                  '200€',
                                                  style: AppTextStyles.caption,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 24),

                                      // Thème
                                      _buildFilterSection(
                                        icon: Icons.palette,
                                        title: 'Thème',
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 12),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children:
                                                  widget.availableThemes.map((
                                                    theme,
                                                  ) {
                                                    final isSelected =
                                                        _selectedTheme == theme;
                                                    return ChoiceChip(
                                                      label: Text(theme),
                                                      selected: isSelected,
                                                      onSelected: (selected) {
                                                        setState(() {
                                                          _selectedTheme =
                                                              selected
                                                                  ? theme
                                                                  : null;
                                                        });
                                                      },
                                                      backgroundColor:
                                                          AppColors.glassFill,
                                                      selectedColor: AppColors
                                                          .primary
                                                          .withValues(
                                                            alpha: 0.2,
                                                          ),
                                                      labelStyle: AppTextStyles
                                                          .body
                                                          .copyWith(
                                                            color:
                                                                isSelected
                                                                    ? AppColors
                                                                        .primary
                                                                    : AppColors
                                                                        .textPrimary,
                                                            fontWeight:
                                                                isSelected
                                                                    ? FontWeight
                                                                        .w600
                                                                    : FontWeight
                                                                        .w400,
                                                          ),
                                                      side: BorderSide(
                                                        color:
                                                            isSelected
                                                                ? AppColors
                                                                    .primary
                                                                : AppColors
                                                                    .glassBorder,
                                                        width:
                                                            isSelected
                                                                ? 1.5
                                                                : 1,
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                    );
                                                  }).toList(),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 24),

                                      // Régime
                                      _buildFilterSection(
                                        icon: Icons.restaurant_menu,
                                        title: 'Régime alimentaire',
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 12),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children:
                                                  widget.availableRegimes.map((
                                                    regime,
                                                  ) {
                                                    final isSelected =
                                                        _selectedRegime ==
                                                        regime;
                                                    return ChoiceChip(
                                                      label: Text(regime),
                                                      selected: isSelected,
                                                      onSelected: (selected) {
                                                        setState(() {
                                                          _selectedRegime =
                                                              selected
                                                                  ? regime
                                                                  : null;
                                                        });
                                                      },
                                                      backgroundColor:
                                                          AppColors.glassFill,
                                                      selectedColor: AppColors
                                                          .primary
                                                          .withValues(
                                                            alpha: 0.2,
                                                          ),
                                                      labelStyle: AppTextStyles
                                                          .body
                                                          .copyWith(
                                                            color:
                                                                isSelected
                                                                    ? AppColors
                                                                        .primary
                                                                    : AppColors
                                                                        .textPrimary,
                                                            fontWeight:
                                                                isSelected
                                                                    ? FontWeight
                                                                        .w600
                                                                    : FontWeight
                                                                        .w400,
                                                          ),
                                                      side: BorderSide(
                                                        color:
                                                            isSelected
                                                                ? AppColors
                                                                    .primary
                                                                : AppColors
                                                                    .glassBorder,
                                                        width:
                                                            isSelected
                                                                ? 1.5
                                                                : 1,
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                    );
                                                  }).toList(),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 24),

                                      // Nombre de personnes minimum
                                      _buildFilterSection(
                                        icon: Icons.people,
                                        title: 'Nombre de personnes minimum',
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 8),
                                            Text(
                                              '$_minPeopleMax personnes max',
                                              style: AppTextStyles.cardTitle
                                                  .copyWith(
                                                    color: AppColors.primary,
                                                    fontSize: 18,
                                                  ),
                                            ),
                                            const SizedBox(height: 12),
                                            SliderTheme(
                                              data: SliderThemeData(
                                                activeTrackColor:
                                                    AppColors.primary,
                                                inactiveTrackColor:
                                                    AppColors.lightGrey,
                                                thumbColor: AppColors.primary,
                                                overlayColor: AppColors.primary
                                                    .withValues(alpha: 0.2),
                                                trackHeight: 4,
                                              ),
                                              child: Slider(
                                                value: _minPeopleMax.toDouble(),
                                                min: 2,
                                                max: 50,
                                                divisions: 48,
                                                onChanged: (value) {
                                                  setState(
                                                    () =>
                                                        _minPeopleMax =
                                                            value.toInt(),
                                                  );
                                                },
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  '2 pers',
                                                  style: AppTextStyles.caption,
                                                ),
                                                Text(
                                                  '50 pers',
                                                  style: AppTextStyles.caption,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Actions
                                Container(
                                  padding: EdgeInsets.all(
                                    isSmallScreen ? 20 : 24,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: AppColors.glassBorder,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: _reset,
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor:
                                                AppColors.textSecondary,
                                            side: const BorderSide(
                                              color: AppColors.glassBorder,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            'Réinitialiser',
                                            style:
                                                AppTextStyles.buttonSecondary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        flex: 2,
                                        child: PrimaryButton(
                                          label: 'Appliquer',
                                          onPressed: _apply,
                                          height: 52,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTextStyles.subtitle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        child,
      ],
    );
  }
}

class MenuFilters {
  final double maxPrice;
  final String? theme;
  final String? regime;
  final int minPeopleMax;

  MenuFilters({
    required this.maxPrice,
    this.theme,
    this.regime,
    required this.minPeopleMax,
  });

  Map<String, dynamic> toQueryParameters() {
    final Map<String, dynamic> params = {
      'max_price': maxPrice.toString(),
      'min_people_max': minPeopleMax.toString(),
      'active_only': 'true',
    };

    if (theme != null && theme!.isNotEmpty) {
      params['theme'] = theme;
    }
    if (regime != null && regime!.isNotEmpty) {
      params['regime'] = regime;
    }

    return params;
  }

  bool get hasActiveFilters =>
      theme != null || regime != null || maxPrice < 200 || minPeopleMax < 50;
}
