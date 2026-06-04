import 'package:dancefirst/services/firestore_service.dart';
import 'package:flutter/material.dart';

class SubscriptionDataCard extends StatelessWidget {
  const SubscriptionDataCard({
    required this.enrollmentType,
    required this.selectedSubscriptionId,
    required this.onEnrollmentTypeChanged,
    required this.onSubscriptionChanged,
    super.key,
  });

  final String enrollmentType;
  final String? selectedSubscriptionId;
  final ValueChanged<String> onEnrollmentTypeChanged;
  final ValueChanged<String?> onSubscriptionChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final FirestoreService firestoreService = FirestoreService();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.card_membership_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '3. Abonnement Keuze',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            SegmentedButton<String>(
              segments: const <ButtonSegment<String>>[
                ButtonSegment<String>(
                  value: 'DanceKids',
                  label: Text('Kids (4-18 jr)'),
                  icon: Icon(Icons.child_care),
                ),
                ButtonSegment<String>(
                  value: 'DanceFirst',
                  label: Text('Adults (18+)'),
                  icon: Icon(Icons.sports_gymnastics_outlined),
                ),
              ],
              selected: <String>{enrollmentType},
              onSelectionChanged: (Set<String> newSelection) {
                onEnrollmentTypeChanged(newSelection.first);
              },
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: firestoreService.getSubscriptionsStream(),
              builder:
                  (
                    BuildContext context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('Geen abonnementen beschikbaar.');
                    }

                    final List<Map<String, dynamic>> filtered = snapshot.data!
                        .where(
                          (Map<String, dynamic> s) =>
                              s['category'] == enrollmentType &&
                              (s['isActive'] as bool? ?? true),
                        )
                        .toList();

                    if (filtered.isEmpty) {
                      return const Text('Geen actieve abonnementen gevonden.');
                    }

                    return DropdownButtonFormField<String>(
                      initialValue: selectedSubscriptionId,
                      decoration: const InputDecoration(
                        labelText: 'Kies een abonnement *',
                        prefixIcon: Icon(Icons.check_circle_outline),
                      ),
                      items: filtered.map(
                        (Map<String, dynamic> s) {
                          return DropdownMenuItem<String>(
                            value: s['id'] as String,
                            child: Text(
                              '${s['name']} (€${s['price']})',
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        },
                      ).toList(),
                      onChanged: onSubscriptionChanged,
                      validator: (String? v) =>
                          v == null ? 'Selecteer een abonnement' : null,
                    );
                  },
            ),
          ],
        ),
      ),
    );
  }
}
