import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../constants/theme_constants.dart';

enum ButtonType { primary, secondary, outline, text }

class FancyButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double height;
  final IconData? icon;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;
  final bool useGradient;
  final List<Color>? gradientColors;
  final TextStyle? textStyle;

  const FancyButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.width,
    this.height = 52.0,
    this.icon,
    this.borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
    this.useGradient = false,
    this.gradientColors,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultRadius = borderRadius ?? BorderRadius.circular(12);

    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SpinKitFadingCircle(color: _getTextColor(isDark), size: 20.0)
        else ...[
          if (icon != null) ...[
            Icon(icon, color: _getTextColor(isDark), size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style:
                textStyle ??
                TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _getTextColor(isDark),
                ),
          ),
        ],
      ],
    );

    // For primary and secondary buttons
    if (type == ButtonType.primary || type == ButtonType.secondary) {
      return SizedBox(
        width: isFullWidth ? double.infinity : width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: defaultRadius,
            gradient:
                useGradient
                    ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors:
                          gradientColors ??
                          (type == ButtonType.primary
                              ? (isDark
                                  ? [AppColors.darkPrimary, Color(0xFF8C9EFF)]
                                  : AppColors.primaryGradient)
                              : (isDark
                                  ? [AppColors.darkSecondary, Color(0xFFFFE082)]
                                  : AppColors.secondaryGradient)),
                    )
                    : null,
            color:
                useGradient
                    ? null
                    : type == ButtonType.primary
                    ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                    : (isDark ? AppColors.darkSecondary : AppColors.secondary),
            boxShadow: [
              if (!isDark && onPressed != null)
                BoxShadow(
                  color: (type == ButtonType.primary
                          ? AppColors.primary
                          : AppColors.secondary)
                      .withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : onPressed,
              borderRadius: defaultRadius,
              child: Padding(
                padding: padding,
                child: Center(child: buttonChild),
              ),
            ),
          ),
        ),
      );
    }

    // For outline button
    if (type == ButtonType.outline) {
      return SizedBox(
        width: isFullWidth ? double.infinity : width,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: defaultRadius),
            side: BorderSide(
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
              width: 1.5,
            ),
            padding: padding,
          ),
          child: buttonChild,
        ),
      );
    }

    // For text button
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: defaultRadius),
          padding: padding,
        ),
        child: buttonChild,
      ),
    );
  }

  Color _getTextColor(bool isDark) {
    if (type == ButtonType.primary) {
      return isDark ? AppColors.darkBackground : AppColors.textWhite;
    } else if (type == ButtonType.secondary) {
      return isDark ? AppColors.darkBackground : AppColors.textDark;
    } else if (type == ButtonType.outline || type == ButtonType.text) {
      return isDark ? AppColors.darkPrimary : AppColors.primary;
    }
    return isDark ? AppColors.darkTextPrimary : AppColors.textDark;
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double height;
  final IconData? icon;
  final bool useGradient;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.width,
    this.height = 52.0,
    this.icon,
    this.useGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    return FancyButton(
      text: text,
      onPressed: onPressed,
      type: ButtonType.primary,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      width: width,
      height: height,
      icon: icon,
      useGradient: useGradient,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double height;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.width,
    this.height = 52.0,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FancyButton(
      text: text,
      onPressed: onPressed,
      type: ButtonType.secondary,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      width: width,
      height: height,
      icon: icon,
    );
  }
}

class OutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double height;
  final IconData? icon;

  const OutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.width,
    this.height = 52.0,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FancyButton(
      text: text,
      onPressed: onPressed,
      type: ButtonType.outline,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      width: width,
      height: height,
      icon: icon,
    );
  }
}
