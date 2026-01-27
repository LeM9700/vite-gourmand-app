import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/skeleton_box.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/price_formatter.dart';
import '../../core/api/dio_client.dart';
import 'models/order_model.dart';
import '../auth/login_page.dart';
import '../reviews/create_review_page.dart';

/// Page de détail d'une commande avec historique
class OrderDetailPage extends StatefulWidget {
  final int orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  OrderDetailModel? _order;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrderDetail();
  }

  Future<void> _loadOrderDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dioClient = await DioClient.create();
      final response = await dioClient.dio.get('/orders/${widget.orderId}');

      if (!mounted) return;

      setState(() {
        _order = OrderDetailModel.fromJson(
          response.data as Map<String, dynamic>,
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
        _errorMessage = 'Impossible de charger les détails';
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
          'Détail commande #${widget.orderId}',
          style: AppTextStyles.sectionTitle.copyWith(
            fontSize: context.fluidValue(minValue: 18, maxValue: 22),
          ),
        ),
        centerTitle: context.isMobile,
      ),
      body: _isLoading
          ? _buildLoadingSkeleton(context, padding)
          : _errorMessage != null
              ? _buildErrorState(context, padding)
              : _buildContent(context, padding),
    );
  }

  Widget _buildContent(BuildContext context, double padding) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.isDesktop ? 800 : double.infinity,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statut actuel
              _buildStatusCard(context),

              SizedBox(height: context.fluidValue(minValue: 16, maxValue: 24)),

              // Détails événement
              _buildEventCard(context),

              SizedBox(height: context.fluidValue(minValue: 16, maxValue: 24)),

              // Historique
              if (_order!.history.isNotEmpty) ...[
                _buildHistoryCard(context),
                SizedBox(
                  height: context.fluidValue(minValue: 16, maxValue: 24),
                ),
              ],

              // Actions
              if (_order!.isEditable || _order!.isCancellable)
                _buildActionsCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final statusColor = Color(_order!.status.colorValue);

    return GlassCard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 10),
                Text(
                  _order!.status.label,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: statusColor,
                    fontSize: context.fluidValue(minValue: 18, maxValue: 22),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations de l\'événement',
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: context.fluidValue(minValue: 16, maxValue: 18),
            ),
          ),
          const SizedBox(height: 16),

          _buildInfoRow(Icons.calendar_today, 'Date', _order!.formattedDate),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.access_time, 'Heure', _order!.formattedTime),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.location_on, 'Adresse', _order!.eventAddress),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.location_city, 'Ville', _order!.eventCity),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.people,
            'Nombre d\'invités',
            '${_order!.peopleCount}',
          ),

          if (_order!.deliveryKm > 0) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.straighten,
              'Distance',
              '${_order!.deliveryKm.toStringAsFixed(0)} km',
            ),
          ],

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Récapitulatif prix
          _buildPriceRow(
            'Menu (${_order!.peopleCount} × ${PriceFormatter.formatPrice(_order!.menuPrice)})',
            _order!.menuPrice * _order!.peopleCount,
          ),

          if (_order!.deliveryFee > 0) ...[
            const SizedBox(height: 8),
            _buildPriceRow('Livraison', _order!.deliveryFee),
          ],

          if (_order!.discount > 0) ...[
            const SizedBox(height: 8),
            _buildPriceRow('Réduction', -_order!.discount, isDiscount: true),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: context.fluidValue(minValue: 18, maxValue: 20),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                PriceFormatter.formatPrice(_order!.totalPrice),
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: context.fluidValue(minValue: 20, maxValue: 24),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
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

  Widget _buildPriceRow(
    String label,
    double amount, {
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: isDiscount ? Colors.green.shade700 : AppColors.textPrimary,
          ),
        ),
        Text(
          PriceFormatter.formatPrice(amount),
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: isDiscount ? Colors.green.shade700 : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Historique',
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: context.fluidValue(minValue: 16, maxValue: 18),
            ),
          ),
          const SizedBox(height: 16),
          ..._order!.history.map((history) {
            final status = OrderStatus.fromString(history.status);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(status.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status.label,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          history.formattedDate,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (history.note != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            history.note!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          // Bouton avis si commande COMPLETED
          if (_order!.status == OrderStatus.completed) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateReviewPage(order: _order!),
                    ),
                  ).then((result) {
                    // Si avis créé avec succès, recharger la commande
                    if (result == true) {
                      _loadOrderDetail();
                    }
                  });
                },
                icon: const Icon(Icons.star, color: Colors.white),
                label: const Text('Donner mon avis'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_order!.isEditable) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.edit, color: AppColors.primary),
                label: const Text('Modifier la commande'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_order!.isCancellable)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showCancelDialog(context);
                },
                icon: const Icon(Icons.cancel, color: Colors.red),
                label: const Text('Annuler la commande'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la commande'),
        content: const Text(
          'Êtes-vous sûr de vouloir annuler cette commande ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Retour'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Confirmer l\'annulation'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context, double padding) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: [
          const GlassCard(child: SkeletonBox(height: 60)),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              children: List.generate(5, (index) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: SkeletonBox(height: 40),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, double padding) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                onPressed: _loadOrderDetail,
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
      ),
    );
  }
}
