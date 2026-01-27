import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/skeleton_box.dart';
import '../../core/utils/responsive.dart';
import '../../core/api/dio_client.dart';
import 'models/order_model.dart';
import '../auth/login_page.dart';

/// Page de suivi de la commande en cours (la plus proche)
class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({super.key});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  OrderDetailModel? _order;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNextOrder();
  }

  Future<void> _loadNextOrder() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dioClient = await DioClient.create();

      // Récupérer toutes les commandes actives
      final response = await dioClient.dio.get('/orders/me');
      final data = response.data as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>;

      if (!mounted) return;

      // Filtrer les commandes actives et trouver la plus proche
      final orders = items
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
          .where((order) => order.isActive)
          .toList()
        ..sort((a, b) => a.eventDate.compareTo(b.eventDate));

      if (orders.isEmpty) {
        setState(() {
          _order = null;
          _isLoading = false;
        });
        return;
      }

      // Charger le détail de la commande la plus proche
      final nextOrder = orders.first;
      final detailResponse = await dioClient.dio.get('/orders/${nextOrder.id}');

      if (!mounted) return;

      setState(() {
        _order = OrderDetailModel.fromJson(
          detailResponse.data as Map<String, dynamic>,
        );
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
        _errorMessage = 'Impossible de charger le suivi';
        _isLoading = false;
      });
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
          'Suivi de commande',
          style: AppTextStyles.sectionTitle.copyWith(
            fontSize: context.fluidValue(minValue: 20, maxValue: 24),
          ),
        ),
        centerTitle: context.isMobile,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNextOrder,
            tooltip: 'Actualiser',
          ),
          SizedBox(width: padding / 2),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNextOrder,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(padding),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: context.isDesktop ? 800 : double.infinity,
              ),
              child: _isLoading
                  ? _buildLoadingSkeleton(context)
                  : _errorMessage != null
                      ? _buildErrorState(context)
                      : _order == null
                          ? _buildEmptyState(context)
                          : _buildTrackingContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrackingContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Carte info commande
        _buildOrderInfoCard(context),

        SizedBox(height: context.fluidValue(minValue: 20, maxValue: 24)),

        // Timeline de statut
        _buildStatusTimeline(context),

        SizedBox(height: context.fluidValue(minValue: 20, maxValue: 24)),

        // Détails de l'événement
        _buildEventDetails(context),

        SizedBox(height: context.fluidValue(minValue: 20, maxValue: 24)),

        // Contact
        _buildContactSection(context),
      ],
    );
  }

  Widget _buildOrderInfoCard(BuildContext context) {
    final statusColor = Color(_order!.status.colorValue);
    final daysLeft = _order!.daysUntilEvent;

    return GlassCard(
      child: Column(
        children: [
          // Badge statut
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _order!.status.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  _order!.status.label,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: statusColor,
                    fontSize: context.fluidValue(minValue: 16, maxValue: 18),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Commande #${_order!.id}',
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Countdown
          if (daysLeft >= 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      daysLeft == 0
                          ? 'Aujourd\'hui !'
                          : daysLeft == 1
                              ? 'Demain'
                              : 'Dans $daysLeft jours',
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: context.fluidValue(
                          minValue: 18,
                          maxValue: 22,
                        ),
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      _order!.formattedDate,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(BuildContext context) {
    // Tous les statuts possibles dans l'ordre
    final allStatuses = [
      OrderStatus.placed,
      OrderStatus.accepted,
      OrderStatus.preparing,
      OrderStatus.delivering,
      OrderStatus.delivered,
      OrderStatus.completed,
    ];

    final currentIndex = allStatuses.indexOf(_order!.status);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progression',
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: context.fluidValue(minValue: 16, maxValue: 18),
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(allStatuses.length, (index) {
            final status = allStatuses[index];
            final isPast = index < currentIndex;
            final isCurrent = index == currentIndex;
            final isFuture = index > currentIndex;

            return _buildTimelineItem(
              context,
              status: status,
              isPast: isPast,
              isCurrent: isCurrent,
              isFuture: isFuture,
              isLast: index == allStatuses.length - 1,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context, {
    required OrderStatus status,
    required bool isPast,
    required bool isCurrent,
    required bool isFuture,
    required bool isLast,
  }) {
    final color =
        isCurrent || isPast ? Color(status.colorValue) : AppColors.textMuted;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            // Cercle
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrent
                    ? color
                    : isPast
                        ? color.withValues(alpha: 0.2)
                        : Colors.transparent,
                border: Border.all(color: color, width: isCurrent ? 3 : 2),
              ),
              child: Center(
                child: isPast
                    ? Icon(Icons.check, size: 16, color: color)
                    : Text(
                        status.emoji,
                        style: TextStyle(fontSize: isCurrent ? 14 : 12),
                      ),
              ),
            ),
            // Ligne verticale
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isPast
                    ? color.withValues(alpha: 0.3)
                    : AppColors.textMuted.withValues(alpha: 0.2),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.label,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                    color: isCurrent ? color : AppColors.textPrimary,
                  ),
                ),
                if (isCurrent && _order!.history.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Mis à jour ${_order!.history.first.formattedDate}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventDetails(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Détails de l\'événement',
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: context.fluidValue(minValue: 16, maxValue: 18),
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.calendar_today, 'Date', _order!.formattedDate),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.access_time, 'Heure', _order!.formattedTime),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.location_on,
            'Lieu',
            '${_order!.eventAddress}, ${_order!.eventCity}',
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.people,
            'Invités',
            '${_order!.peopleCount} personnes',
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: context.fluidValue(minValue: 16, maxValue: 18),
                ),
              ),
              Text(
                '${_order!.totalPrice.toStringAsFixed(2)}€',
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: context.fluidValue(minValue: 18, maxValue: 22),
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
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
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Icon(Icons.support_agent, size: 48, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            'Besoin d\'aide ?',
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: context.fluidValue(minValue: 16, maxValue: 18),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notre équipe est à votre disposition pour toute question',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.mail_outline, color: AppColors.primary),
              label: const Text('Contacter le support'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return Column(
      children: [
        GlassCard(
          child: Column(
            children: [
              SkeletonBox(height: 40, width: context.screenWidth * 0.5),
              const SizedBox(height: 16),
              const SkeletonBox(height: 20, width: 120),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GlassCard(
          child: Column(
            children: List.generate(4, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SkeletonBox(height: 60, width: double.infinity),
              );
            }),
          ),
        ),
      ],
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
              onPressed: _loadNextOrder,
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
    return GlassCard(
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.event_available,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune commande en cours',
              style: AppTextStyles.cardTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Vos commandes actives apparaîtront ici',
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
