import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/glass_card.dart';
import 'models/order_employee_model.dart';
import 'services/employee_order_service.dart';
import 'widgets/order_status_timeline.dart';
import 'widgets/order_action_buttons.dart';

class EmployeeOrderDetailPage extends StatefulWidget {
  final int orderId;

  const EmployeeOrderDetailPage({super.key, required this.orderId});

  @override
  State<EmployeeOrderDetailPage> createState() =>
      _EmployeeOrderDetailPageState();
}

class _EmployeeOrderDetailPageState extends State<EmployeeOrderDetailPage> {
  final EmployeeOrderService _orderService = EmployeeOrderService();
  OrderEmployeeModel? _order;
  bool _isLoading = true;
  bool _isUpdating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final order = await _orderService.getOrderDetail(widget.orderId);
      setState(() {
        _order = order;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleStatusChange(String newStatus, String? note) async {
    setState(() => _isUpdating = true);

    try {
      await _orderService.updateOrderStatus(
        orderId: widget.orderId,
        newStatus: newStatus,
        note: note,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Statut mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadOrder();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _handleCancel(String contactMode, String reason) async {
    setState(() => _isUpdating = true);

    try {
      await _orderService.cancelOrder(
        orderId: widget.orderId,
        contactMode: contactMode,
        reason: reason,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Commande annulée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadOrder();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Commande #${widget.orderId}',
          style: AppTextStyles.sectionTitle,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text('Erreur', style: AppTextStyles.sectionTitle),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadOrder,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    SingleChildScrollView(
                      padding: EdgeInsets.all(context.horizontalPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusCard(),
                          const SizedBox(height: 16),
                          _buildCustomerCard(),
                          const SizedBox(height: 16),
                          _buildOrderDetailsCard(),
                          const SizedBox(height: 16),
                          _buildMenuCard(),
                          const SizedBox(height: 16),
                          _buildPricingCard(),
                          if (_order!.cancellation != null) ...[
                            const SizedBox(height: 16),
                            _buildCancellationCard(),
                          ],
                          const SizedBox(height: 24),
                          GlassCard(
                            child: OrderStatusTimeline(
                              history: _order!.history ?? [],
                              currentStatus: _order!.status.value,
                            ),
                          ),
                          const SizedBox(height: 24),
                          GlassCard(
                            child: OrderActionButtons(
                              order: _order!,
                              onStatusChange: _handleStatusChange,
                              onCancel: _handleCancel,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    if (_isUpdating)
                      Container(
                        color: Colors.black.withValues(alpha: 0.5),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
    );
  }

  Widget _buildStatusCard() {
    final statusColor = _getStatusColor(_order!.status.value);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.assignment, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statut actuel',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  OrderStatusLabels.getLabel(_order!.status.value),
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: statusColor,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard() {
    final customer = _order!.customer;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations client',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.person, 'Nom', customer?.fullName ?? 'Inconnu'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.email, 'Email', customer?.email ?? 'N/A'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.phone, 'Téléphone', customer?.phone ?? 'N/A'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.home, 'Adresse', customer?.address ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Détails de l\'\u00e9v\u00e9nement',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.event,
            'Date',
            DateFormatter.formatDateLong(_order!.eventDate),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.access_time, 'Heure', _order!.eventTime),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.location_on, 'Ville', _order!.eventCity),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.home, 'Adresse', _order!.eventAddress),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.local_shipping,
            'Distance',
            '${_order!.deliveryKm} km',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.people,
            'Nombre de personnes',
            '${_order!.peopleCount}',
          ),
          if (_order!.hasLoanedEquipment) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.kitchen, color: Colors.amber, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Matériel prêté',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.amber.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuCard() {
    final menu = _order!.menu;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Menu commandé',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          Text(
            menu?.title ?? 'Menu #${_order!.menuId}',
            style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
          ),
          if (menu?.description != null) ...[
            const SizedBox(height: 8),
            Text(
              menu!.description,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPricingCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Détails du prix',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          _buildPriceRow('Prix menu', _order!.menuPrice),
          const SizedBox(height: 8),
          _buildPriceRow('Frais de livraison', _order!.deliveryFee),
          if (_order!.discount > 0) ...[
            const SizedBox(height: 8),
            _buildPriceRow('Remise', -_order!.discount, color: Colors.green),
          ],
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
              ),
              Text(
                PriceFormatter.formatPrice(_order!.totalPrice),
                style: AppTextStyles.sectionTitle.copyWith(
                  fontSize: 24,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCancellationCard() {
    final cancellation = _order!.cancellation!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cancel, color: Colors.red, size: 24),
              const SizedBox(width: 12),
              Text(
                'Commande annulée',
                style: AppTextStyles.sectionTitle.copyWith(
                  color: Colors.red,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Date d\'annulation',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            DateFormatter.formatDateTime(cancellation.createdAt),
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            'Mode de contact utilisé',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Row(
            children: [
              Icon(
                cancellation.contactMode == 'EMAIL' ? Icons.email : Icons.phone,
                size: 16,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 4),
              Text(
                cancellation.contactMode == 'EMAIL' ? 'Email' : 'Téléphone',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Motif',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(cancellation.reason, style: AppTextStyles.body),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, double amount, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body),
        Text(
          PriceFormatter.formatPrice(amount),
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
