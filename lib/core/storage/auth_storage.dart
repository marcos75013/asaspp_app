import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _tokenKey = 'auth_token';
  static const _associationIdKey = 'active_association_id';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_associationIdKey);
  }
}