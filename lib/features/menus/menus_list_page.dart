import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/api/dio_client.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/responsive.dart';
import 'models/menu_model.dart';
import 'widgets/menu_card.dart';
import 'widgets/menu_filters_overlay.dart';

class MenusListPage extends StatefulWidget {
  const MenusListPage({super.key});

  @override
  State<MenusListPage> createState() => _MenusListPageState();
}

class _MenusListPageState extends State<MenusListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<MenuModel> _menus = [];
  List<MenuModel> _filteredMenus = [];
  bool _isLoading = true;
  String _errorMessage = '';
  DioClient? _dioClient;
  Timer? _searchTimer;
  
  // Filtres
  MenuFilters? _activeFilters;
  List<String> _availableThemes = [];
  List<String> _availableRegimes = [];

  @override
  void initState() {
    super.initState();
    _initializeAndLoad();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeAndLoad() async {
    try {
      _dioClient = await DioClient.create();
      await _loadMenus();
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de connexion: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMenus({Map<String, dynamic>? queryParams}) async {
    if (_dioClient == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Utilisation de l'endpoint de recherche pour avoir les images
      final response = await _dioClient!.dio.get(
        "/menus/search",
        queryParameters: {
          'q': '', // Recherche vide pour tout récupérer
          'active_only': true,
          'limit': 100, // Limite élevée pour récupérer tous les menus
        },
      );
      
      List<dynamic> menusData;
      if (response.data is List) {
        menusData = response.data;
      } else if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        menusData = map['data'] ?? map['menus'] ?? map['items'] ?? [];
      } else {
        throw Exception('Format de réponse inattendu');
      }

      final menus = menusData
          .map((json) {
            print('Menu data: $json'); // Debug temporaire
            return MenuModel.fromJson(json as Map<String, dynamic>);
          })
          .toList();
      
      // Extraire dynamiquement les thèmes et régimes uniques
      final themes = menus.map((m) => m.theme).toSet().toList()..sort();
      final regimes = menus.map((m) => m.regime).toSet().toList()..sort();

      setState(() {
        _menus = menus;
        _filteredMenus = menus;
        _availableThemes = themes;
        _availableRegimes = regimes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de chargement: $e';
        _isLoading = false;
      });
    }
  }

  void _filterMenus(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredMenus = _menus;
      });
      return;
    }

    if (_dioClient == null) return;

    try {
      final response = await _dioClient!.dio.get(
        "/menus/search",
        queryParameters: {
          'q': query,
          'active_only': true,
          'limit': 20,
        },
      );
      
      List<dynamic> menusData;
      if (response.data is List) {
        menusData = response.data;
      } else if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        menusData = map['data'] ?? map['menus'] ?? map['items'] ?? [];
      } else {
        menusData = [];
      }

      final searchResults = menusData
          .map((json) => MenuModel.fromJson(json as Map<String, dynamic>))
          .toList();

      setState(() {
        _filteredMenus = searchResults;
      });
    } catch (e) {
      print('Erreur de recherche: $e');
      // En cas d'erreur, on fait une recherche locale
      setState(() {
        _filteredMenus = _menus.where((menu) {
          final searchLower = query.toLowerCase();
          return menu.title.toLowerCase().contains(searchLower) ||
                 menu.theme.toLowerCase().contains(searchLower) ||
                 menu.regime.toLowerCase().contains(searchLower) ||
                 menu.description.toLowerCase().contains(searchLower);
        }).toList();
      });
    }
  }

  void _showFiltersOverlay() {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => MenuFiltersOverlay(
        maxPrice: _activeFilters?.maxPrice,
        theme: _activeFilters?.theme,
        regime: _activeFilters?.regime,
        minPeopleMax: _activeFilters?.minPeopleMax,
        availableThemes: _availableThemes,
        availableRegimes: _availableRegimes,
        onApply: (filters) {
          setState(() => _activeFilters = filters);
          _applyFilters(filters);
        },
        onReset: () {
          setState(() => _activeFilters = null);
          _loadMenus();
        },
      ),
    );
  }

  Future<void> _applyFilters(MenuFilters filters) async {
    if (_dioClient == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _activeFilters = filters;
    });

    try {
      // Utiliser l'endpoint /menus/search pour avoir les images et plats
      final response = await _dioClient!.dio.get(
        "/menus/search",
        queryParameters: {
          'q': '', // Recherche vide pour récupérer tous les menus avec images/plats
          'active_only': 'true',
          'limit': 100,
        },
      );

      List<dynamic> menusData;
      if (response.data is List) {
        menusData = response.data;
      } else if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        menusData = map['data'] ?? map['menus'] ?? map['items'] ?? [];
      } else {
        menusData = [];
      }

      final allMenus = menusData
          .map((json) => MenuModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Filtrer les menus côté client selon les critères
      final filteredMenus = allMenus.where((menu) {
        // Filtre prix maximum
        if (menu.basePrice > filters.maxPrice) {
          return false;
        }

        // Filtre thème
        if (filters.theme != null && 
            filters.theme!.isNotEmpty && 
            menu.theme != filters.theme) {
          return false;
        }

        // Filtre régime
        if (filters.regime != null && 
            filters.regime!.isNotEmpty && 
            menu.regime != filters.regime) {
          return false;
        }

        // Filtre nombre minimum de personnes
        if (menu.minPeople > filters.minPeopleMax) {
          return false;
        }

        return true;
      }).toList();

      setState(() {
        _menus = allMenus;
        _filteredMenus = filteredMenus;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de l\'application des filtres: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Valeurs responsive fluides
    final heroHeight = context.fluidValue(minValue: 180, maxValue: 320);
    final titleFontSize = context.fluidValue(minValue: 24, maxValue: 42);
    final subtitleFontSize = context.fluidValue(minValue: 12, maxValue: 16);
    
    // Colonnes selon la largeur
    final screenWidth = context.screenWidth;
    int gridColumns;
    double cardAspectRatio;
    
    if (screenWidth < 500) {
      gridColumns = 1;
      cardAspectRatio = 1.1; // Plus large sur mobile une colonne
    } else if (screenWidth < 700) {
      gridColumns = 2;
      cardAspectRatio = 0.65;
    } else if (screenWidth < 1000) {
      gridColumns = 2;
      cardAspectRatio = 0.7;
    } else if (screenWidth < 1300) {
      gridColumns = 3;
      cardAspectRatio = 0.65;
    } else {
      gridColumns = 4;
      cardAspectRatio = 0.6;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Hero Section similaire à la home page
          SliverToBoxAdapter(
            child: Stack(
              children: [
                // Background image
                Container(
                  height: heroHeight,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/splash_bg.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                
                // Overlay
                Container(
                  height: heroHeight,
                  width: double.infinity,
                  color: const Color.fromARGB(255, 189, 189, 189).withOpacity(0.25),
                ),
                
                // Header avec navigation
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(context.horizontalPadding, 8, context.horizontalPadding, 0),
                    child: Row(
                      children: [
                        // Bouton retour
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          color: Colors.white,
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Nos Menus',
                            style: AppTextStyles.sectionTitle.copyWith(
                              color: Colors.white,
                              fontSize: context.isMobile ? 20 : 24,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Contenu centré du hero
                Positioned.fill(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: context.fluidValue(minValue: 20, maxValue: 40)),
                        Text(
                          'NOS MENUS',
                          style: AppTextStyles.heroTitle.copyWith(
                            color: Colors.white,
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: context.fluidValue(minValue: 8, maxValue: 16)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
                          child: Text(
                            'Découvrez l\'ensemble de nos menus\npour vos événements',
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: subtitleFontSize,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Contenu principal
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.background,
              child: ResponsiveContainer(
                maxWidth: 1400,
                padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
                child: Column(
                  children: [
                    // Barre de recherche et filtre
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: context.isMobile ? 16 : 24,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: context.isDesktop ? 600 : double.infinity),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (value) {
                                    _searchTimer?.cancel();
                                    _searchTimer = Timer(const Duration(milliseconds: 500), () {
                                      _filterMenus(value);
                                    });
                                    setState(() {}); // Pour mettre à jour le suffixIcon
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Recherche menus',
                                    hintStyle: AppTextStyles.body.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: AppColors.textSecondary,
                                    ),
                                    suffixIcon: _searchController.text.isNotEmpty
                                        ? IconButton(
                                            icon: Icon(
                                              Icons.clear,
                                              color: AppColors.textSecondary,
                                            ),
                                            onPressed: () {
                                              _searchController.clear();
                                              _filterMenus('');
                                              setState(() {}); // Pour cacher le bouton clear
                                            },
                                          )
                                        : null,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Bouton filtre avec indicateur
                            Stack(
                          children: [
                            Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: _activeFilters?.hasActiveFilters == true 
                                    ? AppColors.primary 
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.tune,
                                  color: _activeFilters?.hasActiveFilters == true
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                                onPressed: _showFiltersOverlay,
                              ),
                            ),
                            if (_activeFilters?.hasActiveFilters == true)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: AppColors.danger,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Compteur de menus
                    if (!_isLoading && _errorMessage.isEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${_filteredMenus.length} Menu${_filteredMenus.length > 1 ? 's' : ''}',
                          style: AppTextStyles.sectionTitle.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: context.isMobile ? 18 : 20,
                          ),
                        ),
                      ),
              
                    SizedBox(height: context.isMobile ? 12 : 16),
                  ],
                ),
              ),
            ),
          ),
          
          // Liste des menus - état loading
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(50),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        
          // Liste des menus - état erreur
          if (_errorMessage.isNotEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(50),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMenus,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        
          // Liste des menus - état vide
          if (!_isLoading && _errorMessage.isEmpty && _filteredMenus.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(50),
                  child: Column(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchController.text.isNotEmpty
                            ? 'Aucun menu trouvé pour "${_searchController.text}"'
                            : 'Aucun menu disponible',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        
          // Liste des menus - grille
          if (!_isLoading && _errorMessage.isEmpty && _filteredMenus.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridColumns,
                  childAspectRatio: cardAspectRatio,
                  crossAxisSpacing: context.gridSpacing,
                  mainAxisSpacing: context.gridSpacing,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return MenuCard(menu: _filteredMenus[index]);
                  },
                  childCount: _filteredMenus.length,
                ),
              ),
            ),
          
          // Espacement en bas
          SliverToBoxAdapter(
            child: SizedBox(height: context.isMobile ? 24 : 40),
          ),
        ],
      ),
    );
  }

}