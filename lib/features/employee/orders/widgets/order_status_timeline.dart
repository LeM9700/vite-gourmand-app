import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../orders/models/order_model.dart';

class OrderStatusTimeline extends StatelessWidget {
  final List<OrderHistoryModel> history;
  final String currentStatus;

  const OrderStatusTimeline({
    super.key,
    required this.history,
    required this.currentStatus,
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'PLACED':
        return Icons.assignment;
      case 'ACCEPTED':
        return Icons.check_circle;
      case 'PREPARING':
        return Icons.restaurant;
      case 'DELIVERING':
        return Icons.local_shipping;
      case 'DELIVERED':
        return Icons.done_all;
      case 'WAITING_RETURN':
        return Icons.schedule;
      case 'COMPLETED':
        return Icons.verified;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.circle;
    }
  }

  String _getStatusLabel(String status) {
    const labels = {
      'PLACED': 'Commande reçue',
      'ACCEPTED': 'Acceptée',
      'PREPARING': 'En préparation',
      'DELIVERING': 'En livraison',
      'DELIVERED': 'Livrée',
      'WAITING_RETURN': 'Attente retour matériel',
      'COMPLETED': 'Terminée',
      'CANCELLED': 'Annulée',
    };
    return labels[status] ?? status;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy à HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historique',
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 16),
        ...List.generate(history.length, (index) {
          final item = history[index];
          final isLast = index == history.length - 1;
          final statusColor = _getStatusColor(item.status);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline indicator
              Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: statusColor, width: 2),
                    ),
                    child: Icon(
                      _getStatusIcon(item.status),
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 60,
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                ],
              ),

              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStatusLabel(item.status),
                        style: AppTextStyles.subtitle.copyWith(
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(item.changedAt),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (item.note != null && item.note!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.note!,
                            style: AppTextStyles.caption.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}
