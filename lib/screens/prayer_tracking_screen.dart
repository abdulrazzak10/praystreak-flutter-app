import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/prayer_service.dart';
import '../models/prayer_model.dart';
import '../models/prayer_stats.dart';

class PrayerTrackingScreen extends StatefulWidget {
  final String userId;

  const PrayerTrackingScreen({super.key, required this.userId});

  @override
  State<PrayerTrackingScreen> createState() => _PrayerTrackingScreenState();
}

class _PrayerTrackingScreenState extends State<PrayerTrackingScreen> {
  DateTime _selectedDate = DateTime.now();
  late PrayerService _prayerService;
  bool _isLoading = true;
  Map<String, bool> _prayerStatus = {};

  @override
  void initState() {
    super.initState();
    _loadPrayers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prayerService = Provider.of<PrayerService>(context);
    _loadPrayers();
  }

  // Load prayers for the selected date
  Future<void> _loadPrayers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final selectedDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

      // If date is today, use getTodaysPrayers, otherwise look through history
      if (selectedDateStr == today) {
        _prayerStatus = _prayerService.getTodaysPrayers();
      } else {
        // Find prayers for selected date in prayer history
        final history = _prayerService.getPrayerHistory();
        final dayPrayer = history.firstWhere(
          (day) => day.date == selectedDateStr,
          orElse: () => _createEmptyDayPrayer(selectedDateStr),
        );
        _prayerStatus = Map<String, bool>.from(dayPrayer.prayers);
      }
    } catch (e) {
      print('Error loading prayers: $e');
      // Initialize with empty prayers if there's an error
      _prayerStatus = {
        'Fajr': false,
        'Dhuhr': false,
        'Asr': false,
        'Maghrib': false,
        'Isha': false,
      };
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Create an empty day prayer record when none exists
  DailyPrayer _createEmptyDayPrayer(String dateStr) {
    return DailyPrayer(
      date: dateStr,
      prayers: {
        'Fajr': false,
        'Dhuhr': false,
        'Asr': false,
        'Maghrib': false,
        'Isha': false,
      },
    );
  }

  // Update prayer status
  Future<void> _updatePrayer(String prayerName, bool completed) async {
    try {
      // Update local state
      setState(() {
        _prayerStatus[prayerName] = completed;
      });

      // Update in service
      await _prayerService.recordPrayer(prayerName, completed);
    } catch (e) {
      print('Error updating prayer: $e');
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update prayer: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Change date
  void _changeDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadPrayers();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMM d, yyyy');
    final formattedDate = dateFormat.format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Tracking'),
        centerTitle: true,
        elevation: 1,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Date selector
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: () {
                            _changeDate(
                              _selectedDate.subtract(const Duration(days: 1)),
                            );
                          },
                        ),
                        TextButton(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null && mounted) {
                              _changeDate(picked);
                            }
                          },
                          child: Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          onPressed:
                              _selectedDate.isBefore(
                                    DateTime.now().subtract(
                                      const Duration(days: 1),
                                    ),
                                  )
                                  ? () {
                                    _changeDate(
                                      _selectedDate.add(
                                        const Duration(days: 1),
                                      ),
                                    );
                                  }
                                  : null,
                        ),
                      ],
                    ),
                  ),

                  const Divider(),

                  // Prayer list
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16.0),
                      children:
                          _prayerStatus.entries.map((entry) {
                            final prayerName = entry.key;
                            final completed = entry.value;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12.0),
                              elevation: 2,
                              child: SwitchListTile(
                                title: Text(
                                  prayerName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  _prayerService.getArabicPrayerName(
                                    prayerName,
                                  ),
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                secondary: Icon(
                                  completed
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: completed ? Colors.green : Colors.grey,
                                  size: 32,
                                ),
                                value: completed,
                                onChanged: (value) {
                                  _updatePrayer(prayerName, value);
                                },
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
    );
  }
}
