import 'package:dancefirst/services/firestore_service.dart';
import 'package:dancefirst/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

Signal<DateTime> selectedDateSignal = Signal<DateTime>(DateTime.now());

class KlantenTab extends StatelessWidget {
  KlantenTab({super.key});
  final FirestoreService _firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final DateTime selectedDate = selectedDateSignal.watch(context);
    final String dateString =
        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
    final List<String> weekDays = <String>[
      'Zondag',
      'Maandag',
      'Dinsdag',
      'Woensdag',
      'Donderdag',
      'Vrijdag',
      'Zaterdag',
    ];
    final String currentDayName = weekDays[selectedDate.weekday % 7];

    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Boekingen: $dateString ($currentDayName)',
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
                    if (picked != null) selectedDateSignal.value = picked;
                  },
                  child: const Text('Kies Datum'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestore.getBaseScheduleStream(),
              builder:
                  (
                    BuildContext context,
                    AsyncSnapshot<List<Map<String, dynamic>>> baseSnapshot,
                  ) {
                    if (baseSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!baseSnapshot.hasData || baseSnapshot.data!.isEmpty) {
                      return const Center(child: Text('Geen rooster.'));
                    }

                    final List<Map<String, dynamic>> dayClasses = baseSnapshot
                        .data!
                        .where(
                          (Map<String, dynamic> c) =>
                              c['day'] == currentDayName &&
                              c['type'] == 'adults',
                        )
                        .toList();
                    if (dayClasses.isEmpty) {
                      return const Center(child: Text('Geen lessen.'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: dayClasses.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Map<String, dynamic> c = dayClasses[index];
                        return StreamBuilder<List<Map<String, dynamic>>>(
                          stream: _firestore.getBookingsStream(
                            dateString,
                            c['id'] as String,
                          ),
                          builder:
                              (
                                BuildContext context,
                                AsyncSnapshot<List<Map<String, dynamic>>>
                                bookingsSnapshot,
                              ) {
                                final List<Map<String, dynamic>> bookings =
                                    bookingsSnapshot.data ??
                                    <Map<String, dynamic>>[];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ExpansionTile(
                                    title: Text(c['name'] as String? ?? ''),
                                    subtitle: Text(
                                      'Tijd: ${c['time']} | Boekingen: ${bookings.length}/${c['maxParticipants']}',
                                    ),
                                    children: bookings
                                        .map(
                                          (Map<String, dynamic> b) => ListTile(
                                            leading: const Icon(
                                              Icons.person,
                                              color: Colors.teal,
                                            ),
                                            title: Text(
                                              b['profileName'] as String? ??
                                                  'Onbekend',
                                            ),
                                            trailing: IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.redAccent,
                                              ),
                                              onPressed: () async {
                                                await _firestore.cancelBooking(
                                                  date: dateString,
                                                  classId: c['id'] as String,
                                                  profileId:
                                                      b['profileId'] as String,
                                                );
                                                ToastService.showSuccess(
                                                  title: 'Geannuleerd',
                                                  subtitle:
                                                      'Boeking verwijderd.',
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
