import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/prayer_service.dart';
import '../models/prayer_model.dart';
import '../models/user_model.dart';
import 'prayer_tracking_screen.dart';
import 'streaks_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late PrayerService _prayerService;
  UserModel? _user;
  DailyPrayers? _todayPrayers;
  bool _isLoading = true;
  late AuthService _authService;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // We'll initialize the services in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authService = Provider.of<AuthService>(context);
    _prayerService = Provider.of<PrayerService>(context);
    _loadUserData();

    // Set up a timer to refresh data every 5 minutes
    _refreshTimer ??= Timer.periodic(const Duration(minutes: 5), (timer) {
      if (mounted) {
        _loadUserData(showLoading: false);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // Load user data and today's prayers
  Future<void> _loadUserData({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      var user = _authService.currentUser;

      // If user is null, check if we have a saved user_uid in SharedPreferences
      if (user == null) {
        final prefs = await SharedPreferences.getInstance();
        final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
        final savedUid = prefs.getString('userId');

        print(
          'Current user is null. SharedPrefs isLoggedIn: $isLoggedIn, savedUid: $savedUid',
        );

        if (!isLoggedIn || savedUid == null) {
          // No saved login state, redirect to login
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
          return;
        }
      }

      // Get user data from auth service
      if (user != null) {
        final userData = await _authService.getUserData(user.uid);
        if (userData != null) {
          _user = userData;
        }
      }

      // Generate today's prayers based on the prayer service data
      _todayPrayers = _createTodayPrayers();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
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
  }

  // Create today's prayers from the prayer service
  DailyPrayers _createTodayPrayers() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final prayerMap = _prayerService.getTodaysPrayers();

    final List<Prayer> prayers = [];
    int completedCount = 0;

    // Create Prayer objects for each prayer time
    prayerMap.forEach((name, completed) {
      final prayer = Prayer(
        id: name,
        name: name,
        arabicName: _prayerService.getArabicPrayerName(name),
        time: _getPrayerTime(name, today),
        completed: completed,
      );

      prayers.add(prayer);
      if (completed) completedCount++;
    });

    return DailyPrayers(
      id: DateFormat('yyyy-MM-dd').format(today),
      date: today,
      prayers: prayers,
      completedCount: completedCount,
    );
  }

  // Helper method to get prayer times
  DateTime _getPrayerTime(String prayerName, DateTime date) {
    // Return default prayer times
    switch (prayerName) {
      case 'Fajr':
        return DateTime(date.year, date.month, date.day, 5, 30);
      case 'Dhuhr':
        return DateTime(date.year, date.month, date.day, 12, 30);
      case 'Asr':
        return DateTime(date.year, date.month, date.day, 15, 45);
      case 'Maghrib':
        return DateTime(date.year, date.month, date.day, 18, 15);
      case 'Isha':
        return DateTime(date.year, date.month, date.day, 20, 0);
      default:
        return date;
    }
  }

  // Navigate to prayer tracking screen
  void _goToPrayerTracking() {
    if (_authService.currentUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) =>
                  PrayerTrackingScreen(userId: _authService.currentUser!.uid),
        ),
      ).then((_) => _loadUserData()); // Refresh data when returning
    }
  }

  // Change bottom navigation tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define the screens for bottom navigation
    final List<Widget> screens = [
      Scaffold(
        appBar: AppBar(
          title: const Text('Praystreak'),
          centerTitle: true,
          elevation: 1,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: _buildHomeTab(),
      ),
      const StreaksScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_fire_department),
            label: 'Streaks',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // Build the home tab content
  Widget _buildHomeTab() {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final formattedDate = dateFormat.format(now);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Text(
            'Assalamu Alaikum${_user != null ? ', ${_user!.name}' : ''}',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            formattedDate,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Prayer streak card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Current Streak',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_prayerService.prayerStats?.currentStreak ?? 0} days',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Longest Streak',
                        style: TextStyle(fontSize: 16),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${_prayerService.prayerStats?.highestStreak ?? 0} days',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Today's prayers heading
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Prayers",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (_todayPrayers != null)
                Text(
                  '${_todayPrayers!.completedCount}/5 completed',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Prayer progress cards
          if (_todayPrayers != null)
            ...List.generate(
              _todayPrayers!.prayers.length,
              (index) => _buildPrayerItem(_todayPrayers!.prayers[index]),
            )
          else
            const Center(child: Text('No prayers found for today')),

          const SizedBox(height: 24),

          // Prayer tracking button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _goToPrayerTracking,
              icon: const Icon(Icons.edit),
              label: const Text('Track Your Prayers'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build a prayer item card
  Widget _buildPrayerItem(Prayer prayer) {
    final TimeOfDay prayerTime = TimeOfDay(
      hour: prayer.time.hour,
      minute: prayer.time.minute,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          prayer.completed ? Icons.check_circle : Icons.circle_outlined,
          color: prayer.completed ? Colors.green : Colors.grey,
          size: 28,
        ),
        title: Text(
          prayer.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          prayer.arabicName,
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Text(
          prayerTime.format(context),
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
