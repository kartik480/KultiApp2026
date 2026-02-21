import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'habit_model.dart';
import 'json_storage_io.dart' if (dart.library.html) 'json_storage_web.dart' as storage;

const _fileName = 'habits.json';
const _oldPrefsKey = 'kultiv_habits';

class HabitRepository extends ChangeNotifier {
  final List<HabitModel> _habits = [];

  List<HabitModel> get habits => List.unmodifiable(_habits);

  Future<void> load() async {
    try {
      final raw = await storage.readJsonFile(_fileName);
      if (raw != null && raw.isNotEmpty) {
        _parseAndApply(raw);
        notifyListeners();
        return;
      }
      // Migrate from old SharedPreferences key if we had data there
      final prefs = await SharedPreferences.getInstance();
      final oldRaw = prefs.getString(_oldPrefsKey);
      if (oldRaw != null && oldRaw.isNotEmpty) {
        _parseAndApply(oldRaw);
        await _save();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('HabitRepository: load error: $e');
    }
    notifyListeners();
  }

  void _parseAndApply(String raw) {
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final parsed = <HabitModel>[];
      for (final e in list) {
        parsed.add(HabitModel.fromJson(e as Map<String, dynamic>));
      }
      parsed.sort((a, b) => a.order.compareTo(b.order));
      _habits
        ..clear()
        ..addAll(parsed);
    } catch (e) {
      if (kDebugMode) debugPrint('HabitRepository: parse error: $e');
      // Do not clear _habits on parse error so we don't lose in-memory data
    }
  }

  Future<void> _save() async {
    final list = _habits.map((h) => h.toJson()).toList();
    final json = const JsonEncoder.withIndent('  ').convert(list);
    try {
      await storage.writeJsonFile(_fileName, json);
    } catch (e) {
      if (kDebugMode) debugPrint('HabitRepository: save error: $e');
    }
    notifyListeners();
  }

  /// Call when app goes to background so data is persisted even if the app is closed.
  Future<void> persist() => _save();

  Future<void> addHabit(HabitModel habit) async {
    final id = habit.id.isEmpty ? const Uuid().v4() : habit.id;
    final order = _habits.isEmpty ? 0 : _habits.map((h) => h.order).reduce((a, b) => a > b ? a : b) + 1;
    _habits.add(habit.copyWith(id: id, order: order));
    await _save();
  }

  Future<void> updateHabit(HabitModel habit) async {
    final i = _habits.indexWhere((h) => h.id == habit.id);
    if (i >= 0) {
      _habits[i] = habit;
      await _save();
    }
  }

  Future<void> deleteHabit(String id) async {
    _habits.removeWhere((h) => h.id == id);
    await _save();
  }

  Future<void> toggleCompletion(String habitId, String date) async {
    final i = _habits.indexWhere((h) => h.id == habitId);
    if (i < 0) return;
    final h = _habits[i];
    final dates = List<String>.from(h.completionDates);
    if (dates.contains(date)) {
      dates.remove(date);
    } else {
      dates.add(date);
      dates.sort();
    }
    _habits[i] = h.copyWith(completionDates: dates);
    await _save();
  }

  HabitModel? getHabit(String id) {
    try {
      return _habits.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || newIndex < 0 || oldIndex >= _habits.length || newIndex >= _habits.length) return;
    final item = _habits.removeAt(oldIndex);
    _habits.insert(newIndex, item);
    for (int i = 0; i < _habits.length; i++) {
      _habits[i] = _habits[i].copyWith(order: i);
    }
    await _save();
  }
}
