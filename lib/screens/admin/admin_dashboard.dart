import 'package:dancefirst/screens/admin/abonnementen_tab.dart';
import 'package:dancefirst/screens/admin/klanten_tab.dart';
import 'package:dancefirst/screens/admin/vast_rooster_tab.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(icon: Icon(Icons.calendar_month_outlined), text: 'Rooster'),
            Tab(icon: Icon(Icons.euro_outlined), text: 'Abonnementen'),
            Tab(icon: Icon(Icons.person_outlined), text: 'Klanten'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const <Widget>[
          VastRoosterTab(),
          AbonnementenTab(),
          KlantenTab(),
        ],
      ),
    );
  }
}
