import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/prayer_service.dart';
import '../models/user_model.dart';
import '../models/prayer_model.dart';
import '../models/prayer_stats.dart';

class StreaksScreen extends StatefulWidget {
  const StreaksScreen({super.key});

  @override
  State<StreaksScreen> createState() => _StreaksScreenState();
}

class _StreaksScreenState extends State<StreaksScreen> {
  late PrayerService _prayerService;
  bool _isLoading = true;
  UserModel? _user;
  List<DailyPrayer> _prayerHistory = [];

  // Weekly prayer stats
  List<int> _weeklyStats = List.filled(7, 0);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prayerService = Provider.of<PrayerService>(context);
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;

      if (user != null) {
        // Load user data
        final userData = await authService.getUserData(user.uid);

        if (userData != null) {
          // Load prayer history from prayer service
          final history = _prayerService.getPrayerHistory();

          // Calculate weekly stats
          List<int> weeklyStats = List.filled(7, 0);

          for (int i = 0; i < history.length && i < 7; i++) {
            DailyPrayer dailyPrayer = history[i];
            // Count completed prayers for this day
            int completedCount =
                dailyPrayer.prayers.values
                    .where((completed) => completed)
                    .length;

            // Try to determine days ago based on date string (assuming format: yyyy-MM-dd)
            DateTime prayerDate = DateTime.now();
            try {
              prayerDate = DateFormat('yyyy-MM-dd').parse(dailyPrayer.date);
            } catch (e) {
              print('Error parsing date: ${dailyPrayer.date}');
            }

            int daysAgo = DateTime.now().difference(prayerDate).inDays;
            if (daysAgo < 7) {
              weeklyStats[daysAgo] = completedCount;
            }
          }

          setState(() {
            _user = userData;
            _prayerHistory = history;
            _weeklyStats = weeklyStats;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Streaks'),
        elevation: 1,
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStreakCard(),
                    const SizedBox(height: 24),
                    _buildWeeklyStatsCard(),
                    const SizedBox(height: 24),
                    _buildPrayerHistorySection(),
                  ],
                ),
              ),
    );
  }

  Widget _buildStreakCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Streak',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Icon(
                  Icons.local_fire_department,
                  color: Colors.orange[700],
                  size: 30,
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: Colors.orange[700],
                  size: 50,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_user?.currentStreak ?? 0}',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Days in a row',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Longest Streak',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_user?.longestStreak ?? 0} days',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.star, color: Colors.amber[700], size: 30),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyStatsCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Stats',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(height: 200, child: _buildWeeklyChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    // Get the days of the week
    List<String> dayLabels = [];
    final DateTime now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final DateTime date = now.subtract(Duration(days: i));
      dayLabels.add(DateFormat('E').format(date));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        // Reverse the index to show oldest day first
        final reversedIndex = 6 - index;
        final int prayerCount = _weeklyStats[reversedIndex];

        // Calculate bar height (max 5 prayers per day)
        final double barHeightPercent = prayerCount / 5;
        final double barHeight = 150 * barHeightPercent;

        // Determine bar color based on prayer count
        Color barColor;
        if (prayerCount == 5) {
          barColor = Colors.green;
        } else if (prayerCount >= 3) {
          barColor = Colors.amber;
        } else if (prayerCount > 0) {
          barColor = Colors.orange;
        } else {
          barColor = Colors.grey.shade300;
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Prayer count
            Text(
              '$prayerCount',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: prayerCount > 0 ? Colors.black87 : Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            // Bar
            Container(
              width: 30,
              height: barHeight > 0 ? barHeight : 20,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            // Day label
            Text(
              dayLabels[index],
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPrayerHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Prayer History',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _prayerHistory.isEmpty
            ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No prayer history available'),
              ),
            )
            : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _prayerHistory.length,
              itemBuilder: (context, index) {
                return _buildHistoryItem(_prayerHistory[index]);
              },
            ),
      ],
    );
  }

  Widget _buildHistoryItem(DailyPrayer dailyPrayer) {
    // Parse the date string from DailyPrayer
    DateTime prayerDate;
    try {
      prayerDate = DateFormat('yyyy-MM-dd').parse(dailyPrayer.date);
    } catch (e) {
      prayerDate = DateTime.now(); // Fallback to today if date can't be parsed
    }

    final String date = DateFormat('EEEE, MMMM d').format(prayerDate);
    final bool isToday =
        dailyPrayer.date == DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Count completed prayers
    int completedCount =
        dailyPrayer.prayers.values.where((completed) => completed).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color:
                    completedCount == 5
                        ? Colors.green.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  '$completedCount/5',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: completedCount == 5 ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isToday ? 'Today' : date,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getStatusMessage(completedCount),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(
              completedCount == 5 ? Icons.check_circle : Icons.warning,
              color: completedCount == 5 ? Colors.green : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusMessage(int completedCount) {
    if (completedCount == 0) {
      return 'No prayers completed';
    } else if (completedCount == 5) {
      return 'All prayers completed!';
    } else {
      return '$completedCount prayers completed';
    }
  }
}
