import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';

class FancyCard extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadius borderRadius;
  final GestureTapCallback? onTap;
  final bool useGradientBorder;
  final Color? borderColor;
  final double borderWidth;
  final bool useShadow;
  final Color? backgroundColor;

  const FancyCard({
    super.key,
    required this.child,
    this.height,
    this.width,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(vertical: 8),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.onTap,
    this.useGradientBorder = false,
    this.borderColor,
    this.borderWidth = 1.5,
    this.useShadow = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    // Default colors based on theme
    final bgColor =
        backgroundColor ??
        (isDark ? AppColors.darkSurface : AppColors.surfaceLight);

    final defaultBorderColor =
        isDark
            ? AppColors.darkPrimary.withOpacity(0.3)
            : AppColors.primary.withOpacity(0.2);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient:
            useGradientBorder
                ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      isDark
                          ? [AppColors.darkPrimary, AppColors.accent]
                          : [AppColors.primary, AppColors.accent],
                )
                : null,
        boxShadow:
            useShadow
                ? isDark
                    ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : AppShadows.medium
                : null,
      ),
      child: Container(
        height: height,
        width: width,
        margin: useGradientBorder ? const EdgeInsets.all(1.5) : null,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius:
              useGradientBorder
                  ? BorderRadius.circular(borderRadius.topLeft.x - 1.5)
                  : borderRadius,
          border:
              !useGradientBorder
                  ? Border.all(
                    color: borderColor ?? defaultBorderColor,
                    width: borderWidth,
                  )
                  : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius:
                useGradientBorder
                    ? BorderRadius.circular(borderRadius.topLeft.x - 1.5)
                    : borderRadius,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
