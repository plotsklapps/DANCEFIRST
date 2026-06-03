import 'package:dancefirst/constants/icon_library.dart';
import 'package:dancefirst/services/firestore_service.dart';
import 'package:dancefirst/services/toast_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

enum DanceGroup { kids, adults }

class RoosterScreen extends StatefulWidget {
  const RoosterScreen({super.key});

  @override
  State<RoosterScreen> createState() {
    return _RoosterScreenState();
  }
}

class _RoosterScreenState extends State<RoosterScreen> {
  DanceGroup selectedDanceGroup = DanceGroup.kids;
  DateTime _selectedDate = DateTime.now();
  final FirestoreService _firestore = FirestoreService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final String dateString =
        '${_selectedDate.year}-'
        '${_selectedDate.month.toString().padLeft(2, '0')}-'
        '${_selectedDate.day.toString().padLeft(2, '0')}';
    final List<String> weekDays = <String>[
      'Zondag',
      'Maandag',
      'Dinsdag',
      'Woensdag',
      'Donderdag',
      'Vrijdag',
      'Zaterdag',
    ];
    final String currentDayName = weekDays[_selectedDate.weekday % 7];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: <Widget>[
          // GROUP SELECTION
          Row(
            children: <Widget>[
              Expanded(
                child: SegmentedButton<DanceGroup>(
                  segments: const <ButtonSegment<DanceGroup>>[
                    ButtonSegment<DanceGroup>(
                      value: DanceGroup.kids,
                      label: Text('Kids (4-18)'),
                    ),
                    ButtonSegment<DanceGroup>(
                      value: DanceGroup.adults,
                      label: Text('Volwassenen (18+)'),
                    ),
                  ],
                  selected: <DanceGroup>{selectedDanceGroup},
                  onSelectionChanged: (Set<DanceGroup> newSelection) {
                    setState(() {
                      selectedDanceGroup = newSelection.first;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // DATE PICKER BAR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Datum: $dateString ($currentDayName)',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 7)),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                icon: const PhosphorIcon(IconLibrary.calendar, size: 16),
                label: const Text('Kies Datum'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // SCHEDULE VIEW
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
                      return const Center(
                        child: Text('Geen basisrooster gevonden.'),
                      );
                    }

                    // Filter by selected day and category (kids vs adults)
                    final List<Map<String, dynamic>> dayClasses = baseSnapshot
                        .data!
                        .where(
                          (Map<String, dynamic> c) =>
                              c['day'] == currentDayName &&
                              c['type'] ==
                                  (selectedDanceGroup == DanceGroup.kids
                                      ? 'kids'
                                      : 'adults'),
                        )
                        .toList();

                    if (dayClasses.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Text(
                            'Geen lessen gepland voor $currentDayName.',
                          ),
                        ),
                      );
                    }

                    // Sort by time
                    dayClasses.sort(
                      (Map<String, dynamic> a, Map<String, dynamic> b) =>
                          (a['time'] as String).compareTo(b['time'] as String),
                    );

                    return StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _firestore.getScheduleOverridesStream(dateString),
                      builder:
                          (
                            BuildContext context,
                            AsyncSnapshot<List<Map<String, dynamic>>>
                            overridesSnapshot,
                          ) {
                            final List<Map<String, dynamic>> overrides =
                                overridesSnapshot.data ??
                                <Map<String, dynamic>>[];

                            return ListView.builder(
                              itemCount: dayClasses.length,
                              itemBuilder: (BuildContext context, int index) {
                                final Map<String, dynamic> c =
                                    dayClasses[index];
                                final String classId = c['id'] as String;

                                // Check if there is an override for this class
                                final Map<String, dynamic> overrideDoc =
                                    overrides.firstWhere(
                                      (Map<String, dynamic> o) =>
                                          o['classId'] == classId,
                                      orElse: () => <String, dynamic>{},
                                    );

                                final bool isCancelled =
                                    overrideDoc['isCancelled'] as bool? ??
                                    false;
                                final String teacher =
                                    overrideDoc['teacherOverride'] as String? ??
                                    c['teacher'] as String;
                                final String time =
                                    overrideDoc['timeOverride'] as String? ??
                                    c['time'] as String;
                                final String? notes =
                                    overrideDoc['notes'] as String?;

                                return StreamBuilder<
                                  List<Map<String, dynamic>>
                                >(
                                  stream: _firestore.getBookingsStream(
                                    dateString,
                                    classId,
                                  ),
                                  builder:
                                      (
                                        BuildContext context,
                                        AsyncSnapshot<
                                          List<Map<String, dynamic>>
                                        >
                                        bookingsSnapshot,
                                      ) {
                                        final List<Map<String, dynamic>>
                                        bookings =
                                            bookingsSnapshot.data ??
                                            <Map<String, dynamic>>[];
                                        final int currentBookingsCount =
                                            bookings.length;
                                        final int maxParticipants =
                                            c['maxParticipants'] as int? ?? 20;

                                        // Check if current user is booked
                                        final bool isAlreadyBooked = bookings
                                            .any(
                                              (Map<String, dynamic> b) =>
                                                  b['userId'] ==
                                                  _currentUser?.uid,
                                            );

                                        return Card(
                                          margin: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          color: isCancelled
                                              ? Colors.red.shade50
                                              : null,
                                          child: ListTile(
                                            leading: Text(
                                              time,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                decoration: isCancelled
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                            ),
                                            title: Text(
                                              c['name'] as String? ?? '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                decoration: isCancelled
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text('Docent: $teacher'),
                                                if (selectedDanceGroup ==
                                                    DanceGroup.adults)
                                                  Text(
                                                    'Plekken bezet: $currentBookingsCount '
                                                    '/ $maxParticipants',
                                                    style: TextStyle(
                                                      color:
                                                          currentBookingsCount >=
                                                              maxParticipants
                                                          ? Colors.red
                                                          : Colors.teal,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                if (notes != null &&
                                                    notes.isNotEmpty)
                                                  Text(
                                                    'Let op: $notes',
                                                    style: const TextStyle(
                                                      color: Colors.deepOrange,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            trailing:
                                                selectedDanceGroup ==
                                                        DanceGroup.adults &&
                                                    !isCancelled
                                                ? FilledButton.tonal(
                                                    onPressed: isAlreadyBooked
                                                        ? () {
                                                            _cancelBookingDialog(
                                                              dateString,
                                                              classId,
                                                              bookings,
                                                            );
                                                          }
                                                        : currentBookingsCount >=
                                                              maxParticipants
                                                        ? null // Full
                                                        : () {
                                                            _showBookingDialog(
                                                              dateString,
                                                              classId,
                                                              c['name']
                                                                  as String,
                                                              maxParticipants,
                                                            );
                                                          },
                                                    child: Text(
                                                      isAlreadyBooked
                                                          ? 'Afmelden'
                                                          : 'Boeken',
                                                    ),
                                                  )
                                                : null,
                                          ),
                                        );
                                      },
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

  void _showBookingDialog(
    String dateStr,
    String classId,
    String className,
    int maxParticipants,
  ) {
    if (_currentUser == null) {
      ToastService.showError(
        title: 'Log in',
        subtitle: 'Je moet ingelogd zijn om te kunnen boeken.',
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: _firestore.getProfilesStream(_currentUser.uid),
          builder:
              (
                BuildContext context,
                AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
              ) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final List<Map<String, dynamic>> profiles =
                    snapshot.data ?? <Map<String, dynamic>>[];

                // Filter for adult profiles (since this is an 18+ class)
                final List<Map<String, dynamic>> adultProfiles = profiles
                    .where((Map<String, dynamic> p) => p['type'] == 'adult')
                    .toList();

                if (adultProfiles.isEmpty) {
                  return AlertDialog(
                    title: const Text('Geen volwassen profiel'),
                    content: const Text(
                      'Je hebt nog geen volwassen profiel onder dit account. '
                      'Ga naar "Mijn Account" om een profiel aan te maken.',
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                }

                String selectedProfileId = adultProfiles.first['id'] as String;
                String selectedProfileName =
                    adultProfiles.first['name'] as String;

                return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setModalState) {
                    return AlertDialog(
                      title: const Text('Les Boeken'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text('Je wilt boeken voor: $className op $dateStr.'),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: selectedProfileId,
                            decoration: const InputDecoration(
                              labelText: 'Kies deelnemer profiel',
                            ),
                            items: adultProfiles.map((Map<String, dynamic> p) {
                              return DropdownMenuItem<String>(
                                value: p['id'] as String,
                                child: Text(p['name'] as String),
                              );
                            }).toList(),
                            onChanged: (String? val) {
                              if (val != null) {
                                final Map<String, dynamic> selected =
                                    adultProfiles.firstWhere(
                                      (Map<String, dynamic> p) =>
                                          p['id'] == val,
                                    );
                                setModalState(() {
                                  selectedProfileId = val;
                                  selectedProfileName =
                                      selected['name'] as String;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Annuleren'),
                        ),
                        FilledButton(
                          onPressed: () async {
                            final bool success = await _firestore.bookClass(
                              date: dateStr,
                              classId: classId,
                              profileId: selectedProfileId,
                              userId: _currentUser.uid,
                              profileName: selectedProfileName,
                              maxParticipants: maxParticipants,
                            );

                            if (success) {
                              ToastService.showSuccess(
                                title: 'Succesvol geboekt!',
                                subtitle: 'Geboekt voor: $selectedProfileName',
                              );
                            } else {
                              ToastService.showError(
                                title: 'Boekingsfout',
                                subtitle:
                                    'Helaas, de les is al volgeboekt '
                                    '(max. $maxParticipants).',
                              );
                            }
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Boeking Bevestigen'),
                        ),
                      ],
                    );
                  },
                );
              },
        );
      },
    );
  }

  void _cancelBookingDialog(
    String dateStr,
    String classId,
    List<Map<String, dynamic>> bookings,
  ) {
    // Find current user's booking profile
    final List<Map<String, dynamic>> myBookings = bookings
        .where((Map<String, dynamic> b) => b['userId'] == _currentUser?.uid)
        .toList();

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Afmelden voor les'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Kies de boeking die je wilt annuleren:'),
              const SizedBox(height: 16),
              ...myBookings.map((Map<String, dynamic> b) {
                return ListTile(
                  title: Text(b['profileName'] as String? ?? ''),
                  trailing: const PhosphorIcon(
                    PhosphorIconsRegular.x,
                    color: Colors.redAccent,
                  ),
                  onTap: () async {
                    await _firestore.cancelBooking(
                      date: dateStr,
                      classId: classId,
                      profileId: b['profileId'] as String,
                    );
                    ToastService.showSuccess(
                      title: 'Afgemeld',
                      subtitle:
                          'De boeking voor ${b['profileName']} '
                          'is geannuleerd.',
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                );
              }),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Sluiten'),
            ),
          ],
        );
      },
    );
  }
}
