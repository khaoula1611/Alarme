import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sleeptracker/screens/AlarmPage.dart';
import 'package:sleeptracker/screens/CountryTimePage.dart';
// import 'country_time_page.dart'; // Importez votre page ici.

class IndexPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<IndexPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    AlarmePage(),
    CountryTimePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Affiche la page sélectionnée.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: "Alarm",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.language),
            label: "Country Time",
          ),
        ],
      ),
    );
  }
}
