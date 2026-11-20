
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentModeService {
  static final ValueNotifier<bool> isEnabled =
  ValueNotifier<bool>(true);

  static const String _preferenceKey = 'mindmate_student_mode';

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    isEnabled.value = prefs.getBool(_preferenceKey) ?? true;
  }

  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_preferenceKey, value);

    isEnabled.value = value;
  }
}
