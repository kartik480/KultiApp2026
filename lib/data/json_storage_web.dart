import 'package:shared_preferences/shared_preferences.dart';

const _key = 'kultiv_habits_json';

Future<String?> readJsonFile(String filename) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_key);
}

Future<void> writeJsonFile(String filename, String content) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_key, content);
}
