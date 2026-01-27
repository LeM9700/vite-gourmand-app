import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../services/admin_service.dart';
import '../models/employee_model.dart';

class EmployeeCard extends StatefulWidget {
  final EmployeeModel employee;
  final VoidCallback onToggle;

  const EmployeeCard({
    super.key,
    required this.employee,
    required this.onToggle,
  });

  @override
  State<EmployeeCard> createState() => _EmployeeCardState();
}

class _EmployeeCardState extends State<EmployeeCard>
    with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isToggling = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _toggleStatus() async {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    setState(() {
      _isToggling = true;
    });

    try {
      await _adminService.toggleEmployeeActive(
        employeeId: widget.employee.id,
        isActive: !widget.employee.isActive,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.employee.isActive
                  ? 'Employé désactivé avec succès'
                  : 'Employé activé avec succès',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        widget.onToggle();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isToggling = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec nom et badges
              Row(
                children: [
                  // Avatar avec initiales
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.employee.isAdmin
                            ? [
                                AppColors.primary,
                                AppColors.primary.withValues(alpha: 0.7),
                              ]
                            : [
                                Colors.blue,
                                Colors.blue.withValues(alpha: 0.7),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.employee.firstname[0]}${widget.employee.lastname[0]}'
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Nom et email
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.employee.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.employee.email,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Badge de rôle
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.employee.isAdmin
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : Colors.blue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: widget.employee.isAdmin
                            ? AppColors.primary.withValues(alpha: 0.5)
                            : Colors.blue.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.employee.isAdmin
                              ? Icons.admin_panel_settings_rounded
                              : Icons.person_rounded,
                          size: 16,
                          color: widget.employee.isAdmin
                              ? AppColors.primary
                              : Colors.blue,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.employee.roleLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: widget.employee.isAdmin
                                ? AppColors.primary
                                : Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Divider
              Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
              const SizedBox(height: 16),

              // Informations
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.phone_rounded,
                      'Téléphone',
                      widget.employee.phone,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.calendar_today_rounded,
                      'Créé le',
                      _formatDate(widget.employee.createdAt),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Adresse
              _buildInfoItem(
                Icons.location_on_rounded,
                'Adresse',
                widget.employee.address,
              ),
              const SizedBox(height: 16),

              // Divider
              Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
              const SizedBox(height: 16),

              // Footer avec toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Badge de statut
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: widget.employee.isActive
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.employee.isActive
                            ? Colors.green.withValues(alpha: 0.5)
                            : Colors.red.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: widget.employee.isActive
                                ? Colors.green
                                : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.employee.isActive ? 'Actif' : 'Inactif',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: widget.employee.isActive
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bouton toggle
                  ElevatedButton.icon(
                    onPressed: _isToggling ? null : _toggleStatus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.employee.isActive
                          ? Colors.red.withValues(alpha: 0.2)
                          : Colors.green.withValues(alpha: 0.2),
                      foregroundColor:
                          widget.employee.isActive ? Colors.red : Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: widget.employee.isActive
                              ? Colors.red.withValues(alpha: 0.5)
                              : Colors.green.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    icon: _isToggling
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Icon(
                            widget.employee.isActive
                                ? Icons.block_rounded
                                : Icons.check_circle_rounded,
                          ),
                    label: Text(
                      widget.employee.isActive ? 'Désactiver' : 'Activer',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary.withValues(alpha: 0.7)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Août',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
