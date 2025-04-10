import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/prayer_tracking_screen.dart';
import '../screens/streaks_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String prayerTracking = '/prayer-tracking';
  static const String streaks = '/streaks';

  // Route map
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (_) => const SplashScreen(),
      onboarding: (_) => const OnboardingScreen(),
      login: (_) => const LoginScreen(),
      signup: (_) => const SignupScreen(),
      home: (_) => const HomeScreen(),
      profile: (_) => const ProfileScreen(),
      streaks: (_) => const StreaksScreen(),
      // Note: prayer tracking needs userId, so it's not included in the routes map
    };
  }
}
