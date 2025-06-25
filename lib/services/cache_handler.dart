import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheHandler {
  static const String _keyToken = 'token';
  static const String _keyUserProfile = 'user_profile';

  /// Salva dati utente e token nello storage locale.
  static Future<void> saveUserData(String token, Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUserProfile, jsonEncode(userData));
  }

  static Future<void> updateUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserProfile, jsonEncode(userData));
  }

  /// Restituisce il token salvato.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// Restituisce l'oggetto utente salvato.
  static Future<Map<String, dynamic>?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyUserProfile);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  /// Cancella dati salvati.
  static Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserProfile);
  }
}