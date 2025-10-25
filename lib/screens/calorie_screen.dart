import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../utils/date_time_formatter.dart';

class CalorieScreen extends StatefulWidget {
  const CalorieScreen({super.key});

  @override
  State<CalorieScreen> createState() => _CalorieScreenState();
}

class _CalorieScreenState extends State<CalorieScreen> {
  final TextEditingController _calCtrl = TextEditingController();
  final List<Map<String, dynamic>> _entries = [];
  DateTime? _selectedDateTime;
  int _totalCalories = 0;

  @override
  void initState() {
    super.initState();
    _loadCalories();
  }

  Future<void> _loadCalories() async {
    try {
      final rows = await DatabaseHelper.instance.getAllCalories();
      setState(() {
        _entries
          ..clear()
          ..addAll(rows);
        _totalCalories = rows.fold<int>(
          0,
          (sum, r) => sum + (r['calories'] as num).toInt(),
        );
      });
    } catch (e) {
      debugPrint('Load calories error: $e');
      _snack('Could not load entries.');
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _addEntry() async {
    final cal = int.tryParse(_calCtrl.text.trim()) ?? 0;
    if (cal <= 0) {
      _snack('Enter a valid calorie number.');
      return;
    }
    if (_selectedDateTime == null) {
      _snack('Please pick a date & time.');
      return;
    }

    final row = {
      'calories': cal,
      'date_time': _selectedDateTime!.toIso8601String(),
    };

    try {
      final id = await DatabaseHelper.instance.insertCalories(row);
      setState(() {
        _entries.insert(0, {'id': id, ...row});
        _totalCalories += cal;
        _calCtrl.clear();
        _selectedDateTime = null;
      });
      _snack('Check-in saved.');
    } catch (e) {
      debugPrint('Insert calorie error: $e');
      _snack('Could not save. Try again.');
    }
  }

  Future<void> _deleteEntry(int index) async {
    final entry = _entries[index];
    final id = entry['id'] as int?;
    final cal = (entry['calories'] as num).toInt();

    if (id == null) {
      setState(() {
        _entries.removeAt(index);
        _totalCalories -= cal;
      });
      return;
    }

    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete(
        DatabaseHelper.instance.caloriesTable,
        where: 'id = ?',
        whereArgs: [id],
      );
      setState(() {
        _entries.removeAt(index);
        _totalCalories -= cal;
      });
    } catch (e) {
      debugPrint('Delete calorie error: $e');
      _snack('Could not delete. Try again.');
    }
  }

  Future<void> _editEntry(int index) async {
    final entry = _entries[index];
    final int? id = entry['id'] as int?;
    if (id == null) {
      _snack('Cannot edit this entry.');
      return;
    }

    final calController = TextEditingController(text: '${entry['calories']}');
    DateTime currentDateTime =
        DateTime.tryParse(entry['date_time'].toString()) ?? DateTime.now();

    Future<void> pickNewDateTime() async {
      final date = await showDatePicker(
        context: context,
        initialDate: currentDateTime,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (date == null) return;

      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(currentDateTime),
      );
      if (time == null) return;

      currentDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      setState(() {}); // refresh dialog label
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: const Text('Edit Check-In'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: calController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Calories',
                      prefixIcon: Icon(Icons.local_fire_department),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(DateTimeFormatter.format(currentDateTime)),
                      ),
                      TextButton(
                        onPressed: () async {
                          // local pick to avoid closing dialog
                          final date = await showDatePicker(
                            context: context,
                            initialDate: currentDateTime,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date == null) return;

                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                              currentDateTime,
                            ),
                          );
                          if (time == null) return;

                          setLocal(() {
                            currentDateTime = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        },
                        child: const Text('Pick Date/Time'),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newCal = int.tryParse(calController.text.trim()) ?? 0;
                    if (newCal <= 0) {
                      _snack('Enter a valid number.');
                      return;
                    }
                    try {
                      final db = await DatabaseHelper.instance.database;
                      await db.update(
                        DatabaseHelper.instance.caloriesTable,
                        {
                          'calories': newCal,
                          'date_time': currentDateTime.toIso8601String(),
                        },
                        where: 'id = ?',
                        whereArgs: [id],
                      );

                      // Update local list + total
                      final oldCal = (entry['calories'] as num).toInt();
                      setState(() {
                        _entries[index]['calories'] = newCal;
                        _entries[index]['date_time'] = currentDateTime
                            .toIso8601String();
                        _totalCalories += (newCal - oldCal);
                      });
                      if (context.mounted) Navigator.pop(context);
                      _snack('Entry updated.');
                    } catch (e) {
                      debugPrint('Update calorie error: $e');
                      _snack('Could not update. Try again.');
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgColor = isLight ? Colors.white : Colors.grey[850];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          Text(
            'Calorie Check-Ins',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _calCtrl,
            decoration: const InputDecoration(
              labelText: 'Calories',
              prefixIcon: Icon(Icons.local_fire_department),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDateTime == null
                        ? 'No Date/Time Selected'
                        : DateTimeFormatter.format(_selectedDateTime!),
                  ),
                ),
                ElevatedButton(
                  onPressed: _pickDateTime,
                  child: const Text('Pick Date/Time'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _addEntry,
            icon: const Icon(Icons.add),
            label: const Text('Add Check-In'),
          ),
          const SizedBox(height: 20),
          Text('Total: $_totalCalories kcal'),
          const Divider(),
          ...List.generate(_entries.length, (i) {
            final e = _entries[i];
            final dt = DateTime.tryParse(e['date_time']?.toString() ?? '');
            final when = dt == null ? '—' : DateTimeFormatter.format(dt);

            return Dismissible(
              key: ValueKey(e['id'] ?? '${e['date_time']}-${e['calories']}'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                color: Colors.red,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) => _deleteEntry(i),
              child: ListTile(
                title: Text('${e['calories']} kcal'),
                subtitle: Text(when),
                // Replace chevron with edit + delete buttons
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Edit',
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editEntry(i),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteEntry(i),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _calCtrl.dispose();
    super.dispose();
  }
}
