import 'package:flutter/material.dart';

class TaskModel {
  final String id;
  final String title;
  final String category;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int urgency;
  final int importance;
  final double estimatedEffortHours;
  final String energyLevel;

  TaskModel({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.urgency,
    required this.importance,
    required this.estimatedEffortHours,
    required this.energyLevel,
  });

  Map<String, dynamic> toJson() {
    final startH = startTime.hour.toString().padLeft(2, '0');
    final startM = startTime.minute.toString().padLeft(2, '0');
    final endH = endTime.hour.toString().padLeft(2, '0');
    final endM = endTime.minute.toString().padLeft(2, '0');

    return {
      'id': id,
      'title': title,
      'category': category,
      'date': date.toIso8601String().split('T').first,
      'startTime': '$startH:$startM',
      'endTime': '$endH:$endM',
      'urgency': urgency,
      'importance': importance,
      'estimatedEffortHours': estimatedEffortHours,
      'energyLevel': energyLevel,
    };
  }
}
