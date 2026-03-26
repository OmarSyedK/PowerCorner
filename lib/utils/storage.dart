import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static Future<bool> isOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('pc_onboarded') ?? false;
  }

  static Future<void> setOnboarded(String goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pc_onboarded', true);
    await prefs.setString('pc_goal', goal);
  }

  static Future<void> clearOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pc_onboarded');
    await prefs.remove('pc_goal');
  }

  static Future<List<double>> getWeightLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('pc_weights');
    if (raw == null) return [73.8, 73.2, 72.8, 72.4];
    final List decoded = jsonDecode(raw);
    return decoded.map((e) => (e as num).toDouble()).toList();
  }

  static Future<void> saveWeightLogs(List<double> logs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pc_weights', jsonEncode(logs));
  }

  static Future<Map<String, bool>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('pc_settings');
    if (raw == null) {
      return {'notifications': true, 'audio': true, 'offline': false};
    }
    final Map decoded = jsonDecode(raw);
    return decoded.map((k, v) => MapEntry(k.toString(), v as bool));
  }

  static Future<void> saveSettings(Map<String, bool> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pc_settings', jsonEncode(settings));
  }
}
