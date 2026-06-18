import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import 'models/order_employee_model.dart';
import 'services/employee_order_service.dart';
import 'widgets/order_filter_bar.dart';
import 'widgets/employee_order_card.dart';
import 'employee_order_detail_page.dart';

class EmployeeOrdersListPage extends StatefulWidget {
  const EmployeeOrdersListPage({super.key});

  @override
  State<EmployeeOrdersListPage> createState() => _EmployeeOrdersListPageState();
}

class _EmployeeOrdersListPageState extends State<EmployeeOrdersListPage> {
  final EmployeeOrderService _orderService = EmployeeOrderService();
  List<OrderEmployeeModel> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filtres
  String? _selectedStatus;
  String _searchQuery = '';

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
      final orders = await _orderService.getOrders(
        status: _selectedStatus,
        clientName: _searchQuery.isEmpty ? null : _searchQuery,
      );

      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onStatusChanged(String? status) {
    setState(() {
      _selectedStatus = status;
    });
    _loadOrders();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadOrders();
  }

  Future<void> _onRefresh() async {
    await _loadOrders();
  }

  void _navigateToDetail(OrderEmployeeModel order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeOrderDetailPage(orderId: order.id),
      ),
    ).then((_) => _loadOrders()); // Recharger après retour
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          // Barre de filtres
          OrderFilterBar(
            selectedStatus: _selectedStatus,
            onStatusChanged: _onStatusChanged,
            onSearchChanged: _onSearchChanged,
          ),

          const SizedBox(height: 8),

          // Liste des commandes
          Expanded(
            child: _isLoading
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
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
                              onPressed: _loadOrders,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      )
                    : _orders.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.inbox_outlined,
                                  size: 64,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Aucune commande',
                                  style: AppTextStyles.sectionTitle,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _selectedStatus != null ||
                                          _searchQuery.isNotEmpty
                                      ? 'Aucune commande ne correspond aux filtres'
                                      : 'Aucune commande pour le moment',
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _onRefresh,
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.only(top: 8, bottom: 16),
                              itemCount: _orders.length,
                              itemBuilder: (context, index) {
                                final order = _orders[index];
                                return EmployeeOrderCard(
                                  order: order,
                                  onTap: () => _navigateToDetail(order),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
