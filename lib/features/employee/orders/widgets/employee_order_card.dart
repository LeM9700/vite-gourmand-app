import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/theme/shadows.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/glass_card.dart';
import '../models/order_employee_model.dart';

class EmployeeOrderCard extends StatelessWidget {
  final OrderEmployeeModel order;
  final VoidCallback onTap;

  const EmployeeOrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PLACED':
        return Colors.blue;
      case 'ACCEPTED':
        return Colors.cyan;
      case 'PREPARING':
        return Colors.orange;
      case 'DELIVERING':
        return Colors.purple;
      case 'DELIVERED':
        return Colors.green;
      case 'WAITING_RETURN':
        return Colors.amber;
      case 'COMPLETED':
        return AppColors.primary;
      case 'CANCELLED':
        return Colors.red;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status.value);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');
    final isSmallScreen = context.isSmallScreen;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: context.horizontalPadding,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: statusColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec badge statut et numéro
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  // Badge statut
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      OrderStatusLabels.getLabel(order.status.value),
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallScreen ? 11 : 12,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Numéro de commande
                  Text(
                    'CMD #${order.id}',
                    style: AppTextStyles.subtitle.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                ],
              ),
            ),

            // Contenu
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informations client
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.customer?.fullName ?? 'Client inconnu',
                              style: AppTextStyles.cardTitle.copyWith(
                                fontSize: isSmallScreen ? 15 : 16,
                              ),
                            ),
                            if (order.customer?.email != null)
                              Text(
                                order.customer!.email,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: isSmallScreen ? 11 : 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Menu
                  Row(
                    children: [
                      const Icon(
                        Icons.restaurant_menu,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.menu?.title ?? 'Menu #${order.menuId}',
                          style: AppTextStyles.body.copyWith(
                            fontSize: isSmallScreen ? 13 : 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Date et heure événement
                  Row(
                    children: [
                      const Icon(
                        Icons.event,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${dateFormat.format(order.eventDate)} à ${order.eventTime}',
                        style: AppTextStyles.body.copyWith(
                          fontSize: isSmallScreen ? 13 : 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Lieu
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.eventCity,
                          style: AppTextStyles.body.copyWith(
                            fontSize: isSmallScreen ? 13 : 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Infos supplémentaires
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Nombre de personnes
                      Row(
                        children: [
                          const Icon(
                            Icons.people,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${order.peopleCount} pers.',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: isSmallScreen ? 13 : 14,
                            ),
                          ),
                        ],
                      ),

                      // Prix total
                      Text(
                        '${order.totalPrice.toStringAsFixed(2)}€',
                        style: AppTextStyles.cardTitle.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: isSmallScreen ? 16 : 18,
                        ),
                      ),
                    ],
                  ),

                  // Indicateur matériel prêté
                  if (order.hasLoanedEquipment) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.kitchen,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Matériel prêté',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.amber.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: isSmallScreen ? 11 : 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
