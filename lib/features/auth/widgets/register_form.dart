import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/primary_button.dart';
import '../services/auth_service.dart';
import '../models/auth_models.dart';
import '../../navigation/main_navigation_page.dart';

enum RegisterStep { 
  personal, 
  credentials 
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  RegisterStep _currentStep = RegisterStep.personal;
  final _pageController = PageController();

  // Controllers pour étape 1 - Informations personnelles
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // Controllers pour étape 2 - Identifiants
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep != RegisterStep.credentials) {
        setState(() {
          _currentStep = RegisterStep.credentials;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _handleRegister();
      }
    }
  }

  void _previousStep() {
    if (_currentStep != RegisterStep.personal) {
      setState(() {
        _currentStep = RegisterStep.personal;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case RegisterStep.personal:
        if (_nameController.text.trim().isEmpty) {
          _showErrorMessage('Le nom est requis');
          return false;
        }
        if (_surnameController.text.trim().isEmpty) {
          _showErrorMessage('Le prénom est requis');
          return false;
        }
        if (_phoneController.text.trim().isEmpty) {
          _showErrorMessage('Le téléphone est requis');
          return false;
        }
        if (!RegExp(r'^[+]?[0-9]{10,}$').hasMatch(_phoneController.text.replaceAll(' ', ''))) {
          _showErrorMessage('Format de téléphone invalide');
          return false;
        }
        if (_addressController.text.trim().isEmpty) {
          _showErrorMessage('L\'adresse est requise');
          return false;
        }
        return true;
      case RegisterStep.credentials:
        if (_emailController.text.trim().isEmpty) {
          _showErrorMessage('L\'email est requis');
          return false;
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text)) {
          _showErrorMessage('Format d\'email invalide');
          return false;
        }
        if (_passwordController.text.isEmpty) {
          _showErrorMessage('Le mot de passe est requis');
          return false;
        }
        if (_passwordController.text.length < 6) {
          _showErrorMessage('Le mot de passe doit contenir au moins 6 caractères');
          return false;
        }
        return true;
    }
  }

  Future<void> _handleRegister() async {
    setState(() => _isLoading = true);

    try {
      final request = RegisterRequest(
        firstname: _surnameController.text.trim(),
        lastname: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final response = await _authService.register(request);
      
      if (mounted) {
        _showSuccessMessage('Inscription réussie ! Bienvenue ${response.user.fullName}');
        await Future.delayed(const Duration(seconds: 1));
        // Rediriger vers la navigation principale
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Indicateur d'étapes
          _buildStepIndicator(),

          const SizedBox(height: 24),

          // Titre de l'étape
          Text(
            _getStepTitle(),
            style: AppTextStyles.sectionTitle.copyWith(
              color: Colors.white,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Contenu des étapes
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPersonalStep(),
                _buildCredentialsStep(),
              ],
            ),
          ),

          // Boutons de navigation
          Row(
            children: [
              if (_currentStep != RegisterStep.personal)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previousStep,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Retour',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              if (_currentStep != RegisterStep.personal)
                const SizedBox(width: 16),

              Expanded(
                child: PrimaryButton(
                  label: _currentStep == RegisterStep.credentials
                      ? 'Créer mon compte'
                      : 'Suivant',
                  onPressed: _isLoading ? null : _nextStep,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepDot(RegisterStep.personal),
        _buildStepLine(),
        _buildStepDot(RegisterStep.credentials),
      ],
    );
  }

  Widget _buildStepDot(RegisterStep step) {
    final isActive = _currentStep.index >= step.index;
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.primary : Colors.white.withOpacity(0.3),
      ),
    );
  }

  Widget _buildStepLine() {
    return Container(
      width: 40,
      height: 2,
      color: Colors.white.withOpacity(0.3),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case RegisterStep.personal:
        return 'Vos informations';
      case RegisterStep.credentials:
        return 'Identifiants de connexion';
    }
  }

  Widget _buildPersonalStep() {
    return Column(
      children: [
        _buildTextField(
          controller: _nameController,
          hintText: 'Nom',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _surnameController,
          hintText: 'Prénom',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          hintText: 'Téléphone',
          keyboardType: TextInputType.phone,
          prefixText: '+33 ',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _addressController,
          hintText: 'Adresse complète',
        ),
      ],
    );
  }

  Widget _buildCredentialsStep() {
    return Column(
      children: [
        _buildTextField(
          controller: _emailController,
          hintText: 'votre@email.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          hintText: 'Mot de passe',
          obscureText: !_isPasswordVisible,
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.white70,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Le mot de passe doit contenir au moins 6 caractères.',
          style: AppTextStyles.caption.copyWith(
            color: Colors.white70,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? prefixText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: AppTextStyles.body.copyWith(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.body.copyWith(
            color: Colors.white60,
          ),
          prefixText: prefixText,
          prefixStyle: AppTextStyles.body.copyWith(
            color: Colors.white,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}