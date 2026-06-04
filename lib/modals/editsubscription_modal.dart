import 'package:dancefirst/modals/modal_title.dart';
import 'package:dancefirst/services/firestore_service.dart';
import 'package:dancefirst/services/toast_service.dart';
import 'package:flutter/material.dart';

class EditSubscriptionModal extends StatefulWidget {
  const EditSubscriptionModal({
    this.subscription,
    super.key,
  });

  final Map<String, dynamic>? subscription;

  @override
  State<EditSubscriptionModal> createState() {
    return _EditSubscriptionModalState();
  }
}

class _EditSubscriptionModalState extends State<EditSubscriptionModal> {
  final FirestoreService _firestore = FirestoreService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descController;

  late String _selectedCategory;
  late bool _isActive;
  late bool _isEdit;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.subscription != null;

    _idController = TextEditingController(
      text: _isEdit ? (widget.subscription!['id'] as String? ?? '') : '',
    );
    _nameController = TextEditingController(
      text: _isEdit ? (widget.subscription!['name'] as String? ?? '') : '',
    );
    _priceController = TextEditingController(
      text: _isEdit ? (widget.subscription!['price']?.toString() ?? '') : '',
    );
    _descController = TextEditingController(
      text: _isEdit
          ? (widget.subscription!['description'] as String? ?? '')
          : '',
    );

    _selectedCategory = _isEdit
        ? (widget.subscription!['category'] as String? ?? 'DanceKids')
        : 'DanceKids';
    _isActive = !_isEdit || (widget.subscription!['isActive'] as bool? ?? true);
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ModalTitle(
              title: _isEdit ? 'Abonnement Bewerken' : 'Nieuw Abonnement',
            ),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Categorie'),
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(
                  value: 'DanceKids',
                  child: Text('DanceKids (4-18 jaar)'),
                ),
                DropdownMenuItem<String>(
                  value: 'DanceFirst',
                  child: Text('DanceFirst (18+)'),
                ),
              ],
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _idController,
              enabled: !_isEdit, // ID cannot be changed once created
              decoration: const InputDecoration(
                labelText: 'Abonnement Code (bijv. DK-1-J)',
              ),
              validator: (String? v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Code is verplicht';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Naam (bijv. 1x per week jaar)',
              ),
              validator: (String? v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Naam is verplicht';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Prijs per maand (€)',
              ),
              validator: (String? v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Prijs is verplicht';
                }
                if (double.tryParse(v.trim()) == null) {
                  return 'Geef een getal op';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Beschrijving (Optioneel)',
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Actief (Zichtbaar bij inschrijving)'),
              value: _isActive,
              onChanged: (bool value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
            const SizedBox(height: 20),
            FilledButton.tonal(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await _firestore.saveSubscription(
                    id: _idController.text.trim().toUpperCase(),
                    category: _selectedCategory,
                    name: _nameController.text.trim(),
                    price: double.parse(_priceController.text.trim()),
                    description: _descController.text.trim(),
                    isActive: _isActive,
                  );
                  ToastService.showSuccess(
                    title: _isEdit
                        ? 'Abonnement bijgewerkt'
                        : 'Abonnement toegevoegd',
                    subtitle: 'De wijziging is opgeslagen in Firestore.',
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Opslaan'),
            ),
          ],
        ),
      ),
    );
  }
}
