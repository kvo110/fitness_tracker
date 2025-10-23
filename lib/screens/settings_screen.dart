import 'package:flutter/material.dart';
import '../notifications/notification.dart';
import '../database/database_helper.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onToggleTheme;

  const SettingsScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Global notifications
  bool _notificationsEnabled = false;

  // Daily Workout
  bool _dailyWorkout = false;
  TimeOfDay _dailyWorkoutTime = const TimeOfDay(hour: 9, minute: 0);

  // Daily Calories
  bool _dailyCalories = false;
  TimeOfDay _dailyCaloriesTime = const TimeOfDay(hour: 20, minute: 0);

  // Weekly Summary
  bool _weeklySummary = false;
  // 1=Mon ... 7=Sun (default: Sunday)
  int _weeklyWeekday = DateTime.sunday;
  TimeOfDay _weeklyTime = const TimeOfDay(hour: 18, minute: 0);

  final _notifs = NotificationService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Settings',
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Theme toggle
          SwitchListTile(
            title: Text(widget.isDark ? 'Dark Mode Enabled' : 'Light Mode Enabled'),
            subtitle: Text(widget.isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode'),
            value: widget.isDark,
            onChanged: widget.onToggleTheme,
          ),

          const Divider(height: 32),

          // Notifications master switch
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive reminders & alerts'),
            value: _notificationsEnabled,
            onChanged: (v) async {
              setState(() => _notificationsEnabled = v);
              if (!v) {
                // Turn everything off if global is off
                setState(() {
                  _dailyWorkout = false;
                  _dailyCalories = false;
                  _weeklySummary = false;
                });
                await _notifs.cancelAll();
                _snack('Notifications disabled');
              } else {
                _snack('Notifications enabled');
              }
            },
          ),

          const SizedBox(height: 8),

          // Daily Workout Reminder
          _sectionCard(
            context: context,
            title: 'Daily Workout Reminder',
            enabled: _notificationsEnabled,
            trailing: Switch(
              value: _dailyWorkout && _notificationsEnabled,
              onChanged: !_notificationsEnabled
                  ? null
                  : (v) async {
                      setState(() => _dailyWorkout = v);
                      if (v) {
                        await _notifs.scheduleDaily(
                          id: NotificationService.idDailyWorkout,
                          time: _dailyWorkoutTime,
                          title: 'Time to work out!',
                          body: 'Stay consistent — your session awaits.',
                        );
                        _snack('Daily workout reminder set for ${_fmt(_dailyWorkoutTime)}');
                      } else {
                        await _notifs.cancel(NotificationService.idDailyWorkout);
                        _snack('Daily workout reminder off');
                      }
                    },
            ),
            children: [
              _timeRow(
                context: context,
                label: 'Reminder time',
                time: _dailyWorkoutTime,
                enabled: _notificationsEnabled && _dailyWorkout,
                onPick: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _dailyWorkoutTime,
                  );
                  if (picked != null) {
                    setState(() => _dailyWorkoutTime = picked);
                    if (_notificationsEnabled && _dailyWorkout) {
                      await _notifs.scheduleDaily(
                        id: NotificationService.idDailyWorkout,
                        time: picked,
                        title: 'Time to work out!',
                        body: 'Stay consistent — your session awaits.',
                      );
                      _snack('Rescheduled for ${_fmt(picked)}');
                    }
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Daily Calories Reminder
          _sectionCard(
            context: context,
            title: 'Daily Calorie Reminder',
            enabled: _notificationsEnabled,
            trailing: Switch(
              value: _dailyCalories && _notificationsEnabled,
              onChanged: !_notificationsEnabled
                  ? null
                  : (v) async {
                      setState(() => _dailyCalories = v);
                      if (v) {
                        await _notifs.scheduleDaily(
                          id: NotificationService.idDailyCalories,
                          time: _dailyCaloriesTime,
                          title: 'Log your calories',
                          body: 'Track your calorie intake for today.',
                        );
                        _snack('Daily calorie reminder set for ${_fmt(_dailyCaloriesTime)}');
                      } else {
                        await _notifs.cancel(NotificationService.idDailyCalories);
                        _snack('Daily calorie reminder off');
                      }
                    },
            ),
            children: [
              _timeRow(
                context: context,
                label: 'Reminder time',
                time: _dailyCaloriesTime,
                enabled: _notificationsEnabled && _dailyCalories,
                onPick: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _dailyCaloriesTime,
                  );
                  if (picked != null) {
                    setState(() => _dailyCaloriesTime = picked);
                    if (_notificationsEnabled && _dailyCalories) {
                      await _notifs.scheduleDaily(
                        id: NotificationService.idDailyCalories,
                        time: picked,
                        title: 'Log your calories',
                        body: 'Track your calorie intake for today.',
                      );
                      _snack('Rescheduled for ${_fmt(picked)}');
                    }
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Weekly Summary Reminder
          _sectionCard(
            context: context,
            title: 'Weekly Progress Summary',
            enabled: _notificationsEnabled,
            trailing: Switch(
              value: _weeklySummary && _notificationsEnabled,
              onChanged: !_notificationsEnabled
                  ? null
                  : (v) async {
                      setState(() => _weeklySummary = v);
                      if (v) {
                        await _notifs.scheduleWeekly(
                          id: NotificationService.idWeeklySummary,
                          weekday: _weeklyWeekday,
                          time: _weeklyTime,
                          title: 'Weekly summary ready',
                          body: 'Open Insights to review your week.',
                        );
                        _snack('Weekly summary set for ${_weekdayName(_weeklyWeekday)} @ ${_fmt(_weeklyTime)}');
                      } else {
                        await _notifs.cancel(NotificationService.idWeeklySummary);
                        _snack('Weekly summary off');
                      }
                    },
            ),
            children: [
              _weekdayPickerRow(
                context: context,
                current: _weeklyWeekday,
                enabled: _notificationsEnabled && _weeklySummary,
                onChanged: (val) async {
                  setState(() => _weeklyWeekday = val);
                  if (_notificationsEnabled && _weeklySummary) {
                    await _notifs.scheduleWeekly(
                      id: NotificationService.idWeeklySummary,
                      weekday: _weeklyWeekday,
                      time: _weeklyTime,
                      title: 'Weekly summary ready',
                      body: 'Open Insights to review your week.',
                    );
                    _snack('Rescheduled for ${_weekdayName(_weeklyWeekday)} @ ${_fmt(_weeklyTime)}');
                  }
                },
              ),
              const SizedBox(height: 8),
              _timeRow(
                context: context,
                label: 'Summary time',
                time: _weeklyTime,
                enabled: _notificationsEnabled && _weeklySummary,
                onPick: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _weeklyTime,
                  );
                  if (picked != null) {
                    setState(() => _weeklyTime = picked);
                    if (_notificationsEnabled && _weeklySummary) {
                      await _notifs.scheduleWeekly(
                        id: NotificationService.idWeeklySummary,
                        weekday: _weeklyWeekday,
                        time: picked,
                        title: 'Weekly summary ready',
                        body: 'Open Insights to review your week.',
                      );
                      _snack('Rescheduled for ${_weekdayName(_weeklyWeekday)} @ ${_fmt(picked)}');
                    }
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Data management (clear history)
          Text(
            'Data Management',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          _dataCard(
            context: context,
            children: [
              _dangerRow(
                context: context,
                title: 'Clear Workout History',
                subtitle: 'Remove all logged workouts',
                onPressed: () => _confirmClear(
                  context: context,
                  title: 'Clear Workout History?',
                  message: 'This will permanently delete all workout logs. Your saved workout plans will not be touched.',
                  onConfirm: () async {
                    final db = await DatabaseHelper.instance.database;
                    await db.delete(DatabaseHelper.instance.workoutsTable);
                    _snack('Workout history cleared');
                  },
                ),
              ),
              const Divider(height: 16),
              _dangerRow(
                context: context,
                title: 'Clear Calorie History',
                subtitle: 'Remove all calorie check-ins',
                onPressed: () => _confirmClear(
                  context: context,
                  title: 'Clear Calorie History?',
                  message: 'This will permanently delete all calorie entries. Workout plans will remain.',
                  onConfirm: () async {
                    final db = await DatabaseHelper.instance.database;
                    await db.delete(DatabaseHelper.instance.caloriesTable);
                    _snack('Calorie history cleared');
                  },
                ),
              ),
              const Divider(height: 16),
              _dangerRow(
                context: context,
                title: 'Clear All Data',
                subtitle: 'Delete workouts & calories (keeps plans)',
                onPressed: () => _confirmClear(
                  context: context,
                  title: 'Clear All Tracking Data?',
                  message: 'This will delete all workout logs and calorie entries. Your saved workout plans will be preserved.',
                  onConfirm: () async {
                    final db = await DatabaseHelper.instance.database;
                    await db.delete(DatabaseHelper.instance.workoutsTable);
                    await db.delete(DatabaseHelper.instance.caloriesTable);
                    _snack('All tracking data cleared');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Simple section card that disables content when parent switch is off
  Widget _sectionCard({
    required BuildContext context,
    required String title,
    required bool enabled,
    required Widget trailing,
    required List<Widget> children,
  }) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight ? Colors.white : Colors.grey[900];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isLight
                ? Colors.black.withOpacity(0.08)
                : Colors.white.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              trailing,
            ],
          ),
          const SizedBox(height: 8),
          Opacity(
            opacity: enabled ? 1.0 : 0.5,
            child: IgnorePointer(
              ignoring: !enabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Card container for the data management options
  Widget _dataCard({
    required BuildContext context,
    required List<Widget> children,
  }) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight ? Colors.white : Colors.grey[900];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isLight
                ? Colors.black.withOpacity(0.08)
                : Colors.white.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  // Destructive row item with confirm step
  Widget _dangerRow({
    required BuildContext context,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    final danger = Theme.of(context).colorScheme.error;
    final onSurf = Theme.of(context).colorScheme.onSurface;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: onSurf.withOpacity(0.75))),
            ],
          ),
        ),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: danger,
          ),
          child: const Text('Clear'),
        ),
      ],
    );
  }

  // Time row control
  Widget _timeRow({
    required BuildContext context,
    required String label,
    required TimeOfDay time,
    required bool enabled,
    required VoidCallback onPick,
  }) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          _fmt(time),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: enabled ? onPick : null,
          child: const Text('Pick Time'),
        ),
      ],
    );
  }

  // Weekday dropdown row
  Widget _weekdayPickerRow({
    required BuildContext context,
    required int current,
    required bool enabled,
    required ValueChanged<int> onChanged,
  }) {
    final days = <int, String>{
      DateTime.monday: 'Mon',
      DateTime.tuesday: 'Tue',
      DateTime.wednesday: 'Wed',
      DateTime.thursday: 'Thu',
      DateTime.friday: 'Fri',
      DateTime.saturday: 'Sat',
      DateTime.sunday: 'Sun',
    };
    return Row(
      children: [
        const Expanded(child: Text('Summary day')),
        DropdownButton<int>(
          value: current,
          onChanged: enabled ? (v) => onChanged(v ?? current) : null,
          items: days.entries
              .map((e) => DropdownMenuItem<int>(
                    value: e.key,
                    child: Text(e.value),
                  ))
              .toList(),
        ),
      ],
    );
  }

  // Confirm sheet for destructive actions
  Future<void> _confirmClear({
    required BuildContext context,
    required String title,
    required String message,
    required Future<void> Function() onConfirm,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(ctx, false),
            ),
            FilledButton.tonal(
              child: const Text('Confirm'),
              onPressed: () => Navigator.pop(ctx, true),
            ),
          ],
        );
      },
    );
    if (ok == true) {
      await onConfirm();
    }
  }

  String _fmt(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final ampm = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }

  String _weekdayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      default:
        return 'Sunday';
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }
}