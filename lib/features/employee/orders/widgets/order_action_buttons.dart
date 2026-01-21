import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../models/order_employee_model.dart';
import 'cancel_order_modal.dart';

class OrderActionButtons extends StatelessWidget {
  final OrderEmployeeModel order;
  final Future<void> Function(String newStatus, String? note) onStatusChange;
  final Future<void> Function(String contactMode, String reason) onCancel;

  const OrderActionButtons({
    super.key,
    required this.order,
    required this.onStatusChange,
    required this.onCancel,
  });

  Color _getStatusColor(String status) {
    switch (status) {
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
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusLabel(String status) {
    const labels = {
      'ACCEPTED': 'Accepter',
      'PREPARING': 'En préparation',
      'DELIVERING': 'En livraison',
      'DELIVERED': 'Marquer livré',
      'WAITING_RETURN': 'Attente retour',
      'COMPLETED': 'Terminer',
    };
    return labels[status] ?? status;
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
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
      default:
        return Icons.circle;
    }
  }

  Future<void> _handleStatusChange(BuildContext context, String newStatus) async {
    // Vérification spéciale pour WAITING_RETURN
    if (newStatus == 'WAITING_RETURN' && !order.hasLoanedEquipment) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible : aucun matériel n\'a été prêté pour cette commande'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Demander une note optionnelle
    String? note;
    final shouldAddNote = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Changer le statut',
          style: AppTextStyles.sectionTitle,
        ),
        content: Text(
          'Voulez-vous ajouter une note pour ce changement de statut ?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Oui'),
          ),
        ],
      ),
    );

    if (shouldAddNote == null) return;

    if (shouldAddNote == true && context.mounted) {
      final controller = TextEditingController();
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Note', style: AppTextStyles.sectionTitle),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Ajouter une note...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Confirmer'),
            ),
          ],
        ),
      );
      note = result;
    }

    if (context.mounted) {
      await onStatusChange(newStatus, note);
    }
  }

  Future<void> _handleCancel(BuildContext context) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const CancelOrderModal(),
    );

    if (result != null && context.mounted) {
      await onCancel(result['contactMode']!, result['reason']!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allowedTransitions = OrderStatusTransitions.getAllowedTransitions(order.status.value);
    final canCancel = allowedTransitions.contains('CANCELLED');

    if (allowedTransitions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.lightGrey.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Aucune action disponible pour ce statut',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final nextTransitions = allowedTransitions.where((s) => s != 'CANCELLED').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Actions',
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 16),

        // Boutons de transition de statut
        ...nextTransitions.map((status) {
          final color = _getStatusColor(status);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PrimaryButton(
              label: _getStatusLabel(status),
              onPressed: () => _handleStatusChange(context, status),
            ),
          );
        }),

        // Bouton d'annulation
        if (canCancel) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _handleCancel(context),
            icon: const Icon(Icons.cancel, color: Colors.red),
            label: Text(
              'Annuler la commande',
              style: AppTextStyles.body.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.red, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
