import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A simplified AuthService that provides UI-only functionality with passwordless login
class AuthService extends ChangeNotifier {
  // Mock user object
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isLoggedIn = false;

  // Stream controller for auth state changes
  final _authStateController = StreamController<bool>.broadcast();

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  Stream<bool> get authStateChanges => _authStateController.stream;

  // Constructor
  AuthService() {
    // Check if user is logged in from shared preferences
    _checkLoginStatus();
  }

  // Check login status from shared preferences
  Future<void> _checkLoginStatus() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (isLoggedIn) {
        final userId = prefs.getString('userId') ?? 'user_123';
        final userEmail = prefs.getString('userEmail') ?? 'user@example.com';
        final userName = prefs.getString('userName') ?? 'User';

        _currentUser = UserModel(
          uid: userId,
          email: userEmail,
          name: userName,
          lastActive: DateTime.now(),
        );
        _isLoggedIn = true;
        _authStateController.add(true);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error checking login status: $e');
    }
  }

  // Passwordless sign in with email
  Future<bool> signInWithEmail(String email) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Create a mock user
      _currentUser = UserModel(
        uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: email.split('@')[0],
        lastActive: DateTime.now(),
      );

      // Save login status
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userId', _currentUser!.uid);
      await prefs.setString('userEmail', email);
      await prefs.setString('userName', _currentUser!.name);
      await prefs.setString('lastSignInTime', DateTime.now().toString());

      _isLoggedIn = true;
      _authStateController.add(true);

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error signing in: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Clear user data
      _currentUser = null;
      _isLoggedIn = false;

      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('userId');
      await prefs.remove('userEmail');
      await prefs.remove('userName');

      _authStateController.add(false);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error signing out: $e');
    }
  }

  // Get user data
  Future<UserModel?> getUserData(String uid) async {
    // Just return the current user for UI purposes
    return _currentUser;
  }

  // Update user profile - UI only
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Update the current user with new data
      if (_currentUser != null) {
        _currentUser = UserModel(
          uid: _currentUser!.uid,
          email: data['email'] ?? _currentUser!.email,
          name: data['name'] ?? _currentUser!.name,
          lastActive: DateTime.now(),
          profileImageUrl:
              data['profileImageUrl'] ?? _currentUser!.profileImageUrl,
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error updating profile: $e');
    }
  }

  // Dispose
  @override
  void dispose() {
    _authStateController.close();
    super.dispose();
  }
}
