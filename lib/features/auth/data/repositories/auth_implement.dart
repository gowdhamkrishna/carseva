import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carseva/core/auth/local_user.dart';
import 'package:carseva/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const _usersKey = 'registered_users';
  static const _currentUserKey = 'current_user';

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  @override
  Future<LocalUser?> register(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    final users = usersJson != null
        ? Map<String, dynamic>.from(jsonDecode(usersJson))
        : <String, dynamic>{};

    if (users.containsKey(email)) {
      return null; // User already exists
    }

    final uid = DateTime.now().millisecondsSinceEpoch.toString();
    final user = LocalUser(
      uid: uid,
      email: email,
      displayName: email.split('@').first,
    );

    users[email] = {
      'passwordHash': _hashPassword(password),
      'user': user.toJson(),
    };

    await prefs.setString(_usersKey, jsonEncode(users));
    await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));

    return user;
  }

  @override
  Future<LocalUser?> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null) return null;

    final users = Map<String, dynamic>.from(jsonDecode(usersJson));
    final userData = users[email];
    if (userData == null) return null;

    final storedHash = userData['passwordHash'] as String;
    if (storedHash != _hashPassword(password)) return null;

    final user = LocalUser.fromJson(Map<String, dynamic>.from(userData['user']));
    await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));

    return user;
  }

  @override
  Future<LocalUser?> googleLogin() async {
    try {
      final googleSignIn = GoogleSignIn(scopes: ['email']);
      final account = await googleSignIn.signIn();

      if (account == null) return null; // User cancelled

      final user = LocalUser(
        uid: account.id,
        email: account.email,
        displayName: account.displayName ?? account.email.split('@').first,
        photoUrl: account.photoUrl,
      );

      // Save session locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));

      return user;
    } catch (e) {
      print('❌ Google Sign-In error: $e');
      return null;
    }
  }

  /// Get the currently logged-in user from local storage.
  static Future<LocalUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    if (userJson == null) return null;
    return LocalUser.fromJson(Map<String, dynamic>.from(jsonDecode(userJson)));
  }

  /// Log out the current user.
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);

    // Also sign out from Google if applicable
    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    } catch (_) {}
  }
}
