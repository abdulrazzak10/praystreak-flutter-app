import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/prayer_stats.dart';
import '../models/prayer_model.dart';
import 'auth_service.dart';

class PrayerService extends ChangeNotifier {
  PrayerStats? _prayerStats;
  final AuthService _authService;
  bool _isLoading = false;
  String? _userId;
  final String _currentTimeZone = 'UTC';

  PrayerService(this._authService) {
    _init();
  }

  PrayerStats? get prayerStats => _prayerStats;
  bool get isLoading => _isLoading;

  Future<void> _init() async {
    // Initialize user ID from auth service
    _userId = _authService.currentUser?.uid;

    // Load existing prayer stats
    await loadPrayerStats();

    // Listen for authentication changes
    _authService.authStateChanges.listen((isLoggedIn) {
      if (isLoggedIn) {
        _userId = _authService.currentUser?.uid;
        loadPrayerStats();
      } else {
        // User logged out, clear data
        _prayerStats = null;
        notifyListeners();
      }
    });
  }

  Future<void> loadPrayerStats() async {
    if (_userId == null) {
      print('No user ID available, cannot load prayer stats');
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      // Load data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString('prayer_stats_$_userId');

      if (statsJson != null) {
        // Parse the stats from JSON
        final Map<String, dynamic> statsMap = jsonDecode(statsJson);
        _prayerStats = _prayerStatsFromJson(statsMap);
      } else {
        // Create default stats if none exists
        _prayerStats = PrayerStats(
          currentStreak: 0,
          highestStreak: 0,
          missedPrayers: 0,
          completionPercentages: {
            'Fajr': 0.0,
            'Dhuhr': 0.0,
            'Asr': 0.0,
            'Maghrib': 0.0,
            'Isha': 0.0,
          },
          prayerHistory: _createDefaultPrayerHistory(),
        );

        // Save the default stats
        await savePrayerStats();
      }
    } catch (e) {
      print('Error loading prayer stats: $e');
      // Create default stats in case of error
      _prayerStats = PrayerStats.mockData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to create PrayerStats from JSON
  PrayerStats _prayerStatsFromJson(Map<String, dynamic> json) {
    return PrayerStats(
      currentStreak: json['currentStreak'] ?? 0,
      highestStreak: json['highestStreak'] ?? 0,
      missedPrayers: json['missedPrayers'] ?? 0,
      completionPercentages: Map<String, double>.from(
        json['completionPercentages'] ?? {},
      ),
      prayerHistory: _prayerHistoryFromJson(json['prayerHistory'] ?? []),
    );
  }

  // Helper method to convert prayer history from JSON
  List<DailyPrayer> _prayerHistoryFromJson(List<dynamic> json) {
    return json
        .map(
          (item) => DailyPrayer(
            date: item['date'],
            prayers: Map<String, bool>.from(item['prayers'] ?? {}),
          ),
        )
        .toList();
  }

  // Helper method to convert PrayerStats to JSON
  Map<String, dynamic> _prayerStatsToJson(PrayerStats stats) {
    return {
      'currentStreak': stats.currentStreak,
      'highestStreak': stats.highestStreak,
      'missedPrayers': stats.missedPrayers,
      'completionPercentages': stats.completionPercentages,
      'prayerHistory': _prayerHistoryToJson(stats.prayerHistory),
    };
  }

  // Helper method to convert prayer history to JSON
  List<Map<String, dynamic>> _prayerHistoryToJson(List<DailyPrayer> history) {
    return history
        .map((item) => {'date': item.date, 'prayers': item.prayers})
        .toList();
  }

  Future<void> savePrayerStats() async {
    if (_userId == null || _prayerStats == null) {
      print('Cannot save prayer stats: user ID or stats are null');
      return;
    }

    try {
      // Convert stats to JSON and save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final statsJson = jsonEncode(_prayerStatsToJson(_prayerStats!));
      await prefs.setString('prayer_stats_$_userId', statsJson);
      print('Prayer stats saved successfully');
    } catch (e) {
      print('Error saving prayer stats: $e');
    }
  }

  Future<void> recordPrayer(String prayerName, bool completed) async {
    if (_prayerStats == null) {
      await loadPrayerStats();
      if (_prayerStats == null) {
        print('Failed to load prayer stats');
        return;
      }
    }

    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Find today's prayer record or create it
      DailyPrayer? todayRecord;
      try {
        todayRecord = _prayerStats!.prayerHistory.firstWhere(
          (record) => record.date == today,
        );
      } catch (e) {
        // Not found, create new
        todayRecord = DailyPrayer(date: today, prayers: {});
        _prayerStats!.prayerHistory.add(todayRecord);
      }

      // Update the prayer status
      final updatedPrayers = Map<String, bool>.from(todayRecord.prayers);
      updatedPrayers[prayerName] = completed;

      // Create new record with updated prayers
      final updatedRecord = DailyPrayer(
        date: todayRecord.date,
        prayers: updatedPrayers,
      );

      // Replace the old record with the updated one
      final index = _prayerStats!.prayerHistory.indexOf(todayRecord);
      if (index >= 0) {
        _prayerStats!.prayerHistory[index] = updatedRecord;
      } else {
        _prayerStats!.prayerHistory.add(updatedRecord);
      }

      // Update statistics
      await updateStats();

      // Save the updated stats
      await savePrayerStats();

      notifyListeners();
    } catch (e) {
      print('Error recording prayer: $e');
    }
  }

  Future<void> updateStats() async {
    if (_prayerStats == null) return;

    try {
      // Calculate streak
      final streak = calculateStreak();

      // Create a new PrayerStats object with updated values
      _prayerStats = PrayerStats(
        currentStreak: streak,
        highestStreak:
            streak > (_prayerStats!.highestStreak)
                ? streak
                : _prayerStats!.highestStreak,
        missedPrayers: _calculateMissedPrayers(),
        completionPercentages: calculateCompletionPercentages(),
        prayerHistory: _prayerStats!.prayerHistory,
      );

      notifyListeners();
    } catch (e) {
      print('Error updating prayer stats: $e');
    }
  }

  // Helper method to calculate missed prayers
  int _calculateMissedPrayers() {
    if (_prayerStats == null) return 0;

    int missedCount = 0;
    for (var dailyPrayer in _prayerStats!.prayerHistory) {
      for (var entry in dailyPrayer.prayers.entries) {
        if (entry.value == false) {
          missedCount++;
        }
      }
    }
    return missedCount;
  }

  int calculateStreak() {
    if (_prayerStats == null || _prayerStats!.prayerHistory.isEmpty) {
      return 0;
    }

    // Sort history by date (descending)
    final sortedHistory = List<DailyPrayer>.from(_prayerStats!.prayerHistory)
      ..sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final yesterday = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now().subtract(const Duration(days: 1)));

    // Check if today or yesterday exists in history to start the streak
    if (!sortedHistory.any(
      (record) => record.date == today || record.date == yesterday,
    )) {
      return 0;
    }

    // Calculate the streak
    for (int i = 0; i < sortedHistory.length; i++) {
      final dailyPrayer = sortedHistory[i];

      // Check if this day had all prayers completed
      final allCompleted = dailyPrayer.prayers.values.every(
        (completed) => completed,
      );

      if (!allCompleted) break;

      // Check if this day is in sequence with the previous one
      if (i > 0) {
        final currentDate = DateTime.parse(dailyPrayer.date);
        final prevDate = DateTime.parse(sortedHistory[i - 1].date);
        final difference = prevDate.difference(currentDate).inDays;

        if (difference != 1) break;
      }

      streak++;
    }

    return streak;
  }

  Map<String, double> calculateCompletionPercentages() {
    if (_prayerStats == null || _prayerStats!.prayerHistory.isEmpty) {
      return {
        'Fajr': 0.0,
        'Dhuhr': 0.0,
        'Asr': 0.0,
        'Maghrib': 0.0,
        'Isha': 0.0,
      };
    }

    // Count completed prayers for each prayer time
    Map<String, int> completed = {
      'Fajr': 0,
      'Dhuhr': 0,
      'Asr': 0,
      'Maghrib': 0,
      'Isha': 0,
    };

    Map<String, int> total = {
      'Fajr': 0,
      'Dhuhr': 0,
      'Asr': 0,
      'Maghrib': 0,
      'Isha': 0,
    };

    // Calculate completion for each prayer
    for (var dailyPrayer in _prayerStats!.prayerHistory) {
      for (var entry in dailyPrayer.prayers.entries) {
        final prayerName = entry.key;
        final isCompleted = entry.value;

        total[prayerName] = (total[prayerName] ?? 0) + 1;
        if (isCompleted) {
          completed[prayerName] = (completed[prayerName] ?? 0) + 1;
        }
      }
    }

    // Calculate percentages
    Map<String, double> percentages = {};
    for (var prayer in total.keys) {
      if (total[prayer]! > 0) {
        percentages[prayer] = (completed[prayer]! / total[prayer]!) * 100;
      } else {
        percentages[prayer] = 0.0;
      }
    }

    return percentages;
  }

  List<DailyPrayer> _createDefaultPrayerHistory() {
    final List<DailyPrayer> history = [];
    final today = DateTime.now();

    // Create records for past 7 days
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);

      // Generate random prayer completion status based on date
      Map<String, bool> prayers = {
        'Fajr': date.day % 3 != 0,
        'Dhuhr': date.day % 2 == 0,
        'Asr': date.day % 4 != 0,
        'Maghrib': date.day % 5 != 0,
        'Isha': date.day % 3 == 0,
      };

      history.add(DailyPrayer(date: dateStr, prayers: prayers));
    }

    return history;
  }

  String getArabicPrayerName(String englishName) {
    final Map<String, String> arabicNames = {
      'Fajr': 'الفجر',
      'Dhuhr': 'الظهر',
      'Asr': 'العصر',
      'Maghrib': 'المغرب',
      'Isha': 'العشاء',
    };

    return arabicNames[englishName] ?? englishName;
  }

  // Get today's prayers
  Map<String, bool> getTodaysPrayers() {
    if (_prayerStats == null) return {};

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      final todayRecord = _prayerStats!.prayerHistory.firstWhere(
        (record) => record.date == today,
      );
      return Map<String, bool>.from(todayRecord.prayers);
    } catch (e) {
      // Today not found, return empty map with default values
      return {
        'Fajr': false,
        'Dhuhr': false,
        'Asr': false,
        'Maghrib': false,
        'Isha': false,
      };
    }
  }

  // Get all prayer history
  List<DailyPrayer> getPrayerHistory() {
    if (_prayerStats == null) return [];
    return _prayerStats!.prayerHistory;
  }

  // Reset streak (for testing)
  Future<void> resetStreak() async {
    if (_prayerStats != null) {
      _prayerStats = PrayerStats(
        currentStreak: 0,
        highestStreak: _prayerStats!.highestStreak,
        missedPrayers: _prayerStats!.missedPrayers,
        completionPercentages: _prayerStats!.completionPercentages,
        prayerHistory: _prayerStats!.prayerHistory,
      );
      await savePrayerStats();
      notifyListeners();
    }
  }
}
