import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/glass_card.dart';
import '../services/management_service.dart';
import '../widgets/schedule_form_dialog.dart';

class SchedulesManagementPage extends StatefulWidget {
  const SchedulesManagementPage({super.key});

  @override
  State<SchedulesManagementPage> createState() =>
      _SchedulesManagementPageState();
}

class _SchedulesManagementPageState extends State<SchedulesManagementPage> {
  final ManagementService _service = ManagementService();
  List<Map<String, dynamic>> _schedules = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final schedules = await _service.getSchedules();
      setState(() {
        _schedules = schedules;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleScheduleStatus(Map<String, dynamic> schedule) async {
    final scheduleId = schedule['id'] as int;
    final isClosed = schedule['is_closed'] as bool? ?? false;

    try {
      await _service.updateSchedule(scheduleId, {
        'day_of_week': schedule['day_of_week'],
        'open_time': schedule['open_time'],
        'close_time': schedule['close_time'],
        'is_closed': !isClosed,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isClosed
                ? 'Établissement ouvert ce jour'
                : 'Établissement fermé ce jour',
          ),
          backgroundColor: Colors.green,
        ),
      );
      _loadSchedules();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteSchedule(int scheduleId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: const Text('Voulez-vous vraiment supprimer cet horaire ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
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
      await _service.deleteSchedule(scheduleId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Horaire supprimé'),
          backgroundColor: Colors.green,
        ),
      );
      _loadSchedules();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showScheduleForm({Map<String, dynamic>? schedule}) {
    showDialog(
      context: context,
      builder:
          (context) => ScheduleFormDialog(
            schedule: schedule,
            onSave: (data) async {
              try {
                if (schedule == null) {
                  await _service.createSchedule(data);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Horaire créé'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  await _service.updateSchedule(schedule['id'], data);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Horaire mis à jour'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                _loadSchedules();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceAll('Exception: ', '')),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
    );
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(_error!, style: const TextStyle(color: Colors.red)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header premium
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.horizontalPadding,
              context.verticalPadding,
              context.horizontalPadding,
              24,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.info.withValues(alpha: 0.2),
                        AppColors.info.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.access_time_rounded,
                    color: AppColors.info,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Horaires d\'ouverture',
                        style: AppTextStyles.sectionTitle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gérez les horaires de votre établissement',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Liste des horaires
          Expanded(
            child:
                _schedules.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: 64,
                            color: AppColors.textMuted.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun horaire',
                            style: AppTextStyles.subtitle.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        context.horizontalPadding,
                        0,
                        context.horizontalPadding,
                        context.verticalPadding + 80,
                      ),
                      itemCount: _schedules.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final schedule = _schedules[index];
                        return _buildScheduleCard(context, schedule);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(
    BuildContext context,
    Map<String, dynamic> schedule,
  ) {
    final dayOfWeek = schedule['day_of_week'] as int;
    final isClosed = schedule['is_closed'] as bool? ?? false;
    final openTime = schedule['open_time'] as String?;
    final closeTime = schedule['close_time'] as String?;

    // Couleurs selon le jour
    Color dayColor;
    IconData dayIcon;

    if (isClosed) {
      dayColor = AppColors.danger;
      dayIcon = Icons.cancel_rounded;
    } else if (dayOfWeek == 5 || dayOfWeek == 6) {
      // Samedi/Dimanche
      dayColor = AppColors.warning;
      dayIcon = Icons.weekend_rounded;
    } else {
      dayColor = AppColors.info;
      dayIcon = Icons.work_outline_rounded;
    }

    return GlassCard(
      padding: EdgeInsets.zero,
      borderColor: dayColor.withValues(alpha: 0.3),
      borderWidth: 2,
      onTap: () => _showScheduleForm(schedule: schedule),
      child: Column(
        children: [
          // Header avec gradient
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  dayColor.withValues(alpha: 0.15),
                  dayColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(
                bottom: BorderSide(
                  color: dayColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: dayColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: dayColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(dayIcon, color: dayColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getDayLabel(dayOfWeek),
                        style: AppTextStyles.cardTitle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isClosed
                            ? 'Fermé'
                            : (openTime != null && closeTime != null
                                ? '$openTime - $closeTime'
                                : 'Horaires non définis'),
                        style: AppTextStyles.caption.copyWith(
                          color:
                              isClosed
                                  ? AppColors.danger
                                  : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _toggleScheduleStatus(schedule),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isClosed
                              ? AppColors.danger.withValues(alpha: 0.15)
                              : AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isClosed
                                ? AppColors.danger.withValues(alpha: 0.3)
                                : AppColors.success.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isClosed ? Icons.close : Icons.check,
                          size: 16,
                          color:
                              isClosed ? AppColors.danger : AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isClosed ? 'Fermé' : 'Ouvert',
                          style: AppTextStyles.caption.copyWith(
                            color:
                                isClosed ? AppColors.danger : AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  icon: Icons.edit_rounded,
                  label: 'Modifier',
                  color: AppColors.primary,
                  onTap: () => _showScheduleForm(schedule: schedule),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
