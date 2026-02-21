import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/habit_repository.dart';
import 'habit_edit_screen.dart';

class HabitsListScreen extends StatelessWidget {
  const HabitsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<HabitRepository>();
    final habits = repo.habits;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Habits'),
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
      body: habits.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.psychology_rounded,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Build your first habit',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Small steps every day lead to lasting change. Tap + to add a habit.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                    ),
                  ),
                  const SizedBox(height: 28),
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
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    child: ListTile(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HabitEditScreen(habitId: habit.id),
                        ),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: habit.color.withValues(alpha: 0.2),
                        child: Icon(habit.icon, color: habit.color, size: 22),
                      ),
                      title: Text(habit.name),
                      subtitle: Text(
                        'Streak: ${habit.currentStreak} · Best: ${habit.longestStreak}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: habits.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HabitEditScreen()),
              ),
              child: const Icon(Icons.add_rounded),
            )
          : null,
    );
  }
}
