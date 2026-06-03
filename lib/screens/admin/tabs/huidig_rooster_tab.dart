import 'package:dancefirst/constants/icon_library.dart';
import 'package:dancefirst/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:signals/signals_flutter.dart';

final selectedDateSignal = signal<DateTime>(DateTime.now());

class HuidigRoosterTab extends StatelessWidget {
  HuidigRoosterTab({super.key});
  final FirestoreService firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final selectedDate = selectedDateSignal.watch(context);
    final dateString =
        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
    final currentDayName = [
      'Zondag',
      'Maandag',
      'Dinsdag',
      'Woensdag',
      'Donderdag',
      'Vrijdag',
      'Zaterdag',
    ][selectedDate.weekday % 7];

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
                              onPressed: () => _showOverrideSheet(
                                context,
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

  Future<void> _showOverrideSheet(
    BuildContext context,
    String dateStr,
    Map<String, dynamic> c,
    Map<String, dynamic>? currentOverride,
  ) async {
    final teacherOverrideC = TextEditingController(
      text:
          currentOverride?['teacherOverride'] as String? ??
          c['teacher'] as String,
    );
    final timeOverrideC = TextEditingController(
      text: currentOverride?['timeOverride'] as String? ?? c['time'] as String,
    );
    final notesC = TextEditingController(
      text: currentOverride?['notes'] as String? ?? '',
    );
    bool isCancelled = currentOverride?['isCancelled'] as bool? ?? false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ad-hoc Wijziging',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SwitchListTile(
                title: const Text('Geannuleerd?'),
                value: isCancelled,
                onChanged: (val) => setModalState(() => isCancelled = val),
              ),
              if (!isCancelled) ...[
                TextFormField(
                  controller: teacherOverrideC,
                  decoration: const InputDecoration(
                    labelText: 'Docent Vervanger',
                  ),
                ),
                TextFormField(
                  controller: timeOverrideC,
                  decoration: const InputDecoration(
                    labelText: 'Tijd Aanpassing',
                  ),
                ),
              ],
              TextFormField(
                controller: notesC,
                decoration: const InputDecoration(labelText: 'Opmerkingen'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await firestore.removeScheduleOverride(
                          dateStr,
                          c['id'] as String,
                        );
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text(
                        'Herstel',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        await firestore.saveScheduleOverride(
                          date: dateStr,
                          classId: c['id'] as String,
                          isCancelled: isCancelled,
                          teacherOverride: isCancelled
                              ? null
                              : teacherOverrideC.text.trim(),
                          timeOverride: isCancelled
                              ? null
                              : timeOverrideC.text.trim(),
                          notes: notesC.text.trim(),
                        );
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('Opslaan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
