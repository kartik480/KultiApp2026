import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/habit_model.dart';
import '../data/habit_repository.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<HabitRepository>();
    final habits = repo.habits;

    if (habits.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Stats')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bar_chart_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'Complete habits to see stats',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Section(
            title: 'Last 7 days',
            child: SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 1,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                          final i = value.toInt();
                          if (i >= 0 && i < 7) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(days[i], style: const TextStyle(fontSize: 12)),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 24,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) => Text(
                          value == 1 ? '100%' : '${(value * 100).toInt()}%',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (v) => FlLine(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(7, (i) {
                    final d = DateTime.now().subtract(Duration(days: 6 - i));
                    final avg = habits.isEmpty ? 0.0 : _avgCompletionForDay(habits, d);
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: avg,
                          color: Theme.of(context).colorScheme.primary,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                      showingTooltipIndicators: [],
                    );
                  }),
                ),
                swapAnimationDuration: const Duration(milliseconds: 300),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _Section(
            title: 'Streaks',
            child: Column(
              children: habits.map((h) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: h.color.withValues(alpha: 0.2),
                        child: Icon(h.icon, color: h.color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(h.name, style: Theme.of(context).textTheme.titleSmall),
                            Text(
                              'Current: ${h.currentStreak} · Best: ${h.longestStreak}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${h.currentStreak} day',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          _Section(
            title: 'Completion (7 days)',
            child: Column(
              children: habits.map((h) {
                final rate = h.completionRateLast(7);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          h.name,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: rate,
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(h.color),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(rate * 100).toInt()}%',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  static double _avgCompletionForDay(List<HabitModel> habits, DateTime day) {
    if (habits.isEmpty) return 0;
    int done = 0;
    int total = 0;
    final dateStr = _dateKey(day);
    for (final h in habits) {
      if (_habitDueOn(h, day)) {
        total++;
        if (h.isCompletedOn(dateStr)) done++;
      }
    }
    return total == 0 ? 0 : done / total;
  }

  static bool _habitDueOn(HabitModel h, DateTime day) {
    switch (h.frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.weekdays:
        return day.weekday >= DateTime.monday && day.weekday <= DateTime.friday;
      case HabitFrequency.custom:
        return h.customDays.isEmpty || h.customDays.contains(day.weekday);
    }
  }

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
