import 'package:dancefirst/constants/icon_library.dart';
import 'package:dancefirst/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:signals/signals_flutter.dart';

final selectedDateSignal = signal<DateTime>(DateTime.now());

class HuidigRoosterTab extends StatelessWidget {
  const HuidigRoosterTab({
    required this.firestore,
    required this.showOverrideDialog,
    super.key,
  });

  final FirestoreService firestore;
  final Function(String, Map<String, dynamic>, Map<String, dynamic>?)
  showOverrideDialog;

  @override
  Widget build(BuildContext context) {
    final selectedDate = selectedDateSignal.watch(context);
    final dateString =
        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
    final weekDays = [
      'Zondag',
      'Maandag',
      'Dinsdag',
      'Woensdag',
      'Donderdag',
      'Vrijdag',
      'Zaterdag',
    ];
    final currentDayName = weekDays[selectedDate.weekday % 7];

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Datum: $dateString ($currentDayName)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 30),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) selectedDateSignal.value = picked;
                  },
                  child: const Text('Kies Datum'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: firestore.getBaseScheduleStream(),
              builder: (context, baseSnapshot) {
                if (baseSnapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (!baseSnapshot.hasData || baseSnapshot.data!.isEmpty)
                  return const Center(child: Text('Geen basisrooster.'));
                final dayClasses = baseSnapshot.data!
                    .where((c) => c['day'] == currentDayName)
                    .toList();

                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: firestore.getScheduleOverridesStream(dateString),
                  builder: (context, overrideSnapshot) {
                    final overrides = overrideSnapshot.data ?? [];
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: dayClasses.length,
                      itemBuilder: (context, index) {
                        final c = dayClasses[index];
                        final overrideDoc = overrides.firstWhere(
                          (o) => o['classId'] == c['id'],
                          orElse: () => {},
                        );
                        final isCancelled =
                            overrideDoc['isCancelled'] as bool? ?? false;
                        final teacher =
                            overrideDoc['teacherOverride'] as String? ??
                            c['teacher'] as String;
                        final time =
                            overrideDoc['timeOverride'] as String? ??
                            c['time'] as String;

                        return Card(
                          color: isCancelled ? Colors.red.shade50 : null,
                          child: ListTile(
                            leading: Text(time),
                            title: Text(
                              c['name'] as String? ?? '',
                              style: TextStyle(
                                decoration: isCancelled
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: Text(
                              'Docent: $teacher${isCancelled ? ' (GEANNULEERD)' : ''}',
                            ),
                            trailing: IconButton(
                              icon: const PhosphorIcon(
                                IconLibrary.edit,
                                color: Colors.teal,
                              ),
                              onPressed: () => showOverrideDialog(
                                dateString,
                                c,
                                overrideDoc,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
