import 'package:flutter/material.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/api/dio_client.dart';
import '../../legal/pages/legal_notice_page.dart';
import '../../legal/pages/terms_conditions_page.dart';

class HomeSectionFooter extends StatefulWidget {
  const HomeSectionFooter({super.key});

  @override
  State<HomeSectionFooter> createState() => _HomeSectionFooterState();
}

class _HomeSectionFooterState extends State<HomeSectionFooter> {
  List<Map<String, dynamic>> _schedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    try {
      final dio = await DioClient.create();
      final response = await dio.dio.get('/schedules');
      setState(() {
        _schedules = List<Map<String, dynamic>>.from(response.data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getDayLabel(int day) {
    const days = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];
    return days[day];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 550;

    final padding = context.fluidValue(minValue: 16, maxValue: 24);
    final spacing = context.fluidValue(minValue: 12, maxValue: 24);
    final titleSize = context.fluidValue(minValue: 14, maxValue: 16);
    final bodySize = context.fluidValue(minValue: 12, maxValue: 13);
    final logoSize = context.fluidValue(minValue: 50, maxValue: 80);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.dark, AppColors.truffle, AppColors.caviar],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.dark.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Section Horaires et Liens - Responsive Column/Row
          isSmallScreen
              ? Column(
                children: [
                  _buildScheduleSection(context, titleSize, bodySize),
                  SizedBox(height: spacing),
                  _buildLinksSection(context, padding, titleSize, bodySize),
                ],
              )
              : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildScheduleSection(context, titleSize, bodySize),
                  ),
                  SizedBox(width: spacing),
                  Expanded(
                    flex: 2,
                    child: _buildLinksSection(
                      context,
                      padding,
                      titleSize,
                      bodySize,
                    ),
                  ),
                ],
              ),

          SizedBox(height: spacing * 1.3),

          // Logo centré
          Container(
            padding: EdgeInsets.all(padding * 0.85),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Logo image
                Image.asset(
                  'assets/images/logo.png',
                  height: logoSize,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),

          SizedBox(height: spacing * 0.7),

          // Copyright/Info
          Text(
            'Traiteur événementiel depuis 2001',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: context.fluidValue(minValue: 10, maxValue: 12),
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: spacing * 0.35),

          // Version ou autres infos
          Text(
            '© 2026 Vite & Gourmand - Tous droits réservés',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: context.fluidValue(minValue: 9, maxValue: 10),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection(
    BuildContext context,
    double titleSize,
    double bodySize,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Horaires :',
          style: AppTextStyles.body.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: titleSize,
          ),
        ),
        SizedBox(height: context.fluidValue(minValue: 8, maxValue: 12)),
        ..._buildScheduleItems(context, bodySize),
      ],
    );
  }

  Widget _buildLinksSection(
    BuildContext context,
    double padding,
    double titleSize,
    double bodySize,
  ) {
    final buttonHeight = context.fluidValue(minValue: 36, maxValue: 42);

    return Container(
      padding: EdgeInsets.all(padding * 0.7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Liens',
            style: AppTextStyles.body.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: titleSize,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.fluidValue(minValue: 12, maxValue: 16)),

          SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LegalNoticePage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.textPrimary,
                elevation: 2,
                padding: EdgeInsets.symmetric(horizontal: padding * 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                'Mentions légales',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: bodySize,
                ),
              ),
            ),
          ),
          SizedBox(height: context.fluidValue(minValue: 8, maxValue: 10)),
          SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TermsConditionsPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.textPrimary,
                elevation: 2,
                padding: EdgeInsets.symmetric(horizontal: padding * 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                'CGV',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: bodySize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildScheduleItems(BuildContext context, double fontSize) {
    if (_isLoading) {
      return [
        Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ];
    }

    if (_schedules.isEmpty) {
      return [
        Text(
          'Horaires non disponibles',
          style: AppTextStyles.caption.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: fontSize,
          ),
        ),
      ];
    }

    final dayWidth = context.fluidValue(minValue: 55, maxValue: 70);

    // Trier par day_of_week pour avoir les jours dans l'ordre
    final sortedSchedules = List<Map<String, dynamic>>.from(_schedules)..sort(
      (a, b) => (a['day_of_week'] as int).compareTo(b['day_of_week'] as int),
    );

    return sortedSchedules.map((schedule) {
      final isClosed = schedule['is_closed'] as bool? ?? false;
      final openTime = schedule['open_time'] as String?;
      final closeTime = schedule['close_time'] as String?;
      final dayOfWeek = schedule['day_of_week'] as int;

      String hoursText;
      if (isClosed) {
        hoursText = 'Fermé';
      } else if (openTime != null && closeTime != null) {
        // Formater de HH:MM en HHh
        final openFormatted =
            openTime.split(':')[0] +
            'h' +
            (openTime.split(':')[1] != '00' ? openTime.split(':')[1] : '');
        final closeFormatted =
            closeTime.split(':')[0] +
            'h' +
            (closeTime.split(':')[1] != '00' ? closeTime.split(':')[1] : '');
        hoursText = '$openFormatted - $closeFormatted';
      } else {
        hoursText = 'Non défini';
      }

      return Padding(
        padding: EdgeInsets.only(
          bottom: context.fluidValue(minValue: 4, maxValue: 6),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: dayWidth,
              child: Text(
                '${_getDayLabel(dayOfWeek)} ',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: fontSize,
                ),
              ),
            ),
            Text(
              hoursText,
              style: AppTextStyles.caption.copyWith(
                color: isClosed ? Colors.red.shade300 : Colors.white,
                fontSize: fontSize,
                fontWeight: isClosed ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
