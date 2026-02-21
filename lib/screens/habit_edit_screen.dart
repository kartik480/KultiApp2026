import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/habit_model.dart';
import '../data/habit_repository.dart';

class HabitEditScreen extends StatefulWidget {
  const HabitEditScreen({super.key, this.habitId});

  final String? habitId;

  @override
  State<HabitEditScreen> createState() => _HabitEditScreenState();
}

class _HabitEditScreenState extends State<HabitEditScreen> {
  final _nameController = TextEditingController();
  static const _icons = [
    Icons.star_rounded,
    Icons.favorite_rounded,
    Icons.directions_run_rounded,
    Icons.book_rounded,
    Icons.water_drop_rounded,
    Icons.nightlight_rounded,
    Icons.self_improvement_rounded,
    Icons.coffee_rounded,
  ];
  static const _colors = [
    Color(0xFF1B5E4A),
    Color(0xFF2563EB),
    Color(0xFFDC2626),
    Color(0xFFE8A838),
    Color(0xFF7C3AED),
    Color(0xFF0891B2),
    Color(0xFF65A30D),
    Color(0xFFEA580C),
  ];
  int _selectedIconIndex = 0;
  int _selectedColorIndex = 0;
  HabitFrequency _frequency = HabitFrequency.daily;
  List<int> _customDays = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHabit());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _loadHabit() {
    if (widget.habitId == null) return;
    final repo = context.read<HabitRepository>();
    final h = repo.getHabit(widget.habitId!);
    if (h != null) {
      _nameController.text = h.name;
      final iconIdx = _icons.indexOf(h.icon);
      _selectedIconIndex = iconIdx >= 0 ? iconIdx : 0;
      final colorIdx = _colors.indexOf(h.color);
      _selectedColorIndex = colorIdx >= 0 ? colorIdx : 0;
      _frequency = h.frequency;
      _customDays = List.from(h.customDays);
      setState(() {});
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a habit name')),
      );
      return;
    }
    final repo = context.read<HabitRepository>();
    final habit = HabitModel(
      id: widget.habitId ?? '',
      name: name,
      icon: _icons[_selectedIconIndex],
      color: _colors[_selectedColorIndex],
      frequency: _frequency,
      customDays: _frequency == HabitFrequency.custom ? _customDays : [],
      completionDates: widget.habitId != null ? (repo.getHabit(widget.habitId!)?.completionDates ?? []) : [],
      order: widget.habitId != null ? (repo.getHabit(widget.habitId!)?.order ?? 0) : 0,
    );
    if (widget.habitId != null) {
      await repo.updateHabit(habit);
    } else {
      await repo.addHabit(habit);
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete habit?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true && widget.habitId != null && mounted) {
      await context.read<HabitRepository>().deleteHabit(widget.habitId!);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.habitId != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit habit' : 'New habit'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _delete,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Habit name',
              hintText: 'e.g. Morning run',
            ),
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 24),
          Text('Icon', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(_icons.length, (i) {
              final selected = i == _selectedIconIndex;
              return Material(
                color: selected
                    ? _colors[_selectedColorIndex].withValues(alpha: 0.2)
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => setState(() => _selectedIconIndex = i),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      _icons[i],
                      color: selected ? _colors[_selectedColorIndex] : Theme.of(context).colorScheme.onSurface,
                      size: 28,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          Text('Color', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(_colors.length, (i) {
              final selected = i == _selectedColorIndex;
              return Material(
                shape: CircleBorder(side: BorderSide(width: selected ? 3 : 0, color: _colors[i])),
                color: _colors[i],
                child: InkWell(
                  onTap: () => setState(() => _selectedColorIndex = i),
                  customBorder: const CircleBorder(),
                  child: const SizedBox(width: 44, height: 44),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          Text('Frequency', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<HabitFrequency>(
            segments: const [
              ButtonSegment(value: HabitFrequency.daily, label: Text('Daily'), icon: Icon(Icons.today_rounded)),
              ButtonSegment(value: HabitFrequency.weekdays, label: Text('Weekdays'), icon: Icon(Icons.work_rounded)),
              ButtonSegment(value: HabitFrequency.custom, label: Text('Custom'), icon: Icon(Icons.tune_rounded)),
            ],
            selected: {_frequency},
            onSelectionChanged: (s) => setState(() => _frequency = s.first),
          ),
          if (_frequency == HabitFrequency.custom) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(7, (i) {
                final day = i + 1;
                final selected = _customDays.contains(day);
                final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                return FilterChip(
                  label: Text(labels[i]),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _customDays.add(day);
                      } else {
                        _customDays.remove(day);
                      }
                      _customDays.sort();
                    });
                  },
                );
              }),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _save,
            child: Text(isEditing ? 'Save' : 'Add habit'),
          ),
        ),
      ),
    );
  }
}
