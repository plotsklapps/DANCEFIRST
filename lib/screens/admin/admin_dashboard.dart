import 'package:dancefirst/services/firestore_service.dart';
import 'package:dancefirst/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() {
    return _AdminDashboardState();
  }
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestore = FirestoreService();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard (Laila)'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const <Widget>[
            Tab(icon: Icon(Icons.assignment), text: 'Inschrijvingen'),
            Tab(icon: Icon(Icons.calendar_month), text: 'Vast Rooster'),
            Tab(icon: Icon(Icons.edit_calendar), text: 'Ad-hoc Rooster'),
            Tab(icon: Icon(Icons.people), text: 'Boekingen'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          _buildRegistrationsTab(),
          _buildBaseScheduleTab(),
          _buildAdHocTab(),
          _buildBookingsTab(),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // TAB 1: REGISTRATIONS
  // ----------------------------------------------------
  Widget _buildRegistrationsTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestore.getPendingRegistrationsStream(),
      builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Geen openstaande inschrijvingen.'));
        }

        final List<Map<String, dynamic>> items = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            final Map<String, dynamic> reg = items[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal.shade100,
                  child: Icon(
                    reg['enrollmentType'] == 'child'
                        ? Icons.child_care
                        : Icons.person,
                    color: Colors.teal.shade900,
                  ),
                ),
                title: Text('${reg['firstName']} ${reg['lastName']}'),
                subtitle: Text(
                  'Tarief: ${reg['selectedTariff'] ?? "Niet gekozen"}',
                ),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('E-mail: ${reg['email']}'),
                        Text('Telefoon: ${reg['phone']}'),
                        Text(
                          'Adres: ${reg['address']}, ${reg['zip']} ${reg['city']}',
                        ),
                        Text('Geboortedatum: ${reg['dob']}'),
                        Text(
                          'IBAN: ${reg['iban']} (Houder: ${reg['accountHolder']})',
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            OutlinedButton.icon(
                              onPressed: () async {
                                await _firestore.updateRegistrationStatus(
                                  reg['id'] as String,
                                  'declined',
                                );
                                ToastService.showWarning(
                                  title: 'Inschrijving afgewezen',
                                  subtitle:
                                      'De inschrijving is gemarkeerd als afgewezen.',
                                );
                              },
                              icon: const Icon(Icons.close, color: Colors.red),
                              label: const Text(
                                'Afwijzen',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.icon(
                              onPressed: () async {
                                await _firestore.updateRegistrationStatus(
                                  reg['id'] as String,
                                  'approved',
                                );
                                ToastService.showSuccess(
                                  title: 'Inschrijving goedgekeurd',
                                  subtitle:
                                      'De inschrijving is succesvol goedgekeurd!',
                                );
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('Goedkeuren'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ----------------------------------------------------
  // TAB 2: BASE SCHEDULE
  // ----------------------------------------------------
  Widget _buildBaseScheduleTab() {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showClassDialog(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestore.getBaseScheduleStream(),
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
                  child: Text('Geen klassen in het rooster.'),
                );
              }

              final List<Map<String, dynamic>> classes = snapshot.data!;
              final List<String> days = <String>[
                'Maandag',
                'Dinsdag',
                'Woensdag',
                'Donderdag',
                'Vrijdag',
                'Zaterdag',
                'Zondag',
              ];

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: days.length,
                itemBuilder: (BuildContext context, int dIdx) {
                  final String day = days[dIdx];
                  final List<Map<String, dynamic>> dayClasses = classes
                      .where((Map<String, dynamic> c) => c['day'] == day)
                      .toList();

                  if (dayClasses.isEmpty) return const SizedBox.shrink();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              day,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const Divider(),
                          ...dayClasses.map((Map<String, dynamic> c) {
                            return ListTile(
                              leading: Text(c['time'] as String? ?? ''),
                              title: Text(c['name'] as String? ?? ''),
                              subtitle: Text(
                                'Docent: ${c['teacher']} (${c['type'] == 'adults' ? '18+' : 'Kids'}, Max: ${c['maxParticipants']})',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () => _showClassDialog(c: c),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      await _firestore.deleteBaseScheduleClass(
                                        c['id'] as String,
                                      );
                                      ToastService.showSuccess(
                                        title: 'Les verwijderd',
                                        subtitle:
                                            'Les is succesvol verwijderd uit het rooster.',
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
      ),
    );
  }

  void _showClassDialog({Map<String, dynamic>? c}) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController nameC = TextEditingController(
      text: c?['name'] as String? ?? '',
    );
    final TextEditingController teacherC = TextEditingController(
      text: c?['teacher'] as String? ?? '',
    );
    final TextEditingController timeC = TextEditingController(
      text: c?['time'] as String? ?? '',
    );
    final TextEditingController maxC = TextEditingController(
      text: (c?['maxParticipants'] ?? 20).toString(),
    );
    String selectedDay = c?['day'] as String? ?? 'Maandag';
    String selectedType = c?['type'] as String? ?? 'kids';

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(c == null ? 'Nieuwe Les Toevoegen' : 'Les Bewerken'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: nameC,
                    decoration: const InputDecoration(labelText: 'Lesnaam'),
                    validator: (String? v) =>
                        (v == null || v.isEmpty) ? 'Verplicht' : null,
                  ),
                  TextFormField(
                    controller: teacherC,
                    decoration: const InputDecoration(labelText: 'Docent'),
                    validator: (String? v) =>
                        (v == null || v.isEmpty) ? 'Verplicht' : null,
                  ),
                  TextFormField(
                    controller: timeC,
                    decoration: const InputDecoration(
                      labelText: 'Tijd (bijv. 19:30)',
                    ),
                    validator: (String? v) =>
                        (v == null || v.isEmpty) ? 'Verplicht' : null,
                  ),
                  TextFormField(
                    controller: maxC,
                    decoration: const InputDecoration(
                      labelText: 'Max Deelnemers',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (String? v) =>
                        (v == null || v.isEmpty) ? 'Verplicht' : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedDay,
                    items:
                        <String>[
                              'Maandag',
                              'Dinsdag',
                              'Woensdag',
                              'Donderdag',
                              'Vrijdag',
                              'Zaterdag',
                              'Zondag',
                            ]
                            .map(
                              (String d) => DropdownMenuItem<String>(
                                value: d,
                                child: Text(d),
                              ),
                            )
                            .toList(),
                    onChanged: (String? val) {
                      if (val != null) selectedDay = val;
                    },
                    decoration: const InputDecoration(labelText: 'Dag'),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    items: <DropdownMenuItem<String>>[
                      const DropdownMenuItem<String>(
                        value: 'kids',
                        child: Text('Kids (4-18)'),
                      ),
                      const DropdownMenuItem<String>(
                        value: 'adults',
                        child: Text('Volwassenen (18+)'),
                      ),
                    ],
                    onChanged: (String? val) {
                      if (val != null) selectedType = val;
                    },
                    decoration: const InputDecoration(labelText: 'Type'),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuleren'),
            ),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await _firestore.saveBaseScheduleClass(
                    id: c?['id'] as String?,
                    day: selectedDay,
                    time: timeC.text.trim(),
                    name: nameC.text.trim(),
                    teacher: teacherC.text.trim(),
                    type: selectedType,
                    maxParticipants: int.tryParse(maxC.text) ?? 20,
                  );
                  ToastService.showSuccess(
                    title: 'Les opgeslagen',
                    subtitle: 'Les succesvol opgeslagen in rooster.',
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Opslaan'),
            ),
          ],
        );
      },
    );
  }

  // ----------------------------------------------------
  // TAB 3: AD-HOC ROOSTER
  // ----------------------------------------------------
  Widget _buildAdHocTab() {
    final String dateString =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
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

    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                      initialDate: _selectedDate,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 30),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
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
                      return const Center(
                        child: Text('Geen basisrooster om te wijzigen.'),
                      );
                    }

                    // Filter base schedule classes to active day name
                    final List<Map<String, dynamic>> dayClasses = baseSnapshot
                        .data!
                        .where(
                          (Map<String, dynamic> c) =>
                              c['day'] == currentDayName,
                        )
                        .toList();

                    if (dayClasses.isEmpty) {
                      return Center(
                        child: Text(
                          'Geen lessen geprogrammeerd voor $currentDayName.',
                        ),
                      );
                    }

                    return StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _firestore.getScheduleOverridesStream(dateString),
                      builder:
                          (
                            BuildContext context,
                            AsyncSnapshot<List<Map<String, dynamic>>>
                            overrideSnapshot,
                          ) {
                            final List<Map<String, dynamic>> overrides =
                                overrideSnapshot.data ??
                                <Map<String, dynamic>>[];

                            return ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: dayClasses.length,
                              itemBuilder: (BuildContext context, int index) {
                                final Map<String, dynamic> c =
                                    dayClasses[index];
                                final Map<String, dynamic>? overrideDoc =
                                    overrides.firstWhere(
                                      (Map<String, dynamic> o) =>
                                          o['classId'] == c['id'],
                                      orElse: () => <String, dynamic>{},
                                    );

                                final bool isCancelled =
                                    overrideDoc?['isCancelled'] as bool? ??
                                    false;
                                final String teacher =
                                    overrideDoc?['teacherOverride']
                                        as String? ??
                                    c['teacher'] as String;
                                final String time =
                                    overrideDoc?['timeOverride'] as String? ??
                                    c['time'] as String;

                                return Card(
                                  color: isCancelled
                                      ? Colors.red.shade50
                                      : null,
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
                                      icon: const Icon(
                                        Icons.edit_attributes_outlined,
                                        color: Colors.teal,
                                      ),
                                      onPressed: () => _showOverrideDialog(
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

  void _showOverrideDialog(
    String dateStr,
    Map<String, dynamic> c,
    Map<String, dynamic>? currentOverride,
  ) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController teacherOverrideC = TextEditingController(
      text:
          currentOverride?['teacherOverride'] as String? ??
          c['teacher'] as String,
    );
    final TextEditingController timeOverrideC = TextEditingController(
      text: currentOverride?['timeOverride'] as String? ?? c['time'] as String,
    );
    final TextEditingController notesC = TextEditingController(
      text: currentOverride?['notes'] as String? ?? '',
    );
    bool isCancelled = currentOverride?['isCancelled'] as bool? ?? false;

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return AlertDialog(
              title: const Text('Ad-hoc Wijziging'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SwitchListTile(
                      title: const Text('Geannuleerd?'),
                      value: isCancelled,
                      onChanged: (bool val) {
                        setModalState(() {
                          isCancelled = val;
                        });
                      },
                    ),
                    if (!isCancelled) ...<Widget>[
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
                      decoration: const InputDecoration(
                        labelText: 'Opmerkingen (bijv. wegens ziekte)',
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    await _firestore.removeScheduleOverride(
                      dateStr,
                      c['id'] as String,
                    );
                    ToastService.showSuccess(
                      title: 'Wijziging gewist',
                      subtitle: 'Standaard rooster hersteld.',
                    );
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text(
                    'Herstel Standaard',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                FilledButton(
                  onPressed: () async {
                    await _firestore.saveScheduleOverride(
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
                    ToastService.showSuccess(
                      title: 'Wijziging opgeslagen',
                      subtitle: 'Klant-rooster is bijgewerkt.',
                    );
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Opslaan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ----------------------------------------------------
  // TAB 4: BOOKINGS
  // ----------------------------------------------------
  Widget _buildBookingsTab() {
    final String dateString =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
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

    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Boekingen voor: $dateString ($currentDayName)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 30),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
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
                      return const Center(
                        child: Text('Geen rooster gevonden.'),
                      );
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
                      return Center(
                        child: Text(
                          'Geen volwassen lessen op $currentDayName.',
                        ),
                      );
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
                                    children: <Widget>[
                                      if (bookings.isEmpty)
                                        const Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Text('Nog geen boekingen.'),
                                        )
                                      else
                                        ...bookings.map((
                                          Map<String, dynamic> b,
                                        ) {
                                          return ListTile(
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
                                                  title: 'Boeking geannuleerd',
                                                  subtitle:
                                                      'Boeking succesvol verwijderd.',
                                                );
                                              },
                                            ),
                                          );
                                        }),
                                    ],
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
