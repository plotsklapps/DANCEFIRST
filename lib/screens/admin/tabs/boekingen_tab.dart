import 'package:dancefirst/constants/icon_library.dart';
import 'package:dancefirst/services/firestore_service.dart';
import 'package:dancefirst/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:signals/signals_flutter.dart';

final selectedDateSignal = signal<DateTime>(DateTime.now());

class BoekingenTab extends StatelessWidget {
  const BoekingenTab({required this.firestore, super.key});

  final FirestoreService firestore;

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
                  'Boekingen: $dateString ($currentDayName)',
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
                  return const Center(child: Text('Geen rooster.'));

                final dayClasses = baseSnapshot.data!
                    .where(
                      (c) =>
                          c['day'] == currentDayName && c['type'] == 'adults',
                    )
                    .toList();
                if (dayClasses.isEmpty)
                  return const Center(child: Text('Geen lessen.'));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: dayClasses.length,
                  itemBuilder: (context, index) {
                    final c = dayClasses[index];
                    return StreamBuilder<List<Map<String, dynamic>>>(
                      stream: firestore.getBookingsStream(
                        dateString,
                        c['id'] as String,
                      ),
                      builder: (context, bookingsSnapshot) {
                        final bookings = bookingsSnapshot.data ?? [];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ExpansionTile(
                            title: Text(c['name'] as String? ?? ''),
                            subtitle: Text(
                              'Tijd: ${c['time']} | Boekingen: ${bookings.length}/${c['maxParticipants']}',
                            ),
                            children: bookings
                                .map(
                                  (b) => ListTile(
                                    leading: const PhosphorIcon(
                                      IconLibrary.person,
                                      color: Colors.teal,
                                    ),
                                    title: Text(
                                      b['profileName'] as String? ?? 'Onbekend',
                                    ),
                                    trailing: IconButton(
                                      icon: const PhosphorIcon(
                                        IconLibrary.delete,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () async {
                                        await firestore.cancelBooking(
                                          date: dateString,
                                          classId: c['id'] as String,
                                          profileId: b['profileId'] as String,
                                        );
                                        ToastService.showSuccess(
                                          title: 'Geannuleerd',
                                          subtitle: 'Boeking verwijderd.',
                                        );
                                      },
                                    ),
                                  ),
                                )
                                .toList(),
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
