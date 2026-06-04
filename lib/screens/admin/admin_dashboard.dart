import 'package:dancefirst/screens/admin/tabs/abonnementen_tab.dart';
import 'package:dancefirst/screens/admin/tabs/boekingen_tab.dart';
import 'package:dancefirst/screens/admin/tabs/huidig_rooster_tab.dart';
import 'package:dancefirst/screens/admin/tabs/vast_rooster_tab.dart';
import 'package:dancefirst/services/firestore_service.dart';
import 'package:dancefirst/services/schedule_sync_service.dart';
import 'package:dancefirst/services/toast_service.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
    );
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
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                try {
                  // Synchroniseer het rooster.
                  await ScheduleSyncService().syncSchedule();

                  // Vul initiële abonnementen in Firestore als de tabel leeg is.
                  final FirestoreService firestore = FirestoreService();
                  await firestore.populateInitialSubscriptions();

                  ToastService.showSuccess(
                    title: 'Database gesynchroniseerd',
                    subtitle: 'Rooster en Tarieven zijn bijgewerkt.',
                  );
                } on Exception catch (e) {
                  ToastService.showError(
                    title: 'Synchronisatie mislukt',
                    subtitle: e.toString(),
                  );
                }
              },
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              icon: Icon(Icons.calendar_month_outlined),
              text: 'Vast Rooster',
            ),
            Tab(
              icon: Icon(Icons.edit_calendar_outlined),
              text: 'Huidig Rooster',
            ),
            Tab(icon: Icon(Icons.euro_outlined), text: 'Abonnementen'),
            Tab(icon: Icon(Icons.person_outlined), text: 'Klanten'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const <Widget>[
          VastRoosterTab(),
          HuidigRoosterTab(),
          AbonnementenTab(),
          KlantenTab(),
        ],
      ),
    );
  }
}
