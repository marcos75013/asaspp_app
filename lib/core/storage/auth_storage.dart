import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _secureStorage = FlutterSecureStorage();
  static const _sessionKey = 'mobile_auth_session';
  static const _tokenKey = 'auth_token';
  static const _associationIdKey = 'active_association_id';

  Future<void> saveSession(String token, String? refreshToken) async {
    await _secureStorage.write(
      key: _sessionKey,
      value: jsonEncode({'token': token, 'refreshToken': refreshToken}),
    );
  }

  Future<({String? token, String? refreshToken})> getSession() async {
    final stored = await _secureStorage.read(key: _sessionKey);
    if (stored == null) {
      final prefs = await SharedPreferences.getInstance();
      return (token: prefs.getString(_tokenKey), refreshToken: null);
    }
    final json = jsonDecode(stored) as Map<String, dynamic>;
    return (
      token: json['token'] as String?,
      refreshToken: json['refreshToken'] as String?,
    );
  }

  Future<void> saveActiveAssociationId(int associationId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_associationIdKey, associationId);
  }

  Future<int?> getActiveAssociationId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_associationIdKey);
  }

  Future<void> clear() async {
    await _secureStorage.delete(key: _sessionKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_associationIdKey);
  }
}
