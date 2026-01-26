import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/skeleton_box.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/price_formatter.dart';
import '../../core/api/dio_client.dart';
import 'models/order_model.dart';
import 'order_detail_page.dart';
import '../auth/login_page.dart';
import '../reviews/create_review_page.dart';

/// Page de liste des commandes de l'utilisateur
class OrdersListPage extends StatefulWidget {
  const OrdersListPage({super.key});

  @override
  State<OrdersListPage> createState() => _OrdersListPageState();
}

class _OrdersListPageState extends State<OrdersListPage> {
  List<OrderModel>? _orders;
  bool _isLoading = true;
  String? _errorMessage;
  String _filterStatus = 'all'; // all, active, completed, cancelled

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dioClient = await DioClient.create();
      final response = await dioClient.dio.get('/orders/me');

      if (!mounted) return;

      final data = response.data as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>;

      setState(() {
        _orders =
            items
                .map(
                  (json) => OrderModel.fromJson(json as Map<String, dynamic>),
                )
                .toList()
              ..sort(
                (a, b) => b.eventDate.compareTo(a.eventDate),
              ); // Plus récent en premier
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      // Si erreur 401, rediriger vers login
      if (e.toString().contains('401')) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
        return;
      }

      setState(() {
        _errorMessage = 'Impossible de charger vos commandes';
        _isLoading = false;
      });
    }
  }

  List<OrderModel> get _filteredOrders {
    if (_orders == null) return [];

    switch (_filterStatus) {
      case 'active':
        return _orders!.where((o) => o.isActive).toList();
      case 'completed':
        return _orders!
            .where((o) => o.status == OrderStatus.completed)
            .toList();
      case 'cancelled':
        return _orders!
            .where((o) => o.status == OrderStatus.cancelled)
            .toList();
      default:
        return _orders!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = context.fluidValue(minValue: 16, maxValue: 32);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Mes commandes',
          style: AppTextStyles.sectionTitle.copyWith(
            fontSize: context.fluidValue(minValue: 20, maxValue: 24),
          ),
        ),
        centerTitle: context.isMobile,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
            tooltip: 'Actualiser',
          ),
          SizedBox(width: padding / 2),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(padding),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: context.isDesktop ? 1200 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterChips(context),
                  SizedBox(
                    height: context.fluidValue(minValue: 16, maxValue: 24),
                  ),
                  if (_isLoading)
                    _buildLoadingSkeleton(context)
                  else if (_errorMessage != null)
                    _buildErrorState(context)
                  else if (_filteredOrders.isEmpty)
                    _buildEmptyState(context)
                  else
                    _buildOrdersList(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final filters = [
      ('all', 'Toutes', Icons.list),
      ('active', 'En cours', Icons.pending),
      ('completed', 'Terminées', Icons.check_circle),
      ('cancelled', 'Annulées', Icons.cancel),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            filters.map((filter) {
              final isSelected = _filterStatus == filter.$1;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: isSelected,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        filter.$3,
                        size: 16,
                        color:
                            isSelected
                                ? AppColors.dark
                                : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(filter.$2),
                    ],
                  ),
                  onSelected: (_) {
                    setState(() => _filterStatus = filter.$1);
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    color:
                        isSelected ? AppColors.dark : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context) {
    return Column(
      children:
          _filteredOrders.map((order) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: context.fluidValue(minValue: 12, maxValue: 16),
              ),
              child: _OrderCard(
                order: order,
                onTap: () => _navigateToDetail(order.id),
              ),
            );
          }).toList(),
    );
  }

  void _navigateToDetail(int orderId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailPage(orderId: orderId),
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: 20, width: context.screenWidth * 0.3),
                const SizedBox(height: 12),
                SkeletonBox(height: 16, width: context.screenWidth * 0.5),
                const SizedBox(height: 8),
                SkeletonBox(height: 16, width: context.screenWidth * 0.4),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return GlassCard(
      child: Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.danger),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: AppTextStyles.body.copyWith(color: AppColors.danger),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadOrders,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.dark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    String message;
    IconData icon;

    switch (_filterStatus) {
      case 'active':
        message = 'Aucune commande en cours';
        icon = Icons.pending_outlined;
        break;
      case 'completed':
        message = 'Aucune commande terminée';
        icon = Icons.check_circle_outline;
        break;
      case 'cancelled':
        message = 'Aucune commande annulée';
        icon = Icons.cancel_outlined;
        break;
      default:
        message = 'Vous n\'avez pas encore de commande';
        icon = Icons.receipt_long_outlined;
    }

    return GlassCard(
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget carte de commande
class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = Color(order.status.colorValue);

    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec statut
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      order.status.emoji,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      order.status.label,
                      style: AppTextStyles.caption.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Commande #${order.id}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Date et lieu
          _buildInfoRow(
            context,
            icon: Icons.calendar_today,
            label: order.formattedDate,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            icon: Icons.access_time,
            label: order.formattedTime,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            icon: Icons.location_on,
            label: order.eventCity,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            icon: Icons.people,
            label: '${order.peopleCount} personnes',
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Bouton avis si COMPLETED
          if (order.status == OrderStatus.completed) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateReviewPage(order: order),
                    ),
                  );
                },
                icon: Icon(Icons.star_outline, color: AppColors.primary),
                label: const Text('Donner mon avis'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 16),
          ],

          // Total
          Row(
            children: [
              Text(
                'Total',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Text(
                PriceFormatter.formatPrice(order.totalPrice),
                style: AppTextStyles.cardTitle.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontSize: context.fluidValue(minValue: 13, maxValue: 15),
            ),
          ),
        ),
      ],
    );
  }
}
