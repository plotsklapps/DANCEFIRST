import 'package:dancefirst/screens/admin/admin_dashboard.dart';
import 'package:dancefirst/screens/registration/registration_screen.dart';
import 'package:dancefirst/screens/rooster_screen.dart';
import 'package:dancefirst/screens/tarieven_screen.dart';
import 'package:dancefirst/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signals/signals_flutter.dart';

class HomeScreen extends SignalStatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestore = FirestoreService();
  final PageController _pageController = PageController();

  final Signal<int> _currentIndex = signal<int>(
    0,
    options: const SignalOptions<int>(
      name: '_currentIndex',
    ),
  );

  final List<String> _appbarTitles = const <String>[
    'DanceFirst',
    'Rooster',
    'Tarieven',
    'Nieuws',
    'Contact',
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return FutureBuilder<String>(
      future: _firestore.getUserRole(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/dfLogoBlack.png', width: 200),
                  const SizedBox(height: 32),
                  const SizedBox(width: 200, child: LinearProgressIndicator()),
                ],
              ),
            ),
          );
        }
        final String role = snapshot.data ?? 'client';
        final User? user = FirebaseAuth.instance.currentUser;

        return Scaffold(
          appBar: AppBar(
            title: Text(_appbarTitles[_currentIndex.value]),
            centerTitle: true,
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      const Icon(Icons.person, size: 48, color: Colors.white),
                      Text(
                        user?.email ?? 'Gebruiker',
                        style: GoogleFonts.questrial(color: Colors.white),
                      ),
                      Text(
                        role == 'admin' ? 'Beheerder' : 'Geverifieerd',
                        style: GoogleFonts.questrial(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                if (role == 'admin')
                  ListTile(
                    leading: const Icon(Icons.shield),
                    title: const Text('Admin Dashboard'),
                    onTap: () async {
                      Navigator.pop(context);
                      await Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) {
                            return const AdminDashboard();
                          },
                        ),
                      );
                    },
                  ),

                // --- INSCHRIJVEN (Nieuwe Inschrijving) ---
                ListTile(
                  leading: const Icon(Icons.add_reaction_outlined),
                  title: const Text('Nieuwe Inschrijving'),
                  onTap: () async {
                    Navigator.pop(context);
                    await Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) {
                          return const RegistrationScreen();
                        },
                      ),
                    );
                  },
                ),

                // --- PROFIELEN STREAM ---
                if (user != null)
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _firestore.getProfilesStream(user.uid),
                    builder:
                        (
                          BuildContext context,
                          AsyncSnapshot<List<Map<String, dynamic>>>
                          profilesSnapshot,
                        ) {
                          if (!profilesSnapshot.hasData ||
                              profilesSnapshot.data!.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          final List<Map<String, dynamic>> profiles =
                              profilesSnapshot.data!;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: List<Widget>.generate(profiles.length, (
                              int index,
                            ) {
                              final Map<String, dynamic> p = profiles[index];
                              final String firstName =
                                  p['firstName'] as String? ?? 'Profiel';
                              final String dob = p['dob'] as String? ?? '';
                              final String type =
                                  p['type'] as String? ?? 'DanceKids';
                              final bool isKids = type == 'DanceKids';

                              return ListTile(
                                leading: Icon(
                                  isKids
                                      ? Icons.child_care
                                      : Icons.sports_gymnastics_outlined,
                                  color: theme.colorScheme.primary,
                                ),
                                title: Text(
                                  'Profiel ${index + 1} ($firstName)',
                                ),
                                subtitle: dob.isNotEmpty
                                    ? Text('Geb: $dob')
                                    : null,
                                trailing: const Icon(
                                  Icons.edit_outlined,
                                  size: 20,
                                ),
                                onTap: () async {
                                  Navigator.pop(context);
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (_) {
                                        return RegistrationScreen(
                                          profileData: p,
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            }),
                          );
                        },
                  ),

                ListTile(
                  leading: Icon(Icons.logout, color: theme.colorScheme.error),
                  title: const Text('Uitloggen'),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                ),
              ],
            ),
          ),
          body: PageView(
            controller: _pageController,
            onPageChanged: (int i) {
              _currentIndex.value = i;
            },
            children: const <Widget>[
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.star, size: 80),
                    SizedBox(height: 16),
                    Text(
                      'Welkom bij DanceFirst!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              RoosterScreen(),
              TarievenScreen(),
              Center(child: Text('Nieuws Content')),
              Center(child: Text('Contact Content')),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex.value,
            onTap: (int i) async {
              await _pageController.animateToPage(
                i,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month),
                label: 'Rooster',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.monetization_on),
                label: 'Tarieven',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Nieuws'),
              BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Contact'),
            ],
          ),
        );
      },
    );
  }
}
