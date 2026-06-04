import 'package:flutter/material.dart';

class AddressDataCard extends StatelessWidget {
  const AddressDataCard({
    required this.addressController,
    required this.zipController,
    required this.cityController,
    super.key,
  });

  final TextEditingController addressController;
  final TextEditingController zipController;
  final TextEditingController cityController;

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
                Icon(Icons.home_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '2. Adresgegevens',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            TextFormField(
              controller: addressController,
              keyboardType: TextInputType.streetAddress,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Straatnaam & Huisnummer *',
                prefixIcon: Icon(Icons.add_location_alt_outlined),
              ),
              validator: (String? v) {
                return (v == null || v.trim().isEmpty)
                    ? 'Adres is verplicht'
                    : null;
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: zipController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Postcode *',
                      hintText: '1234AB',
                      prefixIcon: Icon(Icons.my_location_outlined),
                    ),
                    validator: (String? v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Verplicht';
                      }
                      if (!RegExp(
                        r'^\d{4}\s?[a-zA-Z]{2}$',
                      ).hasMatch(v.trim())) {
                        return 'Formaat: 1234AB';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: cityController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Woonplaats *',
                      prefixIcon: Icon(Icons.location_city_outlined),
                    ),
                    validator: (String? v) =>
                        (v == null || v.trim().isEmpty) ? 'Verplicht' : null,
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
