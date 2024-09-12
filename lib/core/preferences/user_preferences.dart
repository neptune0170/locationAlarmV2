import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserPreferences {
  static const _keyUserSession = 'user_session';

  static Future<void> saveUserSession(Map<String, dynamic> sessionData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserSession, jsonEncode(sessionData));
  }

  static Future<Map<String, dynamic>?> getUserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionJson = prefs.getString(_keyUserSession);

    if (sessionJson != null) {
      return jsonDecode(sessionJson);
    } else {
      return null;
    }
  }

  static Future<void> clearUserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserSession);
  }
}
