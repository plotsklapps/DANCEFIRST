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

                    Map<String, dynamic>? selectedSub;
                    for (final Map<String, dynamic> s in filtered) {
                      if (s['id'] == selectedSubscriptionId) {
                        selectedSub = s;
                        break;
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        DropdownButtonFormField<String>(
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
                        ),
                        if (selectedSub != null) ...<Widget>[
                          const SizedBox(height: 16),
                          _buildSubscriptionDetails(context, selectedSub),
                        ],
                      ],
                    );
                  },
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateSubscriptionDetails(
    double price,
    int durationMonths,
  ) {
    final DateTime now = DateTime.now();
    final int today = now.day;
    final int currentMonthDays = DateTime(now.year, now.month + 1, 0).day;

    DateTime startDate;
    double proRataPrice = 0;
    int proRataDays = 0;
    String proRataMonthName = '';

    final int remainingDays = currentMonthDays - today + 1;

    if (today == 1) {
      startDate = DateTime(now.year, now.month);
    } else if (remainingDays <= 7) {
      startDate = DateTime(now.year, now.month + 1);
    } else {
      startDate = DateTime(now.year, now.month + 1);
      proRataDays = remainingDays;
      proRataPrice = price * (proRataDays / currentMonthDays);
      proRataMonthName = _getMonthName(now.month);
    }

    final DateTime lastDayOfContract = DateTime(
      startDate.year,
      startDate.month + durationMonths,
    ).subtract(const Duration(days: 1));
    final DateTime endOfContract = DateTime(
      startDate.year,
      startDate.month + durationMonths,
    );

    final double firstPaymentTotal = proRataPrice + price;

    return <String, dynamic>{
      'startDate': startDate,
      'lastDayOfContract': lastDayOfContract,
      'endOfContract': endOfContract,
      'proRataPrice': proRataPrice,
      'proRataDays': proRataDays,
      'totalDaysInMonth': currentMonthDays,
      'proRataMonthName': proRataMonthName,
      'firstPaymentTotal': firstPaymentTotal,
    };
  }

  String _getMonthName(int month) {
    const List<String> months = <String>[
      'januari',
      'februari',
      'maart',
      'april',
      'mei',
      'juni',
      'juli',
      'augustus',
      'september',
      'oktober',
      'november',
      'december',
    ];
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  Widget _buildSubscriptionDetails(
    BuildContext context,
    Map<String, dynamic> subscription,
  ) {
    final ThemeData theme = Theme.of(context);
    final String name = subscription['name'] as String? ?? '';
    final double price = (subscription['price'] as num? ?? 0.0).toDouble();

    // Determine contract duration.
    int durationMonths = 1;
    final String nameLower = name.toLowerCase();
    if (nameLower.contains('halfjaar') || nameLower.contains('6 maand')) {
      durationMonths = 6;
    } else if (nameLower.contains('2 jaar') || nameLower.contains('24 maand')) {
      durationMonths = 24;
    } else if (nameLower.contains('jaar') || nameLower.contains('12 maand')) {
      durationMonths = 12;
    }

    final Map<String, dynamic> details = _calculateSubscriptionDetails(
      price,
      durationMonths,
    );
    final DateTime startDate = details['startDate'] as DateTime;
    final DateTime lastDayOfContract = details['lastDayOfContract'] as DateTime;
    final DateTime endOfContract = details['endOfContract'] as DateTime;
    final double proRataPrice = details['proRataPrice'] as double;
    final int proRataDays = details['proRataDays'] as int;
    final String proRataMonthName = details['proRataMonthName'] as String;
    final double firstPaymentTotal = details['firstPaymentTotal'] as double;

    final String startDateStr =
        '${startDate.day} ${_getMonthName(startDate.month)} '
        '${startDate.year}';
    final String lastDayStr =
        '${lastDayOfContract.day} '
        '${_getMonthName(lastDayOfContract.month)} '
        '${lastDayOfContract.year}';
    final String endOfContractStr =
        '${endOfContract.day} '
        '${_getMonthName(endOfContract.month)} '
        '${endOfContract.year}';

    final bool hasProRata = proRataDays > 0;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Section: Dates.
          Row(
            children: <Widget>[
              Icon(
                Icons.calendar_today_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Looptijd & Termijnen',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            label: 'Ingangsdatum:',
            value: startDateStr,
            theme: theme,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            label: 'Minimale contractduur:',
            value:
                '$durationMonths ${durationMonths == 1 ? 'maand' : 'maanden'}',
            theme: theme,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            label: 'Contract looptijd t/m:',
            value: lastDayStr,
            theme: theme,
            valueStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Divider(height: 24),

          // Section: First payment.
          Row(
            children: <Widget>[
              Icon(
                Icons.payments_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Eerste Betaling (via incasso)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasProRata) ...<Widget>[
            _buildDetailRow(
              label:
                  'Naar rato ($proRataDays resterende dagen '
                  '$proRataMonthName):',
              value: '€${proRataPrice.toStringAsFixed(2)}',
              theme: theme,
            ),
            const SizedBox(height: 8),
          ],
          _buildDetailRow(
            label:
                'Eerste volledige maand (${_getMonthName(startDate.month)}):',
            value: '€${price.toStringAsFixed(2)}',
            theme: theme,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Eerste incasso (op $startDateStr):',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasProRata
                            ? 'Resterende dagen + eerste maand'
                            : 'Eerste volledige maand',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '€${firstPaymentTotal.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 24),

          // Section: Informational note.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  durationMonths == 1
                      ? 'Let op: Dit abonnement is maandelijks opzegbaar '
                            '(vóór de 14e van de maand). Wil je profiteren van '
                            'een voordeliger tarief? Kies dan bijvoorbeeld voor '
                            'een jaarabonnement (zie "Tarieven" '
                            'voor de voorwaarden).'
                      : 'Let op: Na $endOfContractStr wordt het '
                            'abonnement maandelijks opzegbaar. Om te blijven '
                            'profiteren van het voordeligere tarief, '
                            'kun je voor die tijd eenvoudig verlengen of '
                            'wijzigen in de app (zie "Tarieven" '
                            'voor de voorwaarden).',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required ThemeData theme,
    TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style:
              valueStyle ??
              theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
