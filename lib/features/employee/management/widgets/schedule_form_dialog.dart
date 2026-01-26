import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/colors.dart';

class ScheduleFormDialog extends StatefulWidget {
  final Map<String, dynamic>? schedule;
  final Future<void> Function(Map<String, dynamic>) onSave;

  const ScheduleFormDialog({super.key, this.schedule, required this.onSave});

  @override
  State<ScheduleFormDialog> createState() => _ScheduleFormDialogState();
}

class _ScheduleFormDialogState extends State<ScheduleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  int _dayOfWeek = 0;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;

  @override
  void initState() {
    super.initState();
    _dayOfWeek = widget.schedule?['day_of_week'] ?? 0;
    _startTimeController = TextEditingController(
      text: widget.schedule?['open_time'] ?? '09:00',
    );
    _endTimeController = TextEditingController(
      text: widget.schedule?['close_time'] ?? '18:00',
    );
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.schedule == null ? 'Créer un horaire' : 'Modifier l\'horaire',
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              value: _dayOfWeek,
              decoration: const InputDecoration(
                labelText: 'Jour',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 0, child: Text('Lundi')),
                DropdownMenuItem(value: 1, child: Text('Mardi')),
                DropdownMenuItem(value: 2, child: Text('Mercredi')),
                DropdownMenuItem(value: 3, child: Text('Jeudi')),
                DropdownMenuItem(value: 4, child: Text('Vendredi')),
                DropdownMenuItem(value: 5, child: Text('Samedi')),
                DropdownMenuItem(value: 6, child: Text('Dimanche')),
              ],
              onChanged: (v) => setState(() => _dayOfWeek = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _startTimeController,
              decoration: const InputDecoration(
                labelText: 'Heure début (HH:MM)',
                border: OutlineInputBorder(),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
              ],
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Requis';
                if (!RegExp(r'^([0-1][0-9]|2[0-3]):[0-5][0-9]$').hasMatch(v!))
                  return 'Format invalide';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _endTimeController,
              decoration: const InputDecoration(
                labelText: 'Heure fin (HH:MM)',
                border: OutlineInputBorder(),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
              ],
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Requis';
                if (!RegExp(r'^([0-1][0-9]|2[0-3]):[0-5][0-9]$').hasMatch(v!))
                  return 'Format invalide';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              await widget.onSave({
                'day_of_week': _dayOfWeek,
                'open_time': _startTimeController.text,
                'close_time': _endTimeController.text,
                'is_closed': false,
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
