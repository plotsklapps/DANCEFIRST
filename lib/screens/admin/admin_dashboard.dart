import 'package:dancefirst/constants/icon_library.dart';
import 'package:dancefirst/screens/admin/tabs/boekingen_tab.dart';
import 'package:dancefirst/screens/admin/tabs/huidig_rooster_tab.dart';
import 'package:dancefirst/screens/admin/tabs/vast_rooster_tab.dart';
import 'package:dancefirst/services/firestore_service.dart';
import 'package:dancefirst/services/seed_service.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

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
  final SeedService _seedService = SeedService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text("Laila's Dashboard"),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              color: Colors.teal,
              icon: const PhosphorIcon(IconLibrary.refresh),
              onPressed: () async {
                await _seedService.seedDatabase();
              },
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(icon: PhosphorIcon(IconLibrary.calendar), text: 'Vast Rooster'),
            Tab(icon: PhosphorIcon(IconLibrary.edit), text: 'Huidig Rooster'),
            Tab(icon: PhosphorIcon(IconLibrary.person), text: 'Boekingen'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          VastRoosterTab(
            firestore: _firestore,
            showClassDialog: _showClassSheet,
          ),
          HuidigRoosterTab(
            firestore: _firestore,
            showOverrideDialog: _showOverrideDialog,
          ),
          BoekingenTab(firestore: _firestore),
        ],
      ),
    );
  }

  Future<void> _showClassSheet({Map<String, dynamic>? c}) async {
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
    final String selectedType = c?['type'] as String? ?? 'kids';

    await showModalBottomSheet<void>(
      showDragHandle: true,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  c == null ? 'Nieuwe Les' : 'Les Bewerken',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Divider(),
                TextFormField(
                  controller: nameC,
                  decoration: const InputDecoration(labelText: 'Lesnaam'),
                ),
                TextFormField(
                  controller: teacherC,
                  decoration: const InputDecoration(labelText: 'Docent'),
                ),
                TextFormField(
                  controller: timeC,
                  decoration: const InputDecoration(labelText: 'Tijd'),
                ),
                TextFormField(
                  controller: maxC,
                  decoration: const InputDecoration(
                    labelText: 'Max Deelnemers',
                  ),
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
                            (String d) =>
                                DropdownMenuItem(value: d, child: Text(d)),
                          )
                          .toList(),
                  onChanged: (String? val) => selectedDay = val!,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () async {
                    await _firestore.saveBaseScheduleClass(
                      id: c?['id'] as String?,
                      day: selectedDay,
                      time: timeC.text.trim(),
                      name: nameC.text.trim(),
                      teacher: teacherC.text.trim(),
                      type: selectedType,
                      maxParticipants: int.tryParse(maxC.text) ?? 20,
                    );
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('Opslaan'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOverrideDialog(
    String dateStr,
    Map<String, dynamic> c,
    Map<String, dynamic>? currentOverride,
  ) {
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
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
                        await _firestore.removeScheduleOverride(
                          dateStr,
                          c['id'] as String,
                        );
                        if (mounted) Navigator.pop(context);
                      },
                      child: const Text(
                        'Herstel Standaard',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
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
                        if (mounted) Navigator.pop(context);
                      },
                      child: const Text('Opslaan'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
