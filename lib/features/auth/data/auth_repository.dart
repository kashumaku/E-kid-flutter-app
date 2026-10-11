import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../domain/models/user_profile.dart';

abstract class IAuthRepository {
  Future<UserProfile?> getCurrentUser();
  Future<UserProfile> signIn({
    required String phoneNumber,
    required String password,
  });
  Future<UserProfile> signUp({
    required String fullName,
    required String phoneNumber,
    required String password,
  });
  Future<UserProfile> updateProfile({
    required String fullName,
    required String phoneNumber,
  });
  Future<void> signOut();
}

class AuthRepository implements IAuthRepository {
  final SharedPreferences _prefs;
  final Uuid _uuid = const Uuid();

  static const String _keyCurrentUser = 'apex_task_current_user';
  static const String _keyUsersDb = 'apex_task_users_db';

  AuthRepository(this._prefs) {
    _seedDefaultUserIfEmpty();
  }

  void _seedDefaultUserIfEmpty() {
    final existingUsers = _prefs.getString(_keyUsersDb);
    if (existingUsers == null || existingUsers.isEmpty) {
      // Seed default demo profile matching mockup ("Linda C. Ng")
      final defaultUser = {
        'id': 'user-linda-default',
        'fullName': 'Linda C. Ng',
        'phoneNumber': '+1 555 0199',
        'password': 'password123',
        'createdAt': DateTime.now().toIso8601String(),
      };
      _prefs.setString(_keyUsersDb, jsonEncode([defaultUser]));
    }
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    final raw = _prefs.getString(_keyCurrentUser);
    if (raw == null || raw.isEmpty) return null;
    try {
      return UserProfile.fromJson(raw);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserProfile> signIn({
    required String phoneNumber,
    required String password,
  }) async {
    final cleanPhone = _normalizePhone(phoneNumber);
    final usersList = _getStoredUsers();

    final userMap = usersList.firstWhere(
      (u) => _normalizePhone(u['phoneNumber'] as String? ?? '') == cleanPhone,
      orElse: () => {},
    );

    if (userMap.isEmpty) {
      throw Exception('No account found with this phone number. Please sign up.');
    }

    if (userMap['password'] != password) {
      throw Exception('Incorrect password. Please try again.');
    }

    final profile = UserProfile.fromMap(userMap);
    await _prefs.setString(_keyCurrentUser, profile.toJson());
    return profile;
  }

  @override
  Future<UserProfile> signUp({
    required String fullName,
    required String phoneNumber,
    required String password,
  }) async {
    final cleanPhone = _normalizePhone(phoneNumber);
    final usersList = _getStoredUsers();

    final exists = usersList.any(
      (u) => _normalizePhone(u['phoneNumber'] as String? ?? '') == cleanPhone,
    );

    if (exists) {
      throw Exception('An account with this phone number already exists. Please sign in.');
    }

    final newUserData = {
      'id': _uuid.v4(),
      'fullName': fullName.trim(),
      'phoneNumber': phoneNumber.trim(),
      'password': password,
      'createdAt': DateTime.now().toIso8601String(),
    };

    usersList.add(newUserData);
    await _prefs.setString(_keyUsersDb, jsonEncode(usersList));

    final profile = UserProfile.fromMap(newUserData);
    await _prefs.setString(_keyCurrentUser, profile.toJson());
    return profile;
  }

  @override
  Future<UserProfile> updateProfile({
    required String fullName,
    required String phoneNumber,
  }) async {
    final current = await getCurrentUser();
    if (current == null) {
      throw Exception('No active user logged in');
    }
    final usersList = _getStoredUsers();
    final updatedList = usersList.map((u) {
      if (u['id'] == current.id) {
        return {
          ...u,
          'fullName': fullName.trim(),
          'phoneNumber': phoneNumber.trim(),
        };
      }
      return u;
    }).toList();
    await _prefs.setString(_keyUsersDb, jsonEncode(updatedList));

    final updatedProfile = current.copyWith(
      fullName: fullName.trim(),
      phoneNumber: phoneNumber.trim(),
    );
    await _prefs.setString(_keyCurrentUser, updatedProfile.toJson());
    return updatedProfile;
  }

  @override
  Future<void> signOut() async {
    await _prefs.remove(_keyCurrentUser);
  }

  List<Map<String, dynamic>> _getStoredUsers() {
    final raw = _prefs.getString(_keyUsersDb);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }
}
