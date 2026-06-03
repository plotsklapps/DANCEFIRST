import 'package:dancefirst/constants/icon_library.dart';
import 'package:dancefirst/screens/admin/admin_dashboard.dart';
import 'package:dancefirst/screens/registration_screen.dart';
import 'package:dancefirst/screens/rooster_screen.dart';
import 'package:dancefirst/screens/tarieven_screen.dart';
import 'package:dancefirst/services/firestore_service.dart';
import 'package:dancefirst/services/toast_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  final FirestoreService _firestore = FirestoreService();
  String _userRole = 'client';

  final List<String> _titles = const <String>[
    'DanceFirst',
    'Rooster',
    'Tarieven',
    'Nieuws',
    'Contact',
  ];

  final List<Widget> _pages = <Widget>[
    const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          PhosphorIcon(PhosphorIconsRegular.star, size: 80, color: Colors.teal),
          SizedBox(height: 16),
          Text(
            'Welkom bij DanceFirst!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Ontdek onze streetdance, musical, zumba en pilates lessen. Plan je rooster en boek eenvoudig je plek.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    ),
    const RoosterScreen(),
    const TarievenScreen(),
    const Center(child: Text('Nieuws Content')),
    const Center(child: Text('Contact Content')),
  ];

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String role = await _firestore.getUserRole(user.uid);
      if (mounted) {
        setState(() {
          _userRole = role;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showProfileManager(BuildContext context, User user) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Profielen Beheren',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const PhosphorIcon(PhosphorIconsRegular.x),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const Divider(),
                      Text(
                        'Account: ${user.email}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: StreamBuilder<List<Map<String, dynamic>>>(
                          stream: _firestore.getProfilesStream(user.uid),
                          builder:
                              (
                                BuildContext context,
                                AsyncSnapshot<List<Map<String, dynamic>>>
                                snapshot,
                              ) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                final List<Map<String, dynamic>> profiles =
                                    snapshot.data ?? <Map<String, dynamic>>[];

                                if (profiles.isEmpty) {
                                  return const Center(
                                    child: Text(
                                      'Nog geen profielen. Voeg een profiel toe om lessen te boeken!',
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  controller: scrollController,
                                  itemCount: profiles.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final Map<String, dynamic> p =
                                        profiles[index];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.teal.shade50,
                                          child: PhosphorIcon(
                                            p['type'] == 'child'
                                                ? IconLibrary.child
                                                : IconLibrary.person,
                                            color: Colors.teal,
                                          ),
                                        ),
                                        title: Text(p['name'] as String? ?? ''),
                                        subtitle: Text(
                                          '${p['type'] == 'child' ? 'Kind' : 'Volwassene'} | Geboren: ${p['dob']}',
                                        ),
                                        trailing: IconButton(
                                          icon: const PhosphorIcon(
                                            IconLibrary.delete,
                                            color: Colors.redAccent,
                                          ),
                                          onPressed: () async {
                                            await _firestore.deleteProfile(
                                              user.uid,
                                              p['id'] as String,
                                            );
                                            ToastService.showSuccess(
                                              title: 'Profiel verwijderd',
                                              subtitle:
                                                  'Profiel is succesvol verwijderd.',
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
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () =>
                            _showAddProfileDialog(context, user.uid),
                        icon: const PhosphorIcon(IconLibrary.add),
                        label: const Text('Nieuw Profiel Toevoegen'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showAddProfileDialog(BuildContext context, String uid) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController nameC = TextEditingController();
    final TextEditingController dobC = TextEditingController();
    String selectedType = 'adult';
    const String selectedTariff = '1x per week, maandelijks opzegbaar';

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return AlertDialog(
              title: const Text('Nieuw Profiel'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: nameC,
                        decoration: const InputDecoration(labelText: 'Naam'),
                        validator: (String? v) =>
                            (v == null || v.isEmpty) ? 'Verplicht' : null,
                      ),
                      TextFormField(
                        controller: dobC,
                        decoration: const InputDecoration(
                          labelText: 'Geboortedatum (DD-MM-YYYY)',
                        ),
                        validator: (String? v) =>
                            (v == null || v.isEmpty) ? 'Verplicht' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: const <DropdownMenuItem<String>>[
                          DropdownMenuItem<String>(
                            value: 'adult',
                            child: Text('Volwassene (18+)'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'child',
                            child: Text('Kind (onder 18)'),
                          ),
                        ],
                        onChanged: (String? val) {
                          if (val != null) {
                            setModalState(() {
                              selectedType = val;
                            });
                          }
                        },
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
                      await _firestore.addProfile(
                        uid,
                        name: nameC.text.trim(),
                        type: selectedType,
                        dob: dobC.text.trim(),
                        tariff: selectedTariff,
                      );
                      ToastService.showSuccess(
                        title: 'Profiel toegevoegd',
                        subtitle: 'Nieuw profiel succesvol aangemaakt.',
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: const Text('Toevoegen'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[Colors.teal, Colors.tealAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  const PhosphorIcon(
                    IconLibrary.person,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.email ?? user?.phoneNumber ?? 'Gebruiker',
                    style: GoogleFonts.questrial(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _userRole == 'admin'
                        ? 'Beheerder'
                        : 'Ingelogd en geverifieerd',
                    style: GoogleFonts.questrial(
                      color: const Color(0xCCFFFFFF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (_userRole == 'admin')
              ListTile(
                leading: const PhosphorIcon(
                  PhosphorIconsRegular.shieldCheck,
                  color: Colors.amber,
                ),
                title: const Text('Admin Dashboard'),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const AdminDashboard(),
                    ),
                  );
                },
              ),
            ListTile(
              leading: const PhosphorIcon(
                IconLibrary.person,
                color: Colors.teal,
              ),
              title: const Text('Mijn Account & Profielen'),
              onTap: () async {
                Navigator.pop(context); // Close drawer
                if (user != null) {
                  _showProfileManager(context, user);
                }
              },
            ),
            ListTile(
              leading: PhosphorIcon(
                IconLibrary.logout,
                color: Colors.redAccent,
              ),
              title: const Text('Uitloggen'),
              onTap: () async {
                Navigator.pop(context); // Close drawer
                await FirebaseAuth.instance.signOut();
              },
            ),
            ListTile(
              leading: const PhosphorIcon(IconLibrary.contracts),
              title: const Text('Inschrijven'),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return const RegistrationScreen();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (int index) {
          setState(() => _currentIndex = index);
        },
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (int index) async {
          await _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: PhosphorIcon(IconLibrary.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: PhosphorIcon(IconLibrary.calendar),
            label: 'Rooster',
          ),
          BottomNavigationBarItem(
            icon: PhosphorIcon(IconLibrary.money),
            label: 'Tarieven',
          ),
          BottomNavigationBarItem(
            icon: PhosphorIcon(IconLibrary.info),
            label: 'Nieuws',
          ),
          BottomNavigationBarItem(
            icon: PhosphorIcon(IconLibrary.question),
            label: 'Contact',
          ),
        ],
      ),
    );
  }
}
