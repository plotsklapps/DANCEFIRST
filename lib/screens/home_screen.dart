import 'package:dancefirst/screens/rooster_screen.dart';
import 'package:dancefirst/screens/tarieven_screen.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<String> _titles = const <String>[
    'DanceFirst',
    'Rooster',
    'Tarieven',
    'Nieuws',
    'Contact',
  ];

  final List<Widget> _pages = <Widget>[
    const Center(child: Text('Home Content')),
    const RoosterScreen(),
    const TarievenScreen(),
    const Center(child: Text('Nieuws Content')),
    const Center(child: Text('Contact Content')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
      ),
      drawer: const Drawer(),
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedHome01),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedCalendar03),
            label: 'Rooster',
          ),
          BottomNavigationBarItem(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedSaveMoneyEuro),
            label: 'Tarieven',
          ),
          BottomNavigationBarItem(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedInformationCircle),
            label: 'Nieuws',
          ),
          BottomNavigationBarItem(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedBubbleChatQuestion),
            label: 'Contact',
          ),
        ],
      ),
    );
  }
}
