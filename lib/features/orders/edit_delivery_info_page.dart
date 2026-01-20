import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/utils/responsive.dart';
import '../../core/api/dio_client.dart';
import 'models/user_info_model.dart';

class EditDeliveryInfoPage extends StatefulWidget {
  final UserInfoModel userInfo;

  const EditDeliveryInfoPage({super.key, required this.userInfo});

  @override
  State<EditDeliveryInfoPage> createState() => _EditDeliveryInfoPageState();
}

class _EditDeliveryInfoPageState extends State<EditDeliveryInfoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstnameController = TextEditingController(
      text: widget.userInfo.firstname,
    );
    _lastnameController = TextEditingController(text: widget.userInfo.lastname);
    _phoneController = TextEditingController(text: widget.userInfo.phone);
    _addressController = TextEditingController(text: widget.userInfo.address);
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dioClient = await DioClient.create();
      await dioClient.dio.patch(
        '/auth/me',
        data: {
          'firstname': _firstnameController.text.trim(),
          'lastname': _lastnameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
        },
      );

      if (!mounted) return;

      // Retourner les nouvelles données
      Navigator.pop(
        context,
        widget.userInfo.copyWith(
          firstname: _firstnameController.text.trim(),
          lastname: _lastnameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informations mises à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = context.fluidValue(minValue: 16, maxValue: 32);
    final spacing = context.fluidValue(minValue: 16, maxValue: 24);
    final titleSize = context.fluidValue(minValue: 18, maxValue: 22);
    final labelSize = context.fluidValue(minValue: 13, maxValue: 15);

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
          'Modifier mes informations',
          style: AppTextStyles.sectionTitle.copyWith(
            color: AppColors.textPrimary,
            fontSize: titleSize,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.isDesktop ? 600 : 500,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre de section
                  Text(
                    'Informations de livraison',
                    style: AppTextStyles.sectionTitle.copyWith(
                      fontSize: context.fluidValue(minValue: 16, maxValue: 18),
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: spacing),

                  // Prénom et Nom côte à côte sur desktop
                  if (context.isDesktop || context.isTablet)
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _firstnameController,
                            label: 'Prénom',
                            icon: Icons.person_outline,
                            labelSize: labelSize,
                            validator:
                                (v) =>
                                    v == null || v.trim().isEmpty
                                        ? 'Prénom requis'
                                        : null,
                          ),
                        ),
                        SizedBox(width: spacing),
                        Expanded(
                          child: _buildTextField(
                            controller: _lastnameController,
                            label: 'Nom',
                            icon: Icons.person,
                            labelSize: labelSize,
                            validator:
                                (v) =>
                                    v == null || v.trim().isEmpty
                                        ? 'Nom requis'
                                        : null,
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _buildTextField(
                      controller: _firstnameController,
                      label: 'Prénom',
                      icon: Icons.person_outline,
                      labelSize: labelSize,
                      validator:
                          (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'Prénom requis'
                                  : null,
                    ),
                    SizedBox(height: spacing),
                    _buildTextField(
                      controller: _lastnameController,
                      label: 'Nom',
                      icon: Icons.person,
                      labelSize: labelSize,
                      validator:
                          (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'Nom requis'
                                  : null,
                    ),
                  ],

                  SizedBox(height: spacing),

                  // Téléphone
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Numéro de téléphone',
                    icon: Icons.phone,
                    labelSize: labelSize,
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Téléphone requis';
                      }
                      final cleaned = v.replaceAll(RegExp(r'[\s\-\.\(\)]'), '');
                      if (!RegExp(r'^(\+33|0)[1-9]\d{8}$').hasMatch(cleaned)) {
                        return 'Numéro français invalide';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: spacing),

                  // Adresse
                  _buildTextField(
                    controller: _addressController,
                    label: 'Adresse de livraison',
                    icon: Icons.location_on,
                    labelSize: labelSize,
                    maxLines: 3,
                    validator:
                        (v) =>
                            v == null || v.trim().length < 10
                                ? 'Adresse complète requise (min 10 caractères)'
                                : null,
                  ),

                  SizedBox(height: spacing * 1.5),

                  // Note d'information
                  GlassCard(
                    padding: EdgeInsets.all(
                      context.fluidValue(minValue: 12, maxValue: 16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.info,
                          size: context.fluidValue(minValue: 18, maxValue: 22),
                        ),
                        SizedBox(width: spacing * 0.5),
                        Expanded(
                          child: Text(
                            'Ces informations seront utilisées pour la livraison de votre commande.',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: context.fluidValue(
                                minValue: 11,
                                maxValue: 13,
                              ),
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: spacing * 2),

                  // Bouton de sauvegarde
                  SizedBox(
                    width: double.infinity,
                    height: context.fluidValue(minValue: 48, maxValue: 56),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primary.withOpacity(
                          0.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          _isLoading
                              ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Text(
                                'Enregistrer les modifications',
                                style: TextStyle(
                                  fontSize: context.fluidValue(
                                    minValue: 14,
                                    maxValue: 16,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),

                  SizedBox(height: spacing),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required double labelSize,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: AppTextStyles.body.copyWith(fontSize: labelSize),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.caption.copyWith(fontSize: labelSize - 1),
        prefixIcon: Icon(icon, color: AppColors.primary),
        alignLabelWithHint: maxLines > 1,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.danger),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validator,
    );
  }
}
