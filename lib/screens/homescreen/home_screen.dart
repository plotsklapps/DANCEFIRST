import 'package:dancefirst/screens/homescreen/drawer_widget.dart';
import 'package:dancefirst/screens/rooster_screen.dart';
import 'package:dancefirst/screens/tarieven_screen.dart';
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
        currentIndex: _currentIndex,
        onTap: (int i) {
          setState(() {
            _currentIndex = i;
          });
          _pageController.jumpToPage(i);
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
