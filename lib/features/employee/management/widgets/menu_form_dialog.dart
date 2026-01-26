import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../menus/models/menu_model.dart';
import '../services/management_service.dart';

class MenuFormDialog extends StatefulWidget {
  final MenuModel? menu;
  final Future<void> Function(Map<String, dynamic>) onSave;

  const MenuFormDialog({super.key, this.menu, required this.onSave});

  @override
  State<MenuFormDialog> createState() => _MenuFormDialogState();
}

class _MenuFormDialogState extends State<MenuFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _minPeopleController = TextEditingController();
  final _themeController = TextEditingController();
  final _regimeController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _stockController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _isActive = true;
  bool _isLoadingDishes = false;

  // Plats disponibles
  List<Dish> _availableDishes = [];

  // Plats sélectionnés
  Dish? _selectedStarter;
  Dish? _selectedMain;
  Dish? _selectedDessert;

  // Images
  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _loadDishes();

    if (widget.menu != null) {
      final menu = widget.menu!;
      _titleController.text = menu.title;
      _descriptionController.text = menu.description;
      _priceController.text = menu.basePrice.toString();
      _minPeopleController.text = menu.minPeople.toString();
      _themeController.text = menu.theme;
      _regimeController.text = menu.regime;
      _conditionsController.text = menu.conditionsText;
      _stockController.text = menu.stock.toString();
      _isActive = menu.isActive;
      _imageUrls = menu.images.map((img) => img.imageUrl).toList();
      // Les plats seront pré-sélectionnés après le chargement dans _loadDishes()
    } else {
      _minPeopleController.text = '2';
      _stockController.text = '10';
      _conditionsController.text = 'Réservation 48h à l\'avance';
    }
  }

  Future<void> _loadDishes() async {
    setState(() => _isLoadingDishes = true);
    try {
      final service = ManagementService();
      final dishes = await service.getDishes();

      setState(() {
        _availableDishes = dishes.map((json) => Dish.fromJson(json)).toList();
        _isLoadingDishes = false;

        // Pré-sélectionner les plats du menu si on est en mode édition
        if (widget.menu != null) {
          final menu = widget.menu!;

          // Trouver l'entrée
          final starterFromMenu =
              menu.dishes.where((d) => d.dishType == 'STARTER').firstOrNull;
          if (starterFromMenu != null) {
            _selectedStarter = _availableDishes.firstWhere(
              (d) => d.id == starterFromMenu.id,
              orElse:
                  () => Dish(
                    id: 0,
                    name: '',
                    dishType: '',
                    description: '',
                    allergens: [],
                  ),
            );
            if (_selectedStarter?.id == 0) _selectedStarter = null;
          }

          // Trouver le plat principal
          final mainFromMenu =
              menu.dishes.where((d) => d.dishType == 'MAIN').firstOrNull;
          if (mainFromMenu != null) {
            _selectedMain = _availableDishes.firstWhere(
              (d) => d.id == mainFromMenu.id,
              orElse:
                  () => Dish(
                    id: 0,
                    name: '',
                    dishType: '',
                    description: '',
                    allergens: [],
                  ),
            );
            if (_selectedMain?.id == 0) _selectedMain = null;
          }

          // Trouver le dessert
          final dessertFromMenu =
              menu.dishes.where((d) => d.dishType == 'DESSERT').firstOrNull;
          if (dessertFromMenu != null) {
            _selectedDessert = _availableDishes.firstWhere(
              (d) => d.id == dessertFromMenu.id,
              orElse:
                  () => Dish(
                    id: 0,
                    name: '',
                    dishType: '',
                    description: '',
                    allergens: [],
                  ),
            );
            if (_selectedDessert?.id == 0) _selectedDessert = null;
          }
        }
      });
    } catch (e) {
      setState(() => _isLoadingDishes = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur chargement plats: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _minPeopleController.dispose();
    _themeController.dispose();
    _regimeController.dispose();
    _conditionsController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.restaurant_menu,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.menu == null ? 'Créer un menu' : 'Modifier le menu',
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 22),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Contenu scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Informations générales
                      _buildSectionTitle('Informations générales'),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Titre du menu *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _themeController,
                              decoration: const InputDecoration(
                                labelText: 'Thème *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.style),
                                hintText: 'Ex: Gastronomique',
                              ),
                              validator:
                                  (v) => v?.isEmpty ?? true ? 'Requis' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _regimeController,
                              decoration: const InputDecoration(
                                labelText: 'Régime *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.health_and_safety),
                                hintText: 'Ex: Végétarien',
                              ),
                              validator:
                                  (v) => v?.isEmpty ?? true ? 'Requis' : null,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Prix et capacité
                      _buildSectionTitle('Prix et capacité'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              decoration: const InputDecoration(
                                labelText: 'Prix par personne *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.euro),
                                suffixText: '€',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator:
                                  (v) => v?.isEmpty ?? true ? 'Requis' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _minPeopleController,
                              decoration: const InputDecoration(
                                labelText: 'Minimum personnes *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.people),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator:
                                  (v) => v?.isEmpty ?? true ? 'Requis' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _stockController,
                              decoration: const InputDecoration(
                                labelText: 'Stock *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.inventory_2),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator:
                                  (v) => v?.isEmpty ?? true ? 'Requis' : null,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Composition du menu
                      _buildSectionTitle('Composition du menu'),
                      const SizedBox(height: 12),
                      if (_isLoadingDishes)
                        const Center(child: CircularProgressIndicator())
                      else ...[
                        _buildDishSelector(
                          title: 'Entrée',
                          icon: Icons.restaurant,
                          dishType: 'STARTER',
                          selectedDish: _selectedStarter,
                          onChanged:
                              (dish) => setState(() => _selectedStarter = dish),
                        ),
                        const SizedBox(height: 12),
                        _buildDishSelector(
                          title: 'Plat principal',
                          icon: Icons.lunch_dining,
                          dishType: 'MAIN',
                          selectedDish: _selectedMain,
                          onChanged:
                              (dish) => setState(() => _selectedMain = dish),
                        ),
                        const SizedBox(height: 12),
                        _buildDishSelector(
                          title: 'Dessert',
                          icon: Icons.cake,
                          dishType: 'DESSERT',
                          selectedDish: _selectedDessert,
                          onChanged:
                              (dish) => setState(() => _selectedDessert = dish),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Images
                      _buildSectionTitle(
                        'Images du menu (recommandé: 1200x800px, format 3:2)',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '💡 Format optimal: 1200x800 pixels (ratio 3:2) - Format JPEG ou PNG - Taille max: 2MB',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.info,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _imageUrlController,
                              decoration: const InputDecoration(
                                labelText: 'URL de l\'image',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.image),
                                hintText: 'https://exemple.com/image.jpg',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (_imageUrlController.text.isNotEmpty) {
                                setState(() {
                                  _imageUrls.add(_imageUrlController.text);
                                  _imageUrlController.clear();
                                });
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Ajouter'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_imageUrls.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              _imageUrls.asMap().entries.map((entry) {
                                final index = entry.key;
                                final url = entry.value;
                                return Chip(
                                  avatar: const Icon(Icons.image, size: 18),
                                  label: Text(
                                    url.length > 30
                                        ? '${url.substring(0, 30)}...'
                                        : url,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                  onDeleted: () {
                                    setState(() => _imageUrls.removeAt(index));
                                  },
                                );
                              }).toList(),
                        ),

                      const SizedBox(height: 24),

                      // Conditions
                      _buildSectionTitle('Conditions et disponibilité'),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _conditionsController,
                        decoration: const InputDecoration(
                          labelText: 'Conditions de réservation *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.info),
                          hintText: 'Ex: Réservation 48h à l\'avance',
                        ),
                        maxLines: 2,
                        validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Menu actif'),
                        subtitle: const Text(
                          'Le menu sera visible par les clients',
                        ),
                        value: _isActive,
                        onChanged: (v) => setState(() => _isActive = v),
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _saveMenu,
                    icon: const Icon(Icons.save),
                    label: const Text('Enregistrer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.subtitle.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildDishSelector({
    required String title,
    required IconData icon,
    required String dishType,
    required Dish? selectedDish,
    required Function(Dish?) onChanged,
  }) {
    final dishes =
        _availableDishes.where((d) => d.dishType == dishType).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Dish>(
            value: selectedDish,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            hint: Text('Sélectionner un ${title.toLowerCase()}'),
            items: [
              const DropdownMenuItem<Dish>(value: null, child: Text('Aucun')),
              ...dishes.map(
                (dish) =>
                    DropdownMenuItem<Dish>(value: dish, child: Text(dish.name)),
              ),
            ],
            onChanged: onChanged,
          ),
          if (selectedDish != null) ...[
            const SizedBox(height: 8),
            Text(
              selectedDish.description,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _saveMenu() async {
    if (!_formKey.currentState!.validate()) return;

    // Collecter les IDs des plats sélectionnés
    final List<int> dishIds = [];
    if (_selectedStarter != null) dishIds.add(_selectedStarter!.id);
    if (_selectedMain != null) dishIds.add(_selectedMain!.id);
    if (_selectedDessert != null) dishIds.add(_selectedDessert!.id);

    // Vérifier qu'au moins un plat est sélectionné
    if (dishIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins un plat pour le menu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final menuData = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'theme': _themeController.text,
      'regime': _regimeController.text,
      'min_people': int.parse(_minPeopleController.text),
      'base_price': double.parse(_priceController.text),
      'conditions_text': _conditionsController.text,
      'stock': int.parse(_stockController.text),
      'is_active': _isActive,
      'dish_ids': dishIds,
      'image_urls': _imageUrls,
    };

    await widget.onSave(menuData);
    if (mounted) Navigator.pop(context);
  }
}
