import 'package:intl/intl.dart';

class Prayer {
  final String id;
  final String name;
  final String arabicName;
  final DateTime time;
  final bool completed;

  Prayer({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.time,
    this.completed = false,
  });

  factory Prayer.fromJson(Map<String, dynamic> json) {
    return Prayer(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      arabicName: json['arabicName'] ?? '',
      time:
          json['time'] != null ? DateTime.parse(json['time']) : DateTime.now(),
      completed: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'arabicName': arabicName,
      'time': time.toIso8601String(),
      'completed': completed,
    };
  }

  Prayer copyWith({
    String? id,
    String? name,
    String? arabicName,
    DateTime? time,
    bool? completed,
  }) {
    return Prayer(
      id: id ?? this.id,
      name: name ?? this.name,
      arabicName: arabicName ?? this.arabicName,
      time: time ?? this.time,
      completed: completed ?? this.completed,
    );
  }
}

class DailyPrayers {
  final String id;
  final DateTime date;
  final List<Prayer> prayers;
  final int completedCount;

  DailyPrayers({
    required this.id,
    required this.date,
    required this.prayers,
    this.completedCount = 0,
  });

  factory DailyPrayers.fromJson(Map<String, dynamic> json) {
    List<Prayer> prayersList = [];
    if (json['prayers'] != null) {
      prayersList =
          (json['prayers'] as List)
              .map((prayer) => Prayer.fromJson(prayer))
              .toList();
    }

    return DailyPrayers(
      id: json['id'] ?? '',
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      prayers: prayersList,
      completedCount: json['completedCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'prayers': prayers.map((prayer) => prayer.toJson()).toList(),
      'completedCount': completedCount,
    };
  }

  DailyPrayers copyWith({
    String? id,
    DateTime? date,
    List<Prayer>? prayers,
    int? completedCount,
  }) {
    return DailyPrayers(
      id: id ?? this.id,
      date: date ?? this.date,
      prayers: prayers ?? this.prayers,
      completedCount: completedCount ?? this.completedCount,
    );
  }
}
