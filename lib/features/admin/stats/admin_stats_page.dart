import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/glass_card.dart';
import '../services/admin_service.dart';
import 'models/stats_models.dart';
import 'widgets/date_range_picker.dart';
import 'widgets/stats_bar_chart.dart';
import 'widgets/stats_line_chart.dart';
import 'widgets/stats_pie_chart.dart';

/// Page des statistiques admin avec graphiques interchangeables
class AdminStatsPage extends StatefulWidget {
  const AdminStatsPage({super.key});

  @override
  State<AdminStatsPage> createState() => _AdminStatsPageState();
}

class _AdminStatsPageState extends State<AdminStatsPage>
    with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();

  // État du chargement
  bool _isLoading = false;
  String _errorMessage = '';

  // Dates
  late DateTime _startDate;
  late DateTime _endDate;

  // Type de graphique
  ChartType _chartType = ChartType.bar;

  // Données
  OrdersByMenuData? _ordersByMenuData;
  RevenueByMenuData? _revenueByMenuData;
  MenuComparisonData? _comparisonData;

  // Tab controller pour les sections
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Par défaut : 30 derniers jours
    _endDate = DateTime.now();
    _startDate = _endDate.subtract(const Duration(days: 30));

    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final startStr = DateFormatter.formatDateISO(_startDate);
    final endStr = DateFormatter.formatDateISO(_endDate);

    try {
      debugPrint('📊 Chargement des stats : $startStr → $endStr');

      final results = await Future.wait([
        _adminService.getOrdersByMenu(startDate: startStr, endDate: endStr),
        _adminService.getRevenueByMenu(startDate: startStr, endDate: endStr),
        _adminService.getMenuComparison(startDate: startStr, endDate: endStr),
      ]);

      debugPrint('📊 Données reçues :');
      debugPrint('  - Orders: ${results[0]}');
      debugPrint('  - Revenue: ${results[1]}');
      debugPrint('  - Comparison: ${results[2]}');

      if (mounted) {
        setState(() {
          _ordersByMenuData = OrdersByMenuData.fromJson(results[0]);
          _revenueByMenuData = RevenueByMenuData.fromJson(results[1]);
          _comparisonData = MenuComparisonData.fromJson(results[2]);
          _isLoading = false;
        });

        debugPrint('📊 Stats parsées :');
        debugPrint('  - Orders menus: ${_ordersByMenuData?.menus.length ?? 0}');
        debugPrint('  - Revenue data: ${_revenueByMenuData?.data.length ?? 0}');
        debugPrint(
          '  - Comparison menus: ${_comparisonData?.menus.length ?? 0}',
        );
      }
    } catch (e) {
      debugPrint('❌ Erreur chargement stats: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _onDateRangeChanged(DateTime start, DateTime end) {
    setState(() {
      _startDate = start;
      _endDate = end;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // App Bar avec gradient
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                      AppColors.cardBackground.withValues(alpha: 0.9),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.analytics_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Statistiques',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'Playfair Display',
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Analyses et graphiques de performance',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
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
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Date Range Picker
                  DateRangePicker(
                    startDate: _startDate,
                    endDate: _endDate,
                    onDateRangeSelected: _onDateRangeChanged,
                  ),
                  const SizedBox(height: 16),

                  // Sélecteur de type de graphique
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.insert_chart_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Type de graphique :',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: ChartType.values.map((type) {
                                  final isSelected = _chartType == type;
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _chartType = type;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primary.withValues(
                                                  alpha: 0.2,
                                                )
                                              : Colors.white.withValues(
                                                  alpha: 0.05,
                                                ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.primary
                                                : Colors.white.withValues(
                                                    alpha: 0.2,
                                                  ),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              type.icon,
                                              size: 16,
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : AppColors.textSecondary,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              type.label,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tabs pour les sections
                  GlassCard(
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.primary,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      isScrollable: true,
                      tabAlignment: TabAlignment.center,
                      labelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                      tabs: const [
                        Tab(text: 'Commandes'),
                        Tab(text: 'Revenus'),
                        Tab(text: 'Comparaison'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Graphiques
                  if (_isLoading)
                    const SizedBox(
                      height: 400,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    )
                  else if (_errorMessage.isNotEmpty)
                    SizedBox(
                      height: 400,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 64,
                              color: Colors.red.withValues(alpha: 0.7),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _loadData,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Réessayer'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 400,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOrdersChart(),
                          _buildRevenueChart(),
                          _buildComparisonChart(),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersChart() {
    if (_ordersByMenuData == null || _ordersByMenuData!.menus.isEmpty) {
      return _buildEmptyState('Aucune donnée de commandes');
    }

    final menus = _ordersByMenuData!.menus;

    switch (_chartType) {
      case ChartType.bar:
        return GlassCard(
          child: StatsBarChart(
            title: 'Commandes par menu',
            subtitle:
                '${_ordersByMenuData!.totalOrders} commandes - ${PriceFormatter.formatPrice(_ordersByMenuData!.totalRevenue)}',
            barGroups: StatsBarChart.createBars(
              values: menus.map((m) => m.ordersCount.toDouble()).toList(),
              color: AppColors.info,
            ),
            maxY: (menus
                        .map((m) => m.ordersCount)
                        .reduce((a, b) => a > b ? a : b) *
                    1.2)
                .toDouble(),
            getBottomTitles: (value) {
              if (value.toInt() >= menus.length) return '';
              return menus[value.toInt()].menuName ??
                  'Menu ${value.toInt() + 1}';
            },
          ),
        );

      case ChartType.line:
        return GlassCard(
          child: StatsLineChart(
            title: 'Commandes par menu',
            subtitle:
                '${_ordersByMenuData!.totalOrders} commandes - ${PriceFormatter.formatPrice(_ordersByMenuData!.totalRevenue)}',
            spots: StatsLineChart.createSpots(
              menus.map((m) => m.ordersCount.toDouble()).toList(),
            ),
            maxY: (menus
                        .map((m) => m.ordersCount)
                        .reduce((a, b) => a > b ? a : b) *
                    1.2)
                .toDouble(),
            lineColor: AppColors.info,
            getBottomTitles: (value) {
              if (value.toInt() >= menus.length) return '';
              return menus[value.toInt()].menuName ?? 'M${value.toInt() + 1}';
            },
          ),
        );

      case ChartType.pie:
        final pieValues = menus.map((m) => m.ordersCount.toDouble()).toList();
        final pieLabels =
            menus.map((m) => m.menuName ?? 'Menu ${m.menuId}').toList();
        return GlassCard(
          child: StatsPieChart(
            title: 'Répartition des commandes',
            subtitle: '${_ordersByMenuData!.totalOrders} commandes au total',
            sections: StatsPieChart.createSections(
              values: pieValues,
              labels: pieLabels,
            ),
          ),
        );
    }
  }

  Widget _buildRevenueChart() {
    if (_revenueByMenuData == null || _revenueByMenuData!.data.isEmpty) {
      return _buildEmptyState('Aucune donnée de chiffre d\'affaires');
    }

    final data = _revenueByMenuData!.data;

    switch (_chartType) {
      case ChartType.bar:
        return GlassCard(
          child: StatsBarChart(
            title: 'Chiffre d\'affaires par menu',
            subtitle:
                '${PriceFormatter.formatPrice(_revenueByMenuData!.totalRevenue)} - ${_revenueByMenuData!.totalOrders} commandes',
            barGroups: StatsBarChart.createBars(
              values: data.map((m) => m.periodRevenue).toList(),
              color: AppColors.success,
            ),
            maxY: (data
                        .map((m) => m.periodRevenue)
                        .reduce((a, b) => a > b ? a : b) *
                    1.2)
                .toDouble(),
            getBottomTitles: (value) {
              if (value.toInt() >= data.length) return '';
              return data[value.toInt()].menuName ??
                  'Menu ${value.toInt() + 1}';
            },
            getLeftTitles: (value) => '${value.toInt()}€',
          ),
        );

      case ChartType.line:
        return GlassCard(
          child: StatsLineChart(
            title: 'Chiffre d\'affaires par menu',
            subtitle:
                '${PriceFormatter.formatPrice(_revenueByMenuData!.totalRevenue)} - ${_revenueByMenuData!.totalOrders} commandes',
            spots: StatsLineChart.createSpots(
              data.map((m) => m.periodRevenue).toList(),
            ),
            maxY: (data
                        .map((m) => m.periodRevenue)
                        .reduce((a, b) => a > b ? a : b) *
                    1.2)
                .toDouble(),
            lineColor: AppColors.success,
            getBottomTitles: (value) {
              if (value.toInt() >= data.length) return '';
              return data[value.toInt()].menuName ?? 'M${value.toInt() + 1}';
            },
            getLeftTitles: (value) => '${value.toInt()}€',
          ),
        );

      case ChartType.pie:
        final pieValues = data.map((m) => m.periodRevenue).toList();
        final pieLabels =
            data.map((m) => m.menuName ?? 'Menu ${m.menuId}').toList();
        return GlassCard(
          child: StatsPieChart(
            title: 'Répartition du CA',
            subtitle:
                '${PriceFormatter.formatPrice(_revenueByMenuData!.totalRevenue)} au total',
            sections: StatsPieChart.createSections(
              values: pieValues,
              labels: pieLabels,
            ),
          ),
        );
    }
  }

  Widget _buildComparisonChart() {
    if (_comparisonData == null || _comparisonData!.menus.isEmpty) {
      return _buildEmptyState('Aucune donnée de comparaison');
    }

    final menus = _comparisonData!.menus;

    // Pour la comparaison, on utilise le revenue
    switch (_chartType) {
      case ChartType.bar:
        return GlassCard(
          child: StatsBarChart(
            title: 'Comparaison des menus',
            subtitle: '${_comparisonData!.totalMenus} menus analysés',
            barGroups: StatsBarChart.createBars(
              values: menus.map((m) => m.revenue).toList(),
              color: AppColors.warning,
            ),
            maxY: (menus.map((m) => m.revenue).reduce((a, b) => a > b ? a : b) *
                    1.2)
                .toDouble(),
            getBottomTitles: (value) {
              if (value.toInt() >= menus.length) return '';
              return menus[value.toInt()].menuName ??
                  'Menu ${value.toInt() + 1}';
            },
            getLeftTitles: (value) => '${value.toInt()}€',
          ),
        );

      case ChartType.line:
        return GlassCard(
          child: StatsLineChart(
            title: 'Comparaison des menus',
            subtitle: '${_comparisonData!.totalMenus} menus analysés',
            spots: StatsLineChart.createSpots(
              menus.map((m) => m.revenue).toList(),
            ),
            maxY: (menus.map((m) => m.revenue).reduce((a, b) => a > b ? a : b) *
                    1.2)
                .toDouble(),
            lineColor: AppColors.warning,
            getBottomTitles: (value) {
              if (value.toInt() >= menus.length) return '';
              return menus[value.toInt()].menuName ?? 'M${value.toInt() + 1}';
            },
            getLeftTitles: (value) => '${value.toInt()}€',
          ),
        );

      case ChartType.pie:
        final pieValues = menus.map((m) => m.revenue).toList();
        final pieLabels =
            menus.map((m) => m.menuName ?? 'Menu ${m.menuId}').toList();
        return GlassCard(
          child: StatsPieChart(
            title: 'Répartition globale',
            subtitle: '${_comparisonData!.totalMenus} menus',
            sections: StatsPieChart.createSections(
              values: pieValues,
              labels: pieLabels,
            ),
          ),
        );
    }
  }

  Widget _buildEmptyState(String message) {
    return GlassCard(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart_rounded,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
