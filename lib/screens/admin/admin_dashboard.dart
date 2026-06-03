import 'package:dancefirst/constants/icon_library.dart';
import 'package:dancefirst/screens/admin/tabs/boekingen_tab.dart';
import 'package:dancefirst/screens/admin/tabs/huidig_rooster_tab.dart';
import 'package:dancefirst/screens/admin/tabs/vast_rooster_tab.dart';
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
              icon: const Icon(Icons.refresh, color: Colors.teal),
              onPressed: () async {
                await ScheduleSyncService().syncSchedule();
                ToastService.showSuccess(
                  title: 'Database gesynchroniseerd',
                  subtitle: 'Rooster is bijgewerkt.',
                );
              },
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(icon: Icon(IconLibrary.calendar), text: 'Vast Rooster'),
            Tab(icon: Icon(IconLibrary.edit), text: 'Huidig Rooster'),
            Tab(icon: Icon(IconLibrary.person), text: 'Boekingen'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          VastRoosterTab(),
          HuidigRoosterTab(),
          BoekingenTab(),
        ],
      ),
    );
  }
}
