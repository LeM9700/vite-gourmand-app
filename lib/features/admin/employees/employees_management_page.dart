import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../services/admin_service.dart';
import '../employees/models/employee_model.dart';
import '../employees/widgets/employee_card.dart';
import '../employees/widgets/employee_form_dialog.dart';

class EmployeesManagementPage extends StatefulWidget {
  const EmployeesManagementPage({super.key});

  @override
  State<EmployeesManagementPage> createState() =>
      _EmployeesManagementPageState();
}

class _EmployeesManagementPageState extends State<EmployeesManagementPage> {
  final AdminService _adminService = AdminService();
  List<EmployeeModel> _employees = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';
  String _statusFilter = 'all'; // 'all', 'active', 'inactive'

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final employees = await _adminService.getEmployees();
      if (mounted) {
        setState(() {
          _employees = employees;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<EmployeeModel> get _filteredEmployees {
    return _employees.where((employee) {
      // Exclure les admins de la liste
      if (employee.isAdmin) return false;

      // Filtre de recherche
      final matchesSearch = _searchQuery.isEmpty ||
          employee.fullName.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
          employee.email.toLowerCase().contains(_searchQuery.toLowerCase());

      // Filtre de statut
      final matchesStatus = _statusFilter == 'all' ||
          (_statusFilter == 'active' && employee.isActive) ||
          (_statusFilter == 'inactive' && !employee.isActive);

      return matchesSearch && matchesStatus;
    }).toList();
  }

  Future<void> _showCreateEmployeeDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const EmployeeFormDialog(),
    );

    if (result == true) {
      _loadEmployees();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // App Bar avec gradient
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                      AppColors.cardBackground.withValues(alpha: 0.9),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.people_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Gestion des Employés',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'Playfair Display',
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Créer et gérer les comptes employés',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Filtres et recherche
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Barre de recherche
                  GlassCard(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Rechercher un employé...',
                        hintStyle: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppColors.primary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filtre de statut
                  GlassCard(
                    child: GlassCard(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _statusFilter,
                          isExpanded: true,
                          dropdownColor: const Color.fromARGB(
                            255,
                            230,
                            228,
                            228,
                          ),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.primary,
                          ),
                          style: const TextStyle(color: AppColors.textPrimary),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          items: const [
                            DropdownMenuItem(
                              value: 'all',
                              child: Text('Tous les statuts'),
                            ),
                            DropdownMenuItem(
                              value: 'active',
                              child: Text('Actifs'),
                            ),
                            DropdownMenuItem(
                              value: 'inactive',
                              child: Text('Inactifs'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _statusFilter = value ?? 'all';
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Compteur de résultats
                  Text(
                    '${_filteredEmployees.length} employé(s)',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Liste des employés
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            )
          else if (_errorMessage.isNotEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: Colors.red.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadEmployees,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Réessayer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_filteredEmployees.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_search_rounded,
                      size: 64,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'Aucun employé trouvé'
                          : 'Aucun employé pour le moment',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final employee = _filteredEmployees[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: EmployeeCard(
                      employee: employee,
                      onToggle: () => _loadEmployees(),
                    ),
                  );
                }, childCount: _filteredEmployees.length),
              ),
            ),
        ],
      ),

      // Bouton flottant pour créer un employé
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateEmployeeDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text(
          'Nouvel employé',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
