import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/utils/responsive.dart';
import '../../core/api/dio_client.dart';
import '../menus/models/menu_model.dart';
import 'models/user_info_model.dart';
import 'edit_delivery_info_page.dart';
import 'order_confirmation_page.dart';
import 'order_error_page.dart';
import 'package:intl/intl.dart';

class OrderPage extends StatefulWidget {
  final MenuModel? selectedMenu;

  const OrderPage({super.key, this.selectedMenu});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _guestsController;
  late TextEditingController _notesController;
  late TextEditingController _deliveryKmController;
  late TextEditingController _eventAddressController;
  late TextEditingController _eventCityController;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  UserInfoModel? _userInfo;
  bool _isLoadingUser = true;
  bool _isDeliveryInBordeaux = true;
  bool _isSubmitting = false;
  bool _needsEquipment = false;

  // Constantes de calcul (identiques au backend)
  static const double _deliveryBaseFee = 5.00;
  static const double _deliveryPerKm = 0.59;

  @override
  void initState() {
    super.initState();
    _guestsController = TextEditingController(
      text: widget.selectedMenu?.minPeople.toString() ?? '10',
    );
    _notesController = TextEditingController();
    _deliveryKmController = TextEditingController(text: '0');
    _eventAddressController = TextEditingController();
    _eventCityController = TextEditingController(text: 'Bordeaux');
    _loadUserInfo();

    // Écouter les changements pour recalculer le prix
    _guestsController.addListener(_onFormChanged);
    _deliveryKmController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    setState(() {});
  }

  Future<void> _loadUserInfo() async {
    try {
      final dioClient = await DioClient.create();
      final response = await dioClient.dio.get('/auth/me');
      if (mounted) {
        setState(() {
          _userInfo = UserInfoModel.fromJson(response.data);
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingUser = false);
      }
    }
  }

  Future<void> _navigateToEditInfo() async {
    if (_userInfo == null) return;

    final result = await Navigator.push<UserInfoModel>(
      context,
      MaterialPageRoute(
        builder: (context) => EditDeliveryInfoPage(userInfo: _userInfo!),
      ),
    );

    if (result != null && mounted) {
      setState(() => _userInfo = result);
    }
  }

  @override
  void dispose() {
    _guestsController.removeListener(_onFormChanged);
    _deliveryKmController.removeListener(_onFormChanged);
    _guestsController.dispose();
    _notesController.dispose();
    _deliveryKmController.dispose();
    _eventAddressController.dispose();
    _eventCityController.dispose();
    super.dispose();
  }

  // Calculs de prix
  int get _guestsCount => int.tryParse(_guestsController.text) ?? 0;
  double get _deliveryKm => double.tryParse(_deliveryKmController.text) ?? 0;
  int get _minPeople => widget.selectedMenu?.minPeople ?? 10;
  double get _menuPrice => widget.selectedMenu?.basePrice ?? 0;

  bool get _hasDiscount => _guestsCount >= _minPeople + 5;

  double get _menuTotal => _menuPrice * _guestsCount;

  double get _deliveryFee {
    if (_isDeliveryInBordeaux) return 0;
    return _deliveryBaseFee + (_deliveryKm * _deliveryPerKm);
  }

  double get _discount {
    if (!_hasDiscount) return 0;
    return _menuTotal * 0.10;
  }

  double get _totalPrice => _menuTotal + _deliveryFee - _discount;

  Future<void> _submitOrder() async {
    // Validation du formulaire
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une date et une heure'),
        ),
      );
      return;
    }

    if (widget.selectedMenu == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun menu sélectionné'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Vérifier l'adresse de livraison
    final deliveryAddress = _userInfo?.address ?? _eventAddressController.text;
    if (deliveryAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez renseigner une adresse de livraison'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final dioClient = await DioClient.create();

      // Formater l'heure au format HH:mm:ss
      final timeStr =
          '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00';

      // Préparer le payload
      final payload = {
        'menu_id': widget.selectedMenu!.id,
        'event_address': deliveryAddress,
        'event_city': _isDeliveryInBordeaux ? 'Bordeaux' : _eventCityController.text.trim(),
        'event_date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        'event_time': timeStr,
        'delivery_km': _isDeliveryInBordeaux ? 0 : _deliveryKm,
        'people_count': _guestsCount,
        'has_loaned_equipment': _needsEquipment,
      };

      final response = await dioClient.dio.post('/orders', data: payload);

      if (!mounted) return;

      // Extraire l'ID de la commande de la réponse
      final orderId = response.data['id'] as int? ?? 0;

      // Naviguer vers la page de confirmation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderConfirmationPage(
            orderId: orderId,
            menuTitle: widget.selectedMenu!.title,
            eventDate: _selectedDate!,
            eventTime: _selectedTime!,
            guestsCount: _guestsCount,
            deliveryCity: _isDeliveryInBordeaux ? 'Bordeaux' : _eventCityController.text.trim(),
            totalPrice: _totalPrice,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      String errorMessage = 'Erreur lors de l\'envoi de la commande';
      String? errorCode;

      // Extraire le message d'erreur et le code du backend si disponible
      if (e.toString().contains('detail')) {
        final match = RegExp(r'detail["\s:]+([^"}\]]+)').firstMatch(e.toString());
        if (match != null) {
          errorMessage = match.group(1) ?? errorMessage;
        }
      }

      // Extraire le code d'erreur HTTP si disponible
      final statusMatch = RegExp(r'status(?:Code)?["\s:]+(\d+)').firstMatch(e.toString());
      if (statusMatch != null) {
        errorCode = statusMatch.group(1);
      }

      // Naviguer vers la page d'erreur
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderErrorPage(
            errorMessage: errorMessage,
            errorCode: errorCode,
            onRetry: () {
              Navigator.pop(context); // Retour à la page de commande
            },
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().add(const Duration(days: 2)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 19, minute: 00),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentPadding = responsiveValue<double>(
      context,
      mobile: 20,
      tablet: 32,
      desktop: 48,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Finaliser la commande',
          style: AppTextStyles.sectionTitle.copyWith(
            color: AppColors.textPrimary,
            fontSize: context.isMobile ? 18 : 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(contentPadding),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: context.isDesktop ? 800 : 600,
                    minHeight: constraints.maxHeight - (contentPadding * 2),
                  ),
                  child: Form(
                    key: _formKey,
                    child:
                        context.isDesktop
                            ? _buildDesktopLayout(context)
                            : _buildMobileLayout(context),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Carte info utilisateur en premier
        _buildUserInfoCard(context),
        const SizedBox(height: 24),
        if (widget.selectedMenu != null) ...[
          _buildMenuCard(context),
          const SizedBox(height: 24),
        ],
        _buildEventDetails(context),
        const SizedBox(height: 40),
        _buildSubmitButton(context),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Carte info utilisateur en premier
        _buildUserInfoCard(context),
        const SizedBox(height: 32),
        if (widget.selectedMenu != null) ...[
          _buildMenuCard(context),
          const SizedBox(height: 32),
        ],

        Text(
          'Détails de l\'événement',
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 24),

        // Deux colonnes pour date/heure sur desktop
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildDateSelector(context)),
            const SizedBox(width: 16),
            Expanded(child: _buildTimeSelector(context)),
          ],
        ),
        const SizedBox(height: 24),

        // Nombre d'invités
        _buildGuestsInput(context),
        const SizedBox(height: 8),
        _buildDiscountHint(context),
        const SizedBox(height: 24),

        // Section livraison
        _buildDeliverySection(context),
        const SizedBox(height: 24),

        // Demandes spéciales
        _buildNotesInput(context),
        const SizedBox(height: 32),

        // Récapitulatif de commande
        _buildOrderSummary(context),
        const SizedBox(height: 40),

        // Bouton centré sur desktop
        Center(child: _buildSubmitButton(context)),
      ],
    );
  }

  Widget _buildUserInfoCard(BuildContext context) {
    final padding = context.fluidValue(minValue: 14, maxValue: 20);
    final titleSize = context.fluidValue(minValue: 14, maxValue: 16);
    final labelSize = context.fluidValue(minValue: 12, maxValue: 14);
    final iconSize = context.fluidValue(minValue: 16, maxValue: 20);
    final spacing = context.fluidValue(minValue: 8, maxValue: 12);

    if (_isLoadingUser) {
      return GlassCard(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      );
    }

    if (_userInfo == null) {
      return GlassCard(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.danger,
                size: iconSize,
              ),
              SizedBox(width: spacing),
              Expanded(
                child: Text(
                  'Impossible de charger vos informations',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: labelSize,
                    color: AppColors.danger,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GlassCard(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre avec icône édition
            Row(
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  color: AppColors.primary,
                  size: iconSize + 2,
                ),
                SizedBox(width: spacing),
                Expanded(
                  child: Text(
                    'Informations de livraison',
                    style: AppTextStyles.cardTitle.copyWith(
                      fontSize: titleSize,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                // Bouton édition
                InkWell(
                  onTap: _navigateToEditInfo,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.all(spacing * 0.75),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      color: AppColors.primary,
                      size: iconSize,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: spacing * 1.5),
            Divider(height: 1, color: Colors.grey.shade200),
            SizedBox(height: spacing * 1.5),

            // Infos utilisateur en responsive
            if (context.isDesktop || context.isTablet)
              // Layout horizontal sur grand écran
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.person,
                      label: 'Nom complet',
                      value: _userInfo!.fullName,
                      labelSize: labelSize,
                      iconSize: iconSize,
                      spacing: spacing,
                    ),
                  ),
                  SizedBox(width: spacing * 2),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.phone,
                      label: 'Téléphone',
                      value: _userInfo!.phone ?? 'Non renseigné',
                      isWarning: _userInfo!.phone == null,
                      labelSize: labelSize,
                      iconSize: iconSize,
                      spacing: spacing,
                    ),
                  ),
                ],
              )
            else
              // Layout vertical sur mobile
              Column(
                children: [
                  _buildInfoItem(
                    icon: Icons.person,
                    label: 'Nom complet',
                    value: _userInfo!.fullName,
                    labelSize: labelSize,
                    iconSize: iconSize,
                    spacing: spacing,
                  ),
                  SizedBox(height: spacing),
                  _buildInfoItem(
                    icon: Icons.phone,
                    label: 'Téléphone',
                    value: _userInfo!.phone ?? 'Non renseigné',
                    isWarning: _userInfo!.phone == null,
                    labelSize: labelSize,
                    iconSize: iconSize,
                    spacing: spacing,
                  ),
                ],
              ),

            SizedBox(height: spacing),

            // Adresse toujours en pleine largeur
            _buildInfoItem(
              icon: Icons.location_on,
              label: 'Adresse de livraison',
              value: _userInfo!.address ?? 'Non renseignée',
              isWarning: _userInfo!.address == null,
              labelSize: labelSize,
              iconSize: iconSize,
              spacing: spacing,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    bool isWarning = false,
    required double labelSize,
    required double iconSize,
    required double spacing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color:
              isWarning
                  ? AppColors.danger.withValues(alpha:0.7)
                  : AppColors.textSecondary,
          size: iconSize,
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  fontSize: labelSize - 2,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.body.copyWith(
                  fontSize: labelSize,
                  fontWeight: FontWeight.w500,
                  color: isWarning ? AppColors.danger : AppColors.textPrimary,
                  fontStyle: isWarning ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: EdgeInsets.all(context.isMobile ? 16 : 20),
        child: Row(
          children: [
            if (widget.selectedMenu!.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.selectedMenu!.imageUrl!,
                  width: context.isMobile ? 60 : 80,
                  height: context.isMobile ? 60 : 80,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.selectedMenu!.title,
                    style: AppTextStyles.cardTitle.copyWith(
                      fontSize: context.isMobile ? 16 : 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.selectedMenu!.basePrice.toStringAsFixed(0)}€ / pers',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: context.isMobile ? 14 : 16,
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

  Widget _buildEventDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Détails de l\'événement',
          style: AppTextStyles.sectionTitle.copyWith(
            fontSize: context.isMobile ? 16 : 18,
          ),
        ),
        const SizedBox(height: 16),
        _buildDateSelector(context),
        const SizedBox(height: 12),
        _buildTimeSelector(context),
        const SizedBox(height: 24),
        _buildGuestsInput(context),
        const SizedBox(height: 8),
        _buildDiscountHint(context),
        const SizedBox(height: 24),
        _buildDeliverySection(context),
        const SizedBox(height: 24),
        _buildNotesInput(context),
        const SizedBox(height: 24),
        _buildEquipmentCheckbox(context),
        const SizedBox(height: 32),
        _buildOrderSummary(context),
      ],
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: EdgeInsets.all(context.isMobile ? 14 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDate == null
                    ? 'Sélectionner une date'
                    : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                style: AppTextStyles.body,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector(BuildContext context) {
    return InkWell(
      onTap: () => _selectTime(context),
      child: Container(
        padding: EdgeInsets.all(context.isMobile ? 14 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedTime == null
                    ? 'Heure de l\'événement'
                    : _selectedTime!.format(context),
                style: AppTextStyles.body,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountHint(BuildContext context) {
    final discountThreshold = _minPeople + 5;
    final hasDiscount = _hasDiscount;

    return Row(
      children: [
        Icon(
          hasDiscount ? Icons.check_circle : Icons.info_outline,
          size: context.fluidValue(minValue: 14, maxValue: 16),
          color: hasDiscount ? Colors.green : AppColors.info,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            hasDiscount
                ? '🎉 Réduction de 10% appliquée !'
                : '💡 À partir de $discountThreshold invités, bénéficiez de 10% de réduction !',
            style: AppTextStyles.caption.copyWith(
              fontSize: context.fluidValue(minValue: 11, maxValue: 13),
              color:
                  hasDiscount ? Colors.green.shade700 : AppColors.textSecondary,
              fontWeight: hasDiscount ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliverySection(BuildContext context) {
    final spacing = context.fluidValue(minValue: 12, maxValue: 16);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Livraison',
          style: AppTextStyles.cardTitle.copyWith(
            fontSize: context.fluidValue(minValue: 14, maxValue: 16),
          ),
        ),
        SizedBox(height: spacing),

        // Choix Bordeaux ou hors Bordeaux
        GlassCard(
          padding: EdgeInsets.all(spacing),
          child: Column(
            children: [
              RadioListTile<bool>(
                title: Text(
                  'Livraison à Bordeaux',
                  style: AppTextStyles.body.copyWith(
                    fontSize: context.fluidValue(minValue: 13, maxValue: 15),
                  ),
                ),
                subtitle: Text(
                  'Livraison gratuite',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.green.shade600,
                    fontSize: context.fluidValue(minValue: 11, maxValue: 13),
                  ),
                ),
                value: true,
                groupValue: _isDeliveryInBordeaux,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  setState(() {
                    _isDeliveryInBordeaux = value!;
                    _eventCityController.text = 'Bordeaux';
                    _deliveryKmController.text = '0';
                  });
                },
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              RadioListTile<bool>(
                title: Text(
                  'Livraison hors Bordeaux',
                  style: AppTextStyles.body.copyWith(
                    fontSize: context.fluidValue(minValue: 13, maxValue: 15),
                  ),
                ),
                subtitle: Text(
                  '5,00€ + 0,59€/km',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: context.fluidValue(minValue: 11, maxValue: 13),
                  ),
                ),
                value: false,
                groupValue: _isDeliveryInBordeaux,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  setState(() {
                    _isDeliveryInBordeaux = value!;
                  });
                },
              ),
            ],
          ),
        ),

        // Si hors Bordeaux, afficher les champs ville et distance
        if (!_isDeliveryInBordeaux) ...[
          SizedBox(height: spacing),
          TextFormField(
            controller: _eventCityController,
            decoration: InputDecoration(
              labelText: 'Ville de livraison',
              prefixIcon: Icon(Icons.location_city, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) {
              if (!_isDeliveryInBordeaux &&
                  (value == null || value.trim().isEmpty)) {
                return 'Veuillez entrer la ville';
              }
              return null;
            },
          ),
          SizedBox(height: spacing),
          TextFormField(
            controller: _deliveryKmController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Distance depuis Bordeaux (km)',
              prefixIcon: Icon(Icons.straighten, color: AppColors.primary),
              suffixText: 'km',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
              helperText: 'Frais: ${_deliveryFee.toStringAsFixed(2)}€',
              helperStyle: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            validator: (value) {
              if (!_isDeliveryInBordeaux) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer la distance';
                }
                final km = double.tryParse(value);
                if (km == null || km < 0) {
                  return 'Distance invalide';
                }
                if (km > 100) {
                  return 'Livraison limitée à 100km';
                }
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    final spacing = context.fluidValue(minValue: 8, maxValue: 12);
    final labelSize = context.fluidValue(minValue: 13, maxValue: 15);
    final priceSize = context.fluidValue(minValue: 14, maxValue: 16);

    return GlassCard(
      padding: EdgeInsets.all(context.fluidValue(minValue: 16, maxValue: 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: AppColors.primary,
                size: context.fluidValue(minValue: 20, maxValue: 24),
              ),
              SizedBox(width: spacing),
              Text(
                'Récapitulatif',
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: context.fluidValue(minValue: 16, maxValue: 18),
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing * 1.5),
          Divider(height: 1, color: Colors.grey.shade200),
          SizedBox(height: spacing * 1.5),

          // Menu sélectionné
          if (widget.selectedMenu != null) ...[
            _buildSummaryRow(
              context,
              label: widget.selectedMenu!.title,
              detail: '$_guestsCount × ${_menuPrice.toStringAsFixed(2)}€',
              value: _menuTotal,
              labelSize: labelSize,
              priceSize: priceSize,
            ),
            SizedBox(height: spacing),
          ],

          // Frais de livraison
          _buildSummaryRow(
            context,
            label: 'Livraison',
            detail:
                _isDeliveryInBordeaux
                    ? 'Bordeaux'
                    : '${_deliveryKm.toStringAsFixed(0)} km',
            value: _deliveryFee,
            labelSize: labelSize,
            priceSize: priceSize,
            isFree: _isDeliveryInBordeaux,
          ),

          // Réduction si applicable
          if (_hasDiscount) ...[
            SizedBox(height: spacing),
            _buildSummaryRow(
              context,
              label: 'Réduction 10%',
              detail: '($_guestsCount invités)',
              value: -_discount,
              labelSize: labelSize,
              priceSize: priceSize,
              isDiscount: true,
            ),
          ],

          SizedBox(height: spacing * 1.5),
          Divider(height: 1, color: Colors.grey.shade300),
          SizedBox(height: spacing * 1.5),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total estimé',
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: context.fluidValue(minValue: 16, maxValue: 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_totalPrice.toStringAsFixed(2)}€',
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: context.fluidValue(minValue: 18, maxValue: 22),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          SizedBox(height: spacing),
          Text(
            'Ce montant est une estimation. Le prix final sera confirmé par notre équipe.',
            style: AppTextStyles.caption.copyWith(
              fontSize: context.fluidValue(minValue: 10, maxValue: 12),
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required String label,
    required String detail,
    required double value,
    required double labelSize,
    required double priceSize,
    bool isFree = false,
    bool isDiscount = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.body.copyWith(
                  fontSize: labelSize,
                  color:
                      isDiscount
                          ? Colors.green.shade700
                          : AppColors.textPrimary,
                ),
              ),
              Text(
                detail,
                style: AppTextStyles.caption.copyWith(
                  fontSize: labelSize - 2,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Text(
          isFree
              ? 'Gratuit'
              : '${isDiscount ? '' : '+'}${value.toStringAsFixed(2)}€',
          style: AppTextStyles.body.copyWith(
            fontSize: priceSize,
            fontWeight: FontWeight.w600,
            color:
                isFree
                    ? Colors.green.shade600
                    : (isDiscount
                        ? Colors.green.shade700
                        : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestsInput(BuildContext context) {
    return TextFormField(
      controller: _guestsController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Nombre d\'invités',
        prefixIcon: const Icon(Icons.people),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer le nombre d\'invités';
        }
        if (int.tryParse(value) == null) {
          return 'Nombre invalide';
        }
        if (widget.selectedMenu != null &&
            int.parse(value) < widget.selectedMenu!.minPeople) {
          return 'Minimum ${widget.selectedMenu!.minPeople} personnes';
        }
        return null;
      },
    );
  }

  Widget _buildEquipmentCheckbox(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _needsEquipment = !_needsEquipment);
      },
      child: Container(
        padding: EdgeInsets.all(context.isMobile ? 14 : 16),
        decoration: BoxDecoration(
          color: _needsEquipment 
              ? AppColors.primary.withValues(alpha:0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _needsEquipment 
                ? AppColors.primary 
                : Colors.grey.shade300,
            width: _needsEquipment ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox personnalisée
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _needsEquipment ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _needsEquipment 
                      ? AppColors.primary 
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: _needsEquipment
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            
            // Icône et texte
            Icon(
              Icons.restaurant,
              color: _needsEquipment 
                  ? AppColors.primary 
                  : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'J\'ai besoin de matériel',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: _needsEquipment 
                          ? FontWeight.w600 
                          : FontWeight.w500,
                      color: _needsEquipment 
                          ? AppColors.primary 
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Assiettes, couverts, nappes, etc.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: context.fluidValue(minValue: 11, maxValue: 13),
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

  Widget _buildNotesInput(BuildContext context) {
    return TextFormField(
      controller: _notesController,
      maxLines: context.isMobile ? 3 : 4,
      decoration: InputDecoration(
        labelText: 'Demandes spéciales / Allergies',
        alignLabelWithHint: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final buttonWidth = context.isDesktop ? 400.0 : double.infinity;

    return SizedBox(
      width: buttonWidth,
      height: context.isMobile ? 52 : 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha:0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Valider la demande de devis',
                style: TextStyle(
                  fontSize: context.isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
