import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../data/habit_model.dart';
import '../data/habit_repository.dart';
import 'habit_edit_screen.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static bool _habitDueToday(HabitModel h, DateTime today) {
    switch (h.frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.weekdays:
        return today.weekday >= DateTime.monday && today.weekday <= DateTime.friday;
      case HabitFrequency.custom:
        return h.customDays.isEmpty || h.customDays.contains(today.weekday);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<HabitRepository>();
    final today = DateTime.now();
    final todayStr = _dateKey(today);
    final dueHabits = repo.habits.where((h) => _habitDueToday(h, today)).toList();
    final completedCount = dueHabits.where((h) => h.isCompletedOn(todayStr)).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HabitEditScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, MMMM d').format(today),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    if (dueHabits.isNotEmpty)
                      Text(
                        '$completedCount of ${dueHabits.length} habits done',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                      ),
                  ],
                ),
              ),
            ),
            if (dueHabits.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.eco_rounded,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No habits for today',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add a habit and set its schedule',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HabitEditScreen()),
                        ),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add habit'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final habit = dueHabits[index];
                      final done = habit.isCompletedOn(todayStr);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _HabitCheckCard(
                          habit: habit,
                          done: done,
                          onTap: () => repo.toggleCompletion(habit.id, todayStr),
                          onEdit: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HabitEditScreen(habitId: habit.id),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: dueHabits.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HabitCheckCard extends StatelessWidget {
  const _HabitCheckCard({
    required this.habit,
    required this.done,
    required this.onTap,
    required this.onEdit,
  });

  final HabitModel habit;
  final bool done;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        onLongPress: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: done ? habit.color : Colors.transparent,
                  border: Border.all(color: habit.color, width: 2),
                  shape: BoxShape.circle,
                ),
                child: done
                    ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            decoration: done ? TextDecoration.lineThrough : null,
                            color: done
                                ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)
                                : null,
                          ),
                    ),
                    if (habit.currentStreak > 0)
                      Text(
                        '${habit.currentStreak} day streak',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                  ],
                ),
              ),
              Icon(
                habit.icon,
                color: habit.color.withValues(alpha: done ? 0.6 : 1),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
