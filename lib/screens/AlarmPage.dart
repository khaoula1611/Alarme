import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sleeptracker/utils/Alarme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:sleeptracker/services/notification_service.dart';

class AlarmePage extends StatefulWidget {
  @override
  _AlarmePageState createState() => _AlarmePageState();
}

class _AlarmePageState extends State<AlarmePage> {
  List<Alarm> alarms = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  String? get email => _auth.currentUser?.email;
  String? get userId => _auth.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadAlarmsFromFirestore();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      _showActionDialog(selectedTime);
    }
  }

  void _showActionDialog(TimeOfDay time) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Center(
          child: Text(
            "Set Alarm Action",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                final newAlarm = Alarm(time: time, action: "sleep");
                _saveAlarmToFirestore(newAlarm);
              },
              icon: Icon(Icons.nightlight_round, color: Colors.white),
              label: Text("Sleep", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                final newAlarm = Alarm(time: time, action: "wake");
                _saveAlarmToFirestore(newAlarm);
              },
              icon: Icon(Icons.wb_sunny, color: Colors.white),
              label: Text("Wake Up", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAlarmToFirestore(Alarm alarm) async {
    if (userId == null) return;

    try {
      String alarmId = FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .collection('alarms')
          .doc()
          .id;

      final newAlarm = Alarm(
        time: alarm.time,
        action: alarm.action,
        id: alarmId,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .collection('alarms')
          .doc(alarmId)
          .set(newAlarm.toMap());

      setState(() {
        alarms.add(newAlarm);
      });
      Navigator.pop(context);

      // Planification de la notification
      await scheduleNotification(newAlarm);
    } catch (e) {
      print('Failed to save alarm: $e');
    }
  }


  // Modify the scheduleNotification method to handle the alarm scheduling properly
  Future<void> scheduleNotification(Alarm alarm) async {
    final int hour = alarm.time.hour;
    final int minute = alarm.time.minute;
    print("hour : $hour et minute est : $minute");
    // Récupérer l'heure actuelle
    final DateTime now = DateTime.now();
    print("now : $now");
    // Calculer l'heure de la notification
    DateTime scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    print("sheduledtime : $scheduledTime");
    // Si l'heure de l'alarme est passée pour aujourd'hui, planifiez-la pour demain
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    // Planifiez la notification à l'heure calculée
    await _notificationService.scheduleNotification(
      id: alarm.id.hashCode, // Utilisation d'un ID unique pour chaque alarme
      title: 'Alarm',
      body: 'Action: ${alarm.action} '
          ' Date: ${alarm.time.hour}:${alarm.time.minute}',
      scheduledNotificationDateTime: scheduledTime,
    );

  }

  Future<void> _deleteAlarmFromFirestore(Alarm alarm) async {
    if (userId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .collection('alarms')
          .doc(alarm.id)
          .delete();
      setState(() {
        alarms.remove(alarm);
      });
    } catch (e) {
      print('Failed to delete alarm: $e');
    }
  }

  Future<void> _loadAlarmsFromFirestore() async {
    if (userId == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .collection('alarms')
          .get();

      final loadedAlarms = snapshot.docs.map((doc) {
        final data = doc.data();
        final timeParts = (data['time'] as String).split(':');
        return Alarm(
          time: TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          ),
          action: data['action'],
          id: doc.id,
        );
      }).toList();

      setState(() {
        alarms = loadedAlarms;
      });
      for(Alarm alarm in alarms)
        await scheduleNotification(alarm);
    } catch (e) {
      print('Failed to load alarms: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Alarms'),
        backgroundColor: Color(0xFF674AEF),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Header container
          Container(
            padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 15),
            decoration: BoxDecoration(
              color: Color(0xFF674AEF),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Hi, $email",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 25,
                        letterSpacing: 1,
                        wordSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // List of alarms
          Expanded(
            child: ListView.builder(
              itemCount: alarms.length,
              itemBuilder: (context, index) {
                final alarm = alarms[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  child: ListTile(
                    leading: Icon(
                      alarm.action == "wake" ? Icons.wb_sunny : Icons.nights_stay,
                      color: alarm.action == "wake" ? Colors.orange : Colors.blue,
                    ),
                    title: Text(
                      "${alarm.time.format(context)} - ${alarm.action}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteAlarmFromFirestore(alarm),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _selectTime(context),
        backgroundColor: Color(0xFF674AEF),
        child: Icon(Icons.alarm),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
