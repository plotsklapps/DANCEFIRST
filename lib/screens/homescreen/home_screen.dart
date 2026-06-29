import 'package:dancefirst/screens/homescreen/drawer_widget.dart';
import 'package:dancefirst/screens/news_screen.dart';
import 'package:dancefirst/screens/registration/registration_screen.dart';
import 'package:dancefirst/screens/rooster_screen.dart';
import 'package:dancefirst/screens/tarieven_screen.dart';
import 'package:dancefirst/services/client_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

class HomeScreen extends SignalStatefulWidget {
  const HomeScreen({required this.role, super.key});

  final String role;

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();

  int _currentIndex = 0;

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
    final ThemeData theme = Theme.of(context);
    final List<Map<String, dynamic>> profiles =
        ClientState.instance.sProfiles.value;
    final String? activeProfileId = ClientState.instance.sActiveProfileId.value;

    final Map<String, dynamic>? activeProfile = profiles.isEmpty
        ? null
        : profiles.firstWhere(
            (Map<String, dynamic> p) => p['id'] == activeProfileId,
            orElse: () => profiles.first,
          );

    final String greeting = activeProfile != null
        ? 'Hoi, ${activeProfile['firstName']}!'
        : 'Welkom bij DanceFirst!';

    return Scaffold(
      appBar: AppBar(
        title: Text(_appbarTitles[_currentIndex]),
        centerTitle: true,
      ),
      drawer: DrawerWidget(
        user: user,
        role: widget.role,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              theme.colorScheme.primaryContainer.withValues(alpha: 100),
              theme.colorScheme.surface,
              theme.colorScheme.surface,
              theme.colorScheme.primaryContainer.withValues(alpha: 100),
            ],
            stops: const <double>[0, 0.4, 0.8, 1],
          ),
        ),
        child: PageView(
          controller: _pageController,
          onPageChanged: (int i) {
            setState(() {
              _currentIndex = i;
            });
          },
          children: <Widget>[
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.star,
                        size: 80,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        greeting,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      if (profiles.isEmpty) ...<Widget>[
                        const SizedBox(height: 32),
                        const Divider(),
                        const SizedBox(height: 16),
                        const Text(
                          'Nog niet ingeschreven?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
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
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            const RoosterScreen(),
            const TarievenScreen(),
            const NewsScreen(),
            const Center(child: Text('Contact Content')),
          ],
        ),
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
