import 'package:dancefirst/screens/admin/admin_dashboard.dart';
import 'package:dancefirst/screens/rooster_screen.dart';
import 'package:dancefirst/screens/tarieven_screen.dart';
import 'package:dancefirst/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestore = FirestoreService();
  final PageController _pageController = PageController();

  int _currentIndex = 0;

  final List<String> _titles = const <String>[
    'DanceFirst',
    'Rooster',
    'Tarieven',
    'Nieuws',
    'Contact',
  ];

  final List<Widget> _pages = const <Widget>[
    Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.star, size: 80),
          SizedBox(height: 16),
          Text(
            'Welkom bij DanceFirst!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
    RoosterScreen(),
    TarievenScreen(),
    Center(child: Text('Nieuws Content')),
    Center(child: Text('Contact Content')),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return FutureBuilder<String>(
      future: _firestore.getUserRole(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        final String role = snapshot.data ?? 'client';
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
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminDashboard(),
                        ),
                      );
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Uitloggen'),
                  onTap: () => FirebaseAuth.instance.signOut(),
                ),
              ],
            ),
          ),
          body: PageView(
            controller: _pageController,
            onPageChanged: (int i) => setState(() => _currentIndex = i),
            children: _pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (int i) => _pageController.animateToPage(
              i,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
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
