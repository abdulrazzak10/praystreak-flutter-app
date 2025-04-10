import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';

class StreakIndicator extends StatelessWidget {
  final int currentStreak;
  final int maxStreak;
  final double size;
  final bool showText;
  final String? subtitle;
  final Color? progressColor;
  final Color? backgroundColor;
  final Widget? centerWidget;
  final bool useAnimation;

  const StreakIndicator({
    super.key,
    required this.currentStreak,
    this.maxStreak = 100,
    this.size = 200,
    this.showText = true,
    this.subtitle,
    this.progressColor,
    this.backgroundColor,
    this.centerWidget,
    this.useAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressClr =
        progressColor ?? (isDark ? AppColors.darkPrimary : AppColors.primary);
    final bgColor =
        backgroundColor ??
        (isDark ? AppColors.darkSurface : AppColors.background);

    final percentage = min(1.0, currentStreak / maxStreak.toDouble());

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
              ],
            ),
          ),

          // Progress circle
          useAnimation
              ? TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: percentage),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return _buildProgressCircle(
                    size: size,
                    percentage: value,
                    progressColor: progressClr,
                    isDark: isDark,
                  );
                },
              )
              : _buildProgressCircle(
                size: size,
                percentage: percentage,
                progressColor: progressClr,
                isDark: isDark,
              ),

          // Center content
          Positioned.fill(
            child: Center(
              child:
                  centerWidget ??
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (showText) ...[
                        useAnimation
                            ? TweenAnimationBuilder<int>(
                              tween: IntTween(begin: 0, end: currentStreak),
                              duration: const Duration(milliseconds: 1200),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Text(
                                  value.toString(),
                                  style: TextStyle(
                                    fontSize: size * 0.2,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.textDark,
                                  ),
                                );
                              },
                            )
                            : Text(
                              currentStreak.toString(),
                              style: TextStyle(
                                fontSize: size * 0.2,
                                fontWeight: FontWeight.bold,
                                color:
                                    isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.textDark,
                              ),
                            ),
                        SizedBox(height: size * 0.02),
                        Text(
                          subtitle ?? 'Day Streak',
                          style: TextStyle(
                            fontSize: size * 0.07,
                            fontWeight: FontWeight.w500,
                            color:
                                isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textMedium,
                          ),
                        ),
                      ],
                    ],
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle({
    required double size,
    required double percentage,
    required Color progressColor,
    required bool isDark,
  }) {
    return CustomPaint(
      size: Size(size, size),
      painter: CircleProgressPainter(
        percentage: percentage,
        progressColor: progressColor,
        strokeWidth: size * 0.05,
        isDark: isDark,
      ),
    );
  }
}

class CircleProgressPainter extends CustomPainter {
  final double percentage;
  final Color progressColor;
  final double strokeWidth;
  final bool isDark;

  CircleProgressPainter({
    required this.percentage,
    required this.progressColor,
    required this.strokeWidth,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background arc
    final bgPaint =
        Paint()
          ..color =
              isDark
                  ? AppColors.darkTextSecondary.withOpacity(0.1)
                  : AppColors.textLight.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start from top
      2 * pi, // Full circle
      false,
      bgPaint,
    );

    // Draw progress arc
    final progressPaint =
        Paint()
          ..shader = LinearGradient(
            colors: [
              progressColor,
              progressColor
                  .withBlue(min(255, progressColor.blue + 40))
                  .withGreen(min(255, progressColor.green + 20)),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start from top
      2 * pi * percentage,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircleProgressPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
