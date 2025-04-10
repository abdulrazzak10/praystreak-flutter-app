import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../main.dart'; // Import for ThemeProvider
import 'auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:random_avatar/random_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  UserModel? _user;
  String _selectedLanguage = 'English';
  String? _location;
  String _avatarSeed = '';

  // Streak stats (mock data - replace with actual data from your services)
  final int _currentStreak = 15;
  final int _highestStreak = 30;
  final int _missedPrayers = 8;

  // Prayer completion percentages (mock data)
  final Map<String, double> _prayerCompletionPercentages = {
    'Fajr': 80.0,
    'Dhuhr': 95.0,
    'Asr': 90.0,
    'Maghrib': 98.0,
    'Isha': 85.0,
  };

  // Prayer history (mock data)
  final List<Map<String, dynamic>> _prayerHistory = List.generate(
    7,
    (index) => {
      'date': DateTime.now().subtract(Duration(days: index)),
      'prayers': {
        'Fajr': index % 3 == 0 ? false : true,
        'Dhuhr': true,
        'Asr': index % 4 == 0 ? false : true,
        'Maghrib': true,
        'Isha': index % 5 == 0 ? false : true,
      },
    },
  );

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // Get dark mode preference
    _isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    // Generate a random seed for avatar
    _generateAvatarSeed();
  }

  void _generateAvatarSeed() {
    // Generate a random seed based on the current time
    _avatarSeed = DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;

      if (user != null) {
        final userData = await authService.getUserData(user.uid);
        setState(() {
          _user = userData;
          _isLoading = false;

          // Use user ID as seed for consistent avatar
          if (_user != null) {
            _avatarSeed = _user!.uid;
          }
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showEditProfileDialog() async {
    if (_user == null) return;

    final nameController = TextEditingController(text: _user!.name);
    final emailController = TextEditingController(text: _user!.email);
    final locationController = TextEditingController(text: _location ?? '');

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter your name',
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                  ),
                  enabled: false, // Email shouldn't be editable
                ),
                SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location (optional)',
                    hintText: 'Enter your location for prayer times',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final authService = Provider.of<AuthService>(
                    context,
                    listen: false,
                  );
                  final user = authService.currentUser;

                  if (user != null) {
                    await authService.updateUserProfile(user.uid, {
                      'name': nameController.text.trim(),
                      'location': locationController.text.trim(),
                    });

                    setState(() {
                      _location = locationController.text.trim();
                    });

                    // Reload user data
                    await _loadUserData();

                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile updated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      // Show loading indicator
      setState(() {
        _isLoading = true;
      });

      print("Starting sign out process");

      // Clear SharedPreferences login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('user_uid');

      // Sign out from Firebase Auth
      await authService.signOut();
      print("Sign out completed");

      if (mounted) {
        // Clear any saved navigation history and go to login
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      print("Error during sign out: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleDarkMode(bool value) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.toggleTheme();
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });
    // TODO: Save notification preferences to user settings
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value ? 'Notifications enabled' : 'Notifications disabled',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _changeLanguage(String language) {
    setState(() {
      _selectedLanguage = language;
    });
    // TODO: Implement language change functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Language changed to $language'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete Account'),
              ],
            ),
            content: Text(
              'Are you sure you want to delete your account? This action cannot be undone, and all your data will be permanently lost.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement delete account functionality
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Account deletion is not implemented yet'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text('Delete Permanently'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
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
                    _buildProfileHeader(),
                    const SizedBox(height: 24),
                    _buildStreakStats(),
                    const SizedBox(height: 24),
                    _buildPrayerCompletion(),
                    const SizedBox(height: 24),
                    _buildPrayerHistory(),
                    const SizedBox(height: 24),
                    _buildSettingsSection(),
                    const SizedBox(height: 24),
                    _buildAccountSection(),
                  ],
                ),
              ),
    );
  }

  Widget _buildProfileHeader() {
    if (_user == null) {
      return const Center(child: Text('User data not available'));
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Title
            Row(
              children: [
                Icon(Icons.person, color: Theme.of(context).primaryColor),
                SizedBox(width: 8),
                Text(
                  'User Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Random Bitmoji avatar
            Center(
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: RandomAvatar(_avatarSeed, height: 120, width: 120),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // User name
            Text(
              _user!.name,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),

            // User email
            Text(
              _user!.email,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),

            // Location
            if (_location != null && _location!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                    SizedBox(width: 4),
                    Text(
                      _location!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Edit profile button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showEditProfileDialog,
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakStats() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Icon(Icons.whatshot, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Streak Stats',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Streak stats in a row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  'Current Streak',
                  '$_currentStreak days',
                  Icons.trending_up,
                  Colors.green,
                ),
                _buildStatItem(
                  'Highest Streak',
                  '$_highestStreak days',
                  Icons.emoji_events,
                  Colors.amber,
                ),
                _buildStatItem(
                  'Missed Namaz',
                  '$_missedPrayers',
                  Icons.cancel_outlined,
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildPrayerCompletion() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Icon(Icons.insights, color: Theme.of(context).primaryColor),
                SizedBox(width: 8),
                Text(
                  'Prayer Completion',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  'Overall: 90%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Prayer completion bars
            ..._prayerCompletionPercentages.entries
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              entry.key,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '${entry.value.toInt()}%',
                              style: TextStyle(
                                color: _getColorForPercentage(entry.value),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: entry.value / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getColorForPercentage(entry.value),
                          ),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  Color _getColorForPercentage(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 70) return Colors.lightGreen;
    if (percentage >= 50) return Colors.amber;
    if (percentage >= 30) return Colors.orange;
    return Colors.red;
  }

  Widget _buildPrayerHistory() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with dropdown for timeframe
            Row(
              children: [
                Icon(Icons.history, color: Theme.of(context).primaryColor),
                SizedBox(width: 8),
                Text(
                  'Namaz History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                DropdownButton<String>(
                  value: 'Last 7 days',
                  underline: Container(),
                  items:
                      ['Last 7 days', 'Last 30 days']
                          .map(
                            (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                  onChanged: (String? newValue) {
                    // TODO: Implement timeframe change
                  },
                ),
              ],
            ),
            SizedBox(height: 16),

            // Prayer history table
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Table header
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Date',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ..._prayerCompletionPercentages.keys
                            .map(
                              (prayer) => Expanded(
                                flex: 1,
                                child: Center(
                                  child: Text(
                                    prayer,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ],
                    ),
                  ),

                  // Table rows
                  ..._prayerHistory
                      .map(
                        (day) => Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${day['date'].day}/${day['date'].month}/${day['date'].year}',
                                ),
                              ),
                              ..._prayerCompletionPercentages.keys
                                  .map(
                                    (prayer) => Expanded(
                                      flex: 1,
                                      child: Center(
                                        child: Icon(
                                          day['prayers'][prayer]
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          color:
                                              day['prayers'][prayer]
                                                  ? Colors.green
                                                  : Colors.red,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Theme.of(context).primaryColor),
                SizedBox(width: 8),
                Text(
                  'Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Notifications
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.notifications),
              title: const Text('Prayer Reminders'),
              subtitle: const Text('Get notified before prayer times'),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
                activeColor: Theme.of(context).primaryColor,
              ),
            ),

            const Divider(),

            // Dark mode toggle
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: _isDarkMode,
                onChanged: _toggleDarkMode,
                activeColor: Theme.of(context).primaryColor,
              ),
            ),

            const Divider(),

            // Language
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                underline: Container(),
                items:
                    ['English', 'Urdu']
                        .map(
                          (String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _changeLanguage(newValue);
                  }
                },
              ),
            ),

            const Divider(),

            // Prayer Time Settings
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time),
              title: const Text('Prayer Time Settings'),
              subtitle: const Text('Set calculation method, adjustments'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: Navigate to prayer time settings
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Prayer time settings not implemented yet'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_circle,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  'Account',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Delete account
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text(
                'Delete Account',
                style: TextStyle(color: Colors.red),
              ),
              onTap: _showDeleteAccountDialog,
            ),

            const Divider(),

            // Sign out
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: _signOut,
            ),
          ],
        ),
      ),
    );
  }
}
