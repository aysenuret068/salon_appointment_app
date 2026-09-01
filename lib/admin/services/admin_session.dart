import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/admin_session_data.dart';

class AdminSession {
  AdminSession._();
  static const _storageKey = 'admin_session';
  static AdminSessionData? current;
  static bool get isAuthenticated => current?.isValid ?? false;

  static Future<void> restore() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(_storageKey);
    if (value == null) return;
    try {
      final restored = AdminSessionData.fromJson(jsonDecode(value));
      if (restored.isValid) {
        current = restored;
      } else {
        await clear();
      }
    } catch (_) {
      await clear();
    }
  }

  static Future<void> save(AdminSessionData session) async {
    if (!session.isValid) throw StateError('Invalid admin session.');
    current = session;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, jsonEncode(session.toJson()));
  }

  static Future<void> clear() async {
    current = null;
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey);
  }
}
