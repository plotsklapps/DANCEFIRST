import 'package:flutter/material.dart';

class PersonalDataCard extends StatelessWidget {
  const PersonalDataCard({
    required this.firstNameController,
    required this.lastNameController,
    required this.dobController,
    required this.phoneController,
    required this.selectedCountryCode,
    required this.countryCodes,
    required this.onCountryCodeChanged,
    super.key,
  });

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController dobController;
  final TextEditingController phoneController;
  final String selectedCountryCode;
  final List<Map<String, String>> countryCodes;
  final ValueChanged<String?> onCountryCodeChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.person_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '1. Persoonsgegevens',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            TextFormField(
              controller: firstNameController,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Voornaam *',
                prefixIcon: Icon(Icons.person_add_outlined),
              ),
              validator: (String? v) {
                return (v == null || v.trim().isEmpty)
                    ? 'Voornaam is verplicht'
                    : null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: lastNameController,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Achternaam *',
                prefixIcon: Icon(Icons.person_add_outlined),
              ),
              validator: (String? v) {
                return (v == null || v.trim().isEmpty)
                    ? 'Achternaam is verplicht'
                    : null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: dobController,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(
                labelText: 'Geboortedatum * (DD-MM-YYYY)',
                prefixIcon: Icon(Icons.cake_outlined),
              ),
              validator: (String? v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Geboortedatum is verplicht';
                }
                if (!RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(v.trim())) {
                  return 'Formaat moet DD-MM-YYYY zijn';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 100,
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedCountryCode,
                    items: countryCodes.map(
                      (Map<String, String> c) {
                        return DropdownMenuItem<String>(
                          value: c['code'],
                          child: Text(c['name']!),
                        );
                      },
                    ).toList(),
                    onChanged: onCountryCodeChanged,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Telefoonnummer *',
                      prefixIcon: Icon(Icons.phone_android_outlined),
                    ),
                    validator: (String? v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Telefoonnummer is verplicht';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
