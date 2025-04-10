import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? profileImageUrl;
  final int currentStreak;
  final int longestStreak;
  final DateTime lastActive;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.lastActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      currentStreak: _parseIntValue(json['currentStreak']),
      longestStreak: _parseIntValue(json['longestStreak']),
      lastActive: _parseDateTime(json['lastActive']),
    );
  }

  // Helper method to safely parse int values
  static int _parseIntValue(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Helper method to safely parse DateTime from various formats
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();

    if (value is Timestamp) {
      return value.toDate();
    } else if (value is DateTime) {
      return value;
    } else if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    } else if (value is Map) {
      try {
        // Handle the case where Firebase might return a complex object
        return DateTime.now();
      } catch (e) {
        return DateTime.now();
      }
    }

    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActive': lastActive,
    };
  }

  // Create Firestore compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActive': FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? profileImageUrl,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}
