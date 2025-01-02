import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For time formatting
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class CountryTimePage extends StatefulWidget {
  @override
  _CountryTimePageState createState() => _CountryTimePageState();
}

class _CountryTimePageState extends State<CountryTimePage> {
  // List of countries and their respective time zones
  final List<Map<String, String>> countries = [
    {'country': 'USA', 'timezone': 'America/New_York'},
    {'country': 'India', 'timezone': 'Asia/Kolkata'},
    {'country': 'Japan', 'timezone': 'Asia/Tokyo'},
    {'country': 'Germany', 'timezone': 'Europe/Berlin'},
    {'country': 'Australia', 'timezone': 'Australia/Sydney'},
  ];

  // Function to get the current time for each country based on its timezone
  String getTimeForCountry(String timezone) {
    final location = tz.getLocation(timezone);
    final currentTime = tz.TZDateTime.now(location);
    final timeFormat = DateFormat('hh:mm a');
    return timeFormat.format(currentTime);
  }

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones(); // Initialize timezones
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Country Time'),
        backgroundColor: Color(0xFF674AEF),
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        itemCount: countries.length,
        itemBuilder: (context, index) {
          final country = countries[index];
          final countryName = country['country']!;
          final timezone = country['timezone']!;
          final currentTime = getTimeForCountry(timezone);

          return Card(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            elevation: 5,
            child: ListTile(
              title: Text(
                countryName,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text(
                'Current Time: $currentTime',
                style: TextStyle(fontSize: 16),
              ),
              trailing: Icon(Icons.access_time),
            ),
          );
        },
      ),
    );
  }
}
