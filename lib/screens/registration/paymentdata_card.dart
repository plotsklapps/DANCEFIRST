import 'package:flutter/material.dart';

class PaymentDataCard extends StatelessWidget {
  const PaymentDataCard({
    required this.ibanController,
    required this.accountHolderController,
    required this.mandateAccepted,
    required this.onMandateChanged,
    required this.isValidIban,
    super.key,
  });

  final TextEditingController ibanController;
  final TextEditingController accountHolderController;
  final bool mandateAccepted;
  final ValueChanged<bool> onMandateChanged;
  final bool Function(String) isValidIban;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.account_balance_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '4. Automatische Incasso (SEPA)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            TextFormField(
              controller: ibanController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'IBAN Nummer *',
                prefixIcon: Icon(Icons.credit_card_outlined),
              ),
              validator: (String? v) {
                if (v == null || v.trim().isEmpty) {
                  return 'IBAN is verplicht';
                }
                if (!isValidIban(v.trim())) {
                  return 'Ongeldig Europees IBAN formaat';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: accountHolderController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Naam Rekeninghouder *',
                prefixIcon: Icon(Icons.person_pin_outlined),
              ),
              validator: (String? v) => (v == null || v.trim().isEmpty)
                  ? 'Naam rekeninghouder is verplicht'
                  : null,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Ik geef DanceFirst toestemming voor automatische'
                ' incasso rond de 1e van de maand *',
                style: TextStyle(fontSize: 13),
              ),
              value: mandateAccepted,
              onChanged: onMandateChanged,
            ),
          ],
        ),
      ),
    );
  }
}
