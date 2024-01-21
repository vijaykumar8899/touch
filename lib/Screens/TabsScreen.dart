//BottomNavi

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:touch/Screens/RecordsScreen.dart';
import 'package:touch/Screens/CalculateScreen.dart';
 
class TabsScreen extends StatefulWidget {
  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabsScreen> {
  int _currentIndex = 0;
  final List _pages = [
    calculateScreen(),
    RecordsScreen(),
    // DisplayDataFromFirebase(),
  ];

  changeIndex(selectedIndex) {
    setState(() {
      _currentIndex = selectedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: changeIndex,
          selectedItemColor: const Color.fromARGB(255, 2, 69, 124),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.calculator), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.database), label: "Data"),
          ]),
    );
  }
}
