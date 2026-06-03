import 'package:dancefirst/constants/icon_library.dart';
import 'package:dancefirst/modals/overrideclass_modal.dart';
import 'package:dancefirst/services/firestore_service.dart';
import 'package:dancefirst/services/modal_service.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:signals/signals_flutter.dart';

final Signal<DateTime> sSelectedDate = Signal<DateTime>(
  DateTime.now(),
  options: const SignalOptions<DateTime>(name: 'sSelectedDate'),
);

class HuidigRoosterTab extends SignalWidget {
  HuidigRoosterTab({super.key});
  final FirestoreService _firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final DateTime selectedDate = sSelectedDate.value;
    final String dateString =
        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
    final String currentDayName = <String>[
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
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Datum: $dateString ($currentDayName)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 30),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) sSelectedDate.value = picked;
                  },
                  child: const Text('Kies Datum'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestore.getMergedScheduleStream(dateString),
              builder:
                  (
                    BuildContext context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('Geen rooster gevonden.'),
                      );
                    }

                    final List<Map<String, dynamic>> dayClasses = snapshot.data!
                        .where(
                          (Map<String, dynamic> classData) =>
                              classData['day'] == currentDayName,
                        )
                        .toList();
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: dayClasses.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Map<String, dynamic> classData =
                            dayClasses[index];
                        final bool isCancelled =
                            classData['isCancelled'] as bool? ?? false;
                        final String teacher =
                            classData['teacherOverride'] as String? ??
                            classData['teacher'] as String;
                        final String time =
                            classData['timeOverride'] as String? ??
                            classData['time'] as String;

                        return Card(
                          color: isCancelled ? Colors.red.shade50 : null,
                          child: ListTile(
                            leading: Text(time),
                            title: Text(
                              classData['name'] as String? ?? '',
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
                              onPressed: () async {
                                await ModalService.showModal(
                                  context: context,
                                  child: OverrideClassModal(
                                    dateStr: dateString,
                                    classData: classData,
                                  ),
                                );
                              },
                            ),
                          ),
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
