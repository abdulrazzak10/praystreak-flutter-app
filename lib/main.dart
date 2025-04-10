import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'constants/theme_constants.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'services/prayer_service.dart';
import 'utils/routes.dart';

bool isDarkMode = false;

// Error widget to display when Flutter encounters an error
class ErrorScreen extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const ErrorScreen({super.key, required this.errorDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red[800]),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'The app encountered an unexpected error.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => SystemNavigator.pop(),
                child: const Text('Close App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> main() async {
  // Override the error widget
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return ErrorScreen(errorDetails: details);
  };

  // Handle errors during initialization using runZonedGuarded
  runZonedGuarded<Future<void>>(
    () async {
      // Ensure Flutter binding is initialized
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize shared preferences
      final prefs = await SharedPreferences.getInstance();
      isDarkMode = prefs.getBool('darkMode') ?? false;

      // Run the app
      runApp(const MyApp());
    },
    (error, stack) {
      print('Caught error in runZonedGuarded: $error');
      print(stack);
    },
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Create providers list
    final List<SingleChildWidget> providers = [];

    // Add AuthService provider
    final authService = AuthService();
    providers.add(
      ChangeNotifierProvider<AuthService>.value(value: authService),
    );

    // Add PrayerService provider (depends on AuthService)
    providers.add(
      ChangeNotifierProvider<PrayerService>(
        create: (_) => PrayerService(authService),
      ),
    );

    // Add the theme provider
    providers.add(
      ChangeNotifierProvider<ThemeProvider>(
        create: (_) => ThemeProvider(isDarkMode),
      ),
    );

    return MultiProvider(
      providers: providers,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Praystreak',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: (settings) {
              // Special case for home route - check authentication
              if (settings.name == '/home') {
                return MaterialPageRoute(
                  builder: (context) {
                    // Check authentication with AuthService
                    final authService = Provider.of<AuthService>(context);

                    // If not authenticated, redirect to login
                    if (!authService.isLoggedIn) {
                      return const LoginScreen();
                    }

                    // User is authenticated, go to home
                    return const HomeScreen();
                  },
                );
              }

              // Use the routes from AppRoutes
              return MaterialPageRoute(
                builder: (context) {
                  // Catch all route handler with proper context for providers
                  final routes = AppRoutes.getRoutes();
                  final builder = routes[settings.name];
                  if (builder != null) {
                    return builder(context);
                  }
                  return const SplashScreen();
                },
              );
            },
            routes: {}, // We're using onGenerateRoute for all routes
            supportedLocales: const [Locale('en', 'US'), Locale('ar', 'SA')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode;

  ThemeProvider(bool isDark)
    : _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

    // Save theme preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', isDarkMode);

    notifyListeners();
  }
}
