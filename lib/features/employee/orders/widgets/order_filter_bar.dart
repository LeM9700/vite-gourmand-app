import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/utils/responsive.dart';
import 'dart:async';

class OrderFilterBar extends StatefulWidget {
  final String? selectedStatus;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String> onSearchChanged;

  const OrderFilterBar({
    super.key,
    this.selectedStatus,
    required this.onStatusChanged,
    required this.onSearchChanged,
  });

  @override
  State<OrderFilterBar> createState() => _OrderFilterBarState();
}

class _OrderFilterBarState extends State<OrderFilterBar> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  
  final List<Map<String, String>> _statuses = [
    {'value': '', 'label': 'Toutes'},
    {'value': 'PLACED', 'label': 'Reçues'},
    {'value': 'ACCEPTED', 'label': 'Acceptées'},
    {'value': 'PREPARING', 'label': 'En préparation'},
    {'value': 'DELIVERING', 'label': 'En livraison'},
    {'value': 'DELIVERED', 'label': 'Livrées'},
    {'value': 'WAITING_RETURN', 'label': 'Attente retour'},
    {'value': 'COMPLETED', 'label': 'Terminées'},
    {'value': 'CANCELLED', 'label': 'Annulées'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearchChanged(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.horizontalPadding;
    final isSmallScreen = context.isSmallScreen;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Champ de recherche par nom client
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Rechercher par nom du client...',
              hintStyle: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                      onPressed: () {
                        _searchController.clear();
                        widget.onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.lightGrey.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Label statut
          Text(
            'Filtrer par statut',
            style: AppTextStyles.subtitle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          // ChoiceChips pour le filtrage par statut
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _statuses.map((status) {
              final isSelected = widget.selectedStatus == status['value'] ||
                  (widget.selectedStatus == null && status['value'] == '');
              return ChoiceChip(
                label: Text(status['label']!),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    final newStatus = status['value']!.isEmpty ? null : status['value'];
                    widget.onStatusChanged(newStatus);
                  }
                },
                backgroundColor: AppColors.glassFill,
                selectedColor: AppColors.primary.withOpacity(0.2),
                labelStyle: AppTextStyles.body.copyWith(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.glassBorder,
                  width: isSelected ? 1.5 : 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                  vertical: isSmallScreen ? 6 : 8,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
