import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';

class GradientContainer extends StatelessWidget {
  final Widget child;
  final List<Color>? gradient;
  final BorderRadius? borderRadius;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxShadow? shadow;
  final bool useDefaultShadow;
  final Alignment begin;
  final Alignment end;

  const GradientContainer({
    super.key,
    required this.child,
    this.gradient,
    this.borderRadius,
    this.height,
    this.width,
    this.padding,
    this.margin,
    this.shadow,
    this.useDefaultShadow = true,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: height,
      width: width,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors:
              gradient ??
              (isDark ? AppColors.darkGradient : AppColors.lightGradient),
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        boxShadow:
            useDefaultShadow
                ? [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                ]
                : shadow != null
                ? [shadow!]
                : null,
      ),
      child: child,
    );
  }
}

class PrimaryGradientContainer extends GradientContainer {
  PrimaryGradientContainer({
    super.key,
    required super.child,
    super.borderRadius,
    super.height,
    super.width,
    super.padding,
    super.margin,
    super.useDefaultShadow = true,
  }) : super(gradient: AppColors.primaryGradient);
}

class SecondaryGradientContainer extends GradientContainer {
  SecondaryGradientContainer({
    super.key,
    required super.child,
    super.borderRadius,
    super.height,
    super.width,
    super.padding,
    super.margin,
    super.useDefaultShadow = true,
  }) : super(gradient: AppColors.secondaryGradient);
}
