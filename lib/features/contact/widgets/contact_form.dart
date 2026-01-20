import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/primary_button.dart';
import '../services/contact_service.dart';
import '../models/contact_models.dart';

class ContactForm extends StatefulWidget {
  final VoidCallback? onMessageSent;

  const ContactForm({
    super.key,
    this.onMessageSent,
  });

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactService = ContactService();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSendMessage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final request = ContactRequest(
        email: _emailController.text.trim(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      final response = await _contactService.sendMessage(request);
      
      if (mounted) {
        _showSuccessMessage(response.message);
        _clearForm();
        widget.onMessageSent?.call();
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

  void _clearForm() {
    _emailController.clear();
    _titleController.clear();
    _descriptionController.clear();
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre du formulaire
              Text(
                'Envoyez-nous un message',
                style: AppTextStyles.sectionTitle.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 20),

              // Champ email
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                hintText: 'votre@email.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email requis';
                  }
                  if (!RegExp(r'^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$').hasMatch(value.trim())) {
                    return 'Format invalide';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Champ sujet
              _buildTextField(
                controller: _titleController,
                label: 'Sujet',
                hintText: 'Sujet de votre message',
                prefixIcon: Icons.subject_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Sujet requis';
                  }
                  if (value.trim().length < 3) {
                    return 'Minimum 3 caractères';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Champ message
              _buildTextField(
                controller: _descriptionController,
                label: 'Message',
                hintText: 'Décrivez votre demande...',
                prefixIcon: Icons.message_outlined,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Message requis';
                  }
                  if (value.trim().length < 10) {
                    return 'Minimum 10 caractères';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Bouton d'envoi
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: _isLoading ? 'Envoi en cours...' : 'Envoyer',
                  onPressed: _isLoading ? null : _handleSendMessage,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
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
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            style: AppTextStyles.body.copyWith(color: Colors.white),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTextStyles.body.copyWith(
                color: Colors.white60,
              ),
              prefixIcon: Icon(
                prefixIcon,
                color: Colors.white70,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: maxLines > 1 ? 20 : 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}