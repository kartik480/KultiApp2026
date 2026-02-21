import 'package:flutter/material.dart';

enum HabitFrequency { daily, weekdays, custom }

class HabitModel {
  /// Fixed list of allowed icons (must match habit_edit_screen). Used so fromJson
  /// only returns constant IconData, which allows icon tree-shaking.
  static const List<IconData> _kAllowedIcons = [
    Icons.star_rounded,
    Icons.favorite_rounded,
    Icons.directions_run_rounded,
    Icons.book_rounded,
    Icons.water_drop_rounded,
    Icons.nightlight_rounded,
    Icons.self_improvement_rounded,
    Icons.coffee_rounded,
  ];
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final HabitFrequency frequency;
  final List<int> customDays;
  final List<String> completionDates;
  final int order;

  const HabitModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.frequency = HabitFrequency.daily,
    this.customDays = const [],
    this.completionDates = const [],
    this.order = 0,
  });

  HabitModel copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    HabitFrequency? frequency,
    List<int>? customDays,
    List<String>? completionDates,
    int? order,
  }) {
    return HabitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      frequency: frequency ?? this.frequency,
      customDays: customDays ?? this.customDays,
      completionDates: completionDates ?? this.completionDates,
      order: order ?? this.order,
    );
  }

  int get currentStreak {
    if (completionDates.isEmpty) return 0;
    final sorted = List<String>.from(completionDates)..sort();
    final today = _dateString(DateTime.now());
    if (!sorted.contains(today)) {
      final yesterday = _dateString(DateTime.now().subtract(const Duration(days: 1)));
      if (!sorted.contains(yesterday)) return 0;
    }
    int streak = 0;
    DateTime d = DateTime.now();
    while (sorted.contains(_dateString(d))) {
      streak++;
      d = d.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int get longestStreak {
    if (completionDates.isEmpty) return 0;
    final sorted = List<String>.from(completionDates)..sort();
    int maxStreak = 1;
    int current = 1;
    for (int i = 1; i < sorted.length; i++) {
      final prev = DateTime.parse(sorted[i - 1]);
      final curr = DateTime.parse(sorted[i]);
      final diff = curr.difference(prev).inDays;
      if (diff == 1) {
        current++;
        if (current > maxStreak) maxStreak = current;
      } else {
        current = 1;
      }
    }
    return maxStreak;
  }

  double completionRateLast(int days) {
    if (days <= 0) return 0;
    final target = frequency == HabitFrequency.daily
        ? days
        : frequency == HabitFrequency.weekdays
            ? _weekdaysInRange(days)
            : customDays.isEmpty ? days : (days * customDays.length / 7).round();
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days));
    int completed = 0;
    for (final d in completionDates) {
      try {
        final dt = DateTime.parse(d);
        if (!dt.isBefore(start) && !dt.isAfter(end)) completed++;
      } catch (_) {}
    }
    if (target == 0) return 0;
    return (completed / target).clamp(0.0, 1.0);
  }

  int _weekdaysInRange(int days) {
    int count = 0;
    final end = DateTime.now();
    for (int i = 0; i < days; i++) {
      final d = end.subtract(Duration(days: i));
      if (d.weekday >= DateTime.monday && d.weekday <= DateTime.friday) count++;
    }
    return count;
  }

  static String _todayString() => _dateString(DateTime.now());
  static String _dateString(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': icon.codePoint,
      'colorValue': color.toARGB32(),
      'frequency': frequency.index,
      'customDays': customDays,
      'completionDates': completionDates,
      'order': order,
    };
  }

  bool isCompletedOn(String dateStr) => completionDates.contains(dateStr);

  static IconData _iconForCodePoint(int? codePoint) {
    if (codePoint == null) return _kAllowedIcons[0];
    final idx = _kAllowedIcons.indexWhere((i) => i.codePoint == codePoint);
    return idx >= 0 ? _kAllowedIcons[idx] : _kAllowedIcons[0];
  }

  static HabitModel fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: _iconForCodePoint(json['iconCodePoint'] as int?),
      color: Color(json['colorValue'] as int? ?? 0xFF1B5E4A),
      frequency: HabitFrequency.values[json['frequency'] as int? ?? 0],
      customDays: (json['customDays'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
      completionDates: (json['completionDates'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      order: json['order'] as int? ?? 0,
    );
  }
}
