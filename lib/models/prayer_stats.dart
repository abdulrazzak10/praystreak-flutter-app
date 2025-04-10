import 'package:intl/intl.dart';

class PrayerStats {
  final int currentStreak;
  final int highestStreak;
  final int missedPrayers;
  final Map<String, double> completionPercentages;
  final List<DailyPrayer> prayerHistory;

  PrayerStats({
    required this.currentStreak,
    required this.highestStreak,
    required this.missedPrayers,
    required this.completionPercentages,
    required this.prayerHistory,
  });

  // Create mock data for testing
  factory PrayerStats.mockData() {
    final today = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');

    // Create mock history for the last 7 days
    List<DailyPrayer> history = [];
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dateStr = formatter.format(date);

      // Generate example completion data
      final prayers = {
        'Fajr': i != 2, // All completed except day 3
        'Dhuhr': i % 2 == 0, // Alternating
        'Asr': i != 1, // All completed except day 2
        'Maghrib': true, // All completed
        'Isha': i != 4, // All completed except day 5
      };

      history.add(DailyPrayer(date: dateStr, prayers: prayers));
    }

    return PrayerStats(
      currentStreak: 3,
      highestStreak: 5,
      missedPrayers: 4,
      completionPercentages: {
        'Fajr': 85.7,
        'Dhuhr': 57.1,
        'Asr': 85.7,
        'Maghrib': 100.0,
        'Isha': 85.7,
      },
      prayerHistory: history,
    );
  }

  // Get the overall prayer completion percentage
  double get overallPercentage {
    if (completionPercentages.isEmpty) return 0.0;

    final total = completionPercentages.values.reduce((a, b) => a + b);
    return total / completionPercentages.length;
  }

  // Convert PrayerStats to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'currentStreak': currentStreak,
      'highestStreak': highestStreak,
      'missedPrayers': missedPrayers,
      'completionPercentages': completionPercentages,
      'prayerHistory': prayerHistory.map((prayer) => prayer.toMap()).toList(),
    };
  }

  // Create a PrayerStats object from a Firestore document
  factory PrayerStats.fromMap(Map<String, dynamic> map) {
    List<DailyPrayer> history = [];
    if (map['prayerHistory'] != null) {
      history =
          (map['prayerHistory'] as List)
              .map((prayer) => DailyPrayer.fromMap(prayer))
              .toList();
    }

    return PrayerStats(
      currentStreak: map['currentStreak'] ?? 0,
      highestStreak: map['highestStreak'] ?? 0,
      missedPrayers: map['missedPrayers'] ?? 0,
      completionPercentages: Map<String, double>.from(
        map['completionPercentages'] ?? {},
      ),
      prayerHistory: history,
    );
  }
}

class DailyPrayer {
  final String date; // Format: yyyy-MM-dd
  final Map<String, bool> prayers;

  DailyPrayer({required this.date, required this.prayers});

  // Convert DailyPrayer to a map for Firestore
  Map<String, dynamic> toMap() {
    return {'date': date, 'prayers': prayers};
  }

  // Create a DailyPrayer object from a Firestore document
  factory DailyPrayer.fromMap(Map<String, dynamic> map) {
    return DailyPrayer(
      date: map['date'] ?? '',
      prayers: Map<String, bool>.from(map['prayers'] ?? {}),
    );
  }
}
