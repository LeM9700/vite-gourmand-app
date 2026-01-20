import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class DishFormDialog extends StatefulWidget {
  final Map<String, dynamic>? dish;
  final Future<void> Function(Map<String, dynamic>) onSave;

  const DishFormDialog({super.key, this.dish, required this.onSave});

  @override
  State<DishFormDialog> createState() => _DishFormDialogState();
}

class _DishFormDialogState extends State<DishFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _allergensController;
  String _dishType = 'STARTER';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.dish?['name'] ?? '');
    _descriptionController = TextEditingController(text: widget.dish?['description'] ?? '');
    
    // Extraire les allergènes du plat s'il existe
    final allergens = widget.dish?['allergens'] as List<dynamic>?;
    final allergensList = allergens?.map((a) => a['allergen'] as String).toList() ?? [];
    _allergensController = TextEditingController(text: allergensList.join(', '));
    
    _dishType = widget.dish?['dish_type'] ?? 'STARTER';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _allergensController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.dish == null ? 'Créer un plat' : 'Modifier le plat'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nom', border: OutlineInputBorder()),
                validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'Requis';
                  if (v!.length < 10) return 'La description doit contenir au moins 10 caractères';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _dishType,
                decoration: const InputDecoration(labelText: 'Type de plat *', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'STARTER', child: Text('Entrée')),
                  DropdownMenuItem(value: 'MAIN', child: Text('Plat principal')),
                  DropdownMenuItem(value: 'DESSERT', child: Text('Dessert')),
                ],
                onChanged: (v) => setState(() => _dishType = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _allergensController,
                decoration: const InputDecoration(
                  labelText: 'Allergènes (séparés par des virgules)',
                  border: OutlineInputBorder(),
                  hintText: 'Ex: Gluten, Lactose, Arachides',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              // Parser les allergènes
              final allergensText = _allergensController.text.trim();
              final allergensList = allergensText.isEmpty 
                  ? <String>[]
                  : allergensText.split(',').map((a) => a.trim()).where((a) => a.isNotEmpty).toList();
              
              await widget.onSave({
                'name': _nameController.text,
                'description': _descriptionController.text,
                'dish_type': _dishType,
                'allergens': allergensList,
              });
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
