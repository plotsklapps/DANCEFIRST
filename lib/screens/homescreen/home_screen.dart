import 'package:dancefirst/screens/homescreen/drawer_widget.dart';
import 'package:dancefirst/screens/registration/registration_screen.dart';
import 'package:dancefirst/screens/rooster_screen.dart';
import 'package:dancefirst/screens/tarieven_screen.dart';
import 'package:dancefirst/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.role, super.key});

  final String role;

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  final FirestoreService _firestoreService = FirestoreService();

  int _currentIndex = 0;
  String? _activeProfileId;

  final List<String> _appbarTitles = const <String>[
    'DanceFirst',
    'Rooster',
    'Tarieven',
    'Nieuws',
    'Contact',
  ];

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(_appbarTitles[_currentIndex]),
        centerTitle: true,
      ),
      drawer: DrawerWidget(
        user: user,
        role: widget.role,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (int i) {
          setState(() {
            _currentIndex = i;
          });
        },
        children: <Widget>[
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _firestoreService.getProfilesStream(user?.uid ?? ''),
            builder:
                (
                  BuildContext context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
                ) {
                  final List<Map<String, dynamic>>? profiles = snapshot.data;
                  if (profiles == null || profiles.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Icon(Icons.star, size: 80),
                          const SizedBox(height: 16),
                          const Text(
                            'Welkom bij DanceFirst!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 32),
                          FilledButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => const RegistrationScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_reaction_outlined),
                            label: const Text('Schrijf je hier in'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Set default active profile if null.
                  if (_activeProfileId == null ||
                      !profiles.any(
                        (Map<String, dynamic> p) => p['id'] == _activeProfileId,
                      )) {
                    _activeProfileId = profiles.first['id'] as String;
                  }

                  final Map<String, dynamic> activeProfile = profiles
                      .firstWhere(
                        (Map<String, dynamic> p) => p['id'] == _activeProfileId,
                      );

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.star,
                          size: 80,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Hoi, ${activeProfile['firstName']}!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text('Wissel van profiel:'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: profiles.map((Map<String, dynamic> p) {
                            final bool isSelected = p['id'] == _activeProfileId;
                            return ChoiceChip(
                              label: Text(p['firstName'] as String),
                              selected: isSelected,
                              onSelected: (bool selected) {
                                if (selected) {
                                  setState(() {
                                    _activeProfileId = p['id'] as String?;
                                  });
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                },
          ),
          const RoosterScreen(),
          const TarievenScreen(),
          const Center(child: Text('Nieuws Content')),
          const Center(child: Text('Contact Content')),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (int i) async {
          setState(() {
            _currentIndex = i;
          });
          await _pageController.animateToPage(
            i,
            duration: const Duration(milliseconds: 400),
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
  }
}
