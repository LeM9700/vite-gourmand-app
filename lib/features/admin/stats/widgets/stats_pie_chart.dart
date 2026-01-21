import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

/// Widget de graphique camembert premium
class StatsPieChart extends StatefulWidget {
  final List<PieChartSectionData> sections;
  final String title;
  final String? subtitle;

  const StatsPieChart({
    super.key,
    required this.sections,
    required this.title,
    this.subtitle,
  });

  @override
  State<StatsPieChart> createState() => _StatsPieChartState();

  /// Crée des sections de camembert à partir de données simples
  static List<PieChartSectionData> createSections({
    required List<double> values,
    required List<String> labels,
    List<Color>? colors,
  }) {
    final defaultColors = [
      AppColors.primary,
      AppColors.info,
      AppColors.success,
      AppColors.warning,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
    ];

    final total = values.fold(0.0, (sum, value) => sum + value);

    return List.generate(values.length, (index) {
      final percentage = (values[index] / total * 100).toStringAsFixed(1);
      final color = colors != null && index < colors.length
          ? colors[index]
          : defaultColors[index % defaultColors.length];

      return PieChartSectionData(
        color: color,
        value: values[index],
        title: '$percentage%',
        radius: 110,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: _Badge(
          label: labels[index],
          color: color,
        ),
        badgePositionPercentageOffset: 1.3,
      );
    });
  }
}

class _StatsPieChartState extends State<StatsPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontFamily: 'Playfair Display',
                ),
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.subtitle!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Chart
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: PieChart(
              PieChartData(
                sections: widget.sections.map((section) {
                  final isTouched = widget.sections.indexOf(section) == _touchedIndex;
                  final radius = isTouched ? 130.0 : 110.0;
                  final fontSize = isTouched ? 18.0 : 14.0;
                  
                  return PieChartSectionData(
                    color: section.color,
                    value: section.value,
                    title: section.title,
                    radius: radius,
                    titleStyle: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    badgeWidget: isTouched ? section.badgeWidget : null,
                    badgePositionPercentageOffset: 1.3,
                  );
                }).toList(),
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 50,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Badge pour afficher le label à l'extérieur du camembert
class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
