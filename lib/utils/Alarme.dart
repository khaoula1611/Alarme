import 'package:flutter/material.dart';

class Alarm {
  final String? id;
  final TimeOfDay time;
  final String action;

  Alarm({this.id, required this.time, required this.action});

  Map<String, dynamic> toMap() {
    return {
      'time': '${time.hour}:${time.minute}',
      'action': action,
    };
  }

  Alarm copyWith({String? id, TimeOfDay? time, String? action}) {
    return Alarm(
      id: id ?? this.id,
      time: time ?? this.time,
      action: action ?? this.action,
    );
  }
}