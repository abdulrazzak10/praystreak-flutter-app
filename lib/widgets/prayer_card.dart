import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/theme_constants.dart';
import 'fancy_card.dart';

class PrayerCard extends StatelessWidget {
  final String prayerName;
  final DateTime? prayerTime;
  final bool isPrayed;
  final bool isCurrentPrayer;
  final VoidCallback onTap;
  final String? timeFormat;
  final IconData? icon;

  const PrayerCard({
    super.key,
    required this.prayerName,
    this.prayerTime,
    required this.isPrayed,
    this.isCurrentPrayer = false,
    required this.onTap,
    this.timeFormat,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultIcon = _getPrayerIcon(prayerName);
    final prayerIcon = icon ?? defaultIcon;
    final formattedTime =
        prayerTime != null
            ? DateFormat(timeFormat ?? 'h:mm a').format(prayerTime!)
            : '-- : --';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: FancyCard(
        useGradientBorder: isCurrentPrayer,
        backgroundColor:
            isPrayed
                ? isDark
                    ? AppColors.darkPrimary.withOpacity(0.15)
                    : AppColors.primaryLight.withOpacity(0.1)
                : null,
        useShadow: isCurrentPrayer,
        padding: const EdgeInsets.all(16),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            isPrayed
                                ? isDark
                                    ? AppColors.darkPrimary.withOpacity(0.2)
                                    : AppColors.primaryLight.withOpacity(0.2)
                                : isDark
                                ? AppColors.darkSurface.withOpacity(0.7)
                                : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        prayerIcon,
                        color:
                            isPrayed
                                ? isDark
                                    ? AppColors.darkPrimary
                                    : AppColors.primary
                                : isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textMedium,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prayerName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                isPrayed
                                    ? isDark
                                        ? AppColors.darkPrimary
                                        : AppColors.primary
                                    : isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                _buildStatusIndicator(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            isPrayed
                ? isDark
                    ? AppColors.darkPrimary.withOpacity(0.2)
                    : AppColors.primaryLight.withOpacity(0.2)
                : isDark
                ? AppColors.darkSurface
                : AppColors.background,
        border: Border.all(
          color:
              isPrayed
                  ? isDark
                      ? AppColors.darkPrimary
                      : AppColors.primary
                  : isDark
                  ? AppColors.darkTextSecondary.withOpacity(0.3)
                  : AppColors.textLight.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Center(
        child:
            isPrayed
                ? Icon(
                  Icons.check_rounded,
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  size: 22,
                )
                : isCurrentPrayer
                ? Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isDark ? AppColors.darkSecondary : AppColors.secondary,
                  ),
                )
                : null,
      ),
    );
  }

  IconData _getPrayerIcon(String prayer) {
    switch (prayer.toLowerCase()) {
      case 'fajr':
        return Icons.wb_twilight;
      case 'dhuhr':
        return Icons.wb_sunny;
      case 'asr':
        return Icons.sunny_snowing;
      case 'maghrib':
        return Icons.nightlight_round;
      case 'isha':
        return Icons.nightlight;
      default:
        return Icons.access_time;
    }
  }
}
