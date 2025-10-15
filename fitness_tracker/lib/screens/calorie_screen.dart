import 'package:flutter/material.dart';

// Simple calorie tracker using temporary data
class CalorieScreen extends StatefulWidget {
    const CalorieScreen({super.key});

    @override
    State<CalorieScreen> createState() => _CalorieScreenState();
}

class _CalorieScreenState extends State<CalorieScreen> {
    final _foodCtrl = TextEditingController();
    final _calCtrl = TextEditingController();
    final List<Map<String, dynamic>> _entries = [];
    int _totalCalories = 0;

    // Add food entry
    void _addEntry() {
        final name = _foodCtrl.text.trim();
        final cal = int.tryParse(_calCtrl.text) ?? 0;
        if (name.isEmpty || cal <= 0) return;
        setState(() {
            _entries.insert(0, {'food': name, 'calories': cal});
            _totalCalories += cal;
            _foodCtrl.clear();
            _calCtrl.clear();
        });
    }

    // Delete food entry
    void _deleteEntry(int index) {
        setState(() {
            _totalCalories -= (_entries[index]['calories'] as num).toInt();
            _entries.removeAt(index);
        });
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: const Text('Calorie Tracker')),
            body: SafeArea(
                child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    children: [
                        Text('Calorie Tracker', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 12),
                    TextFormField(
                        controller: _foodCtrl,
                        decoration: const InputDecoration(labelText: 'Food'),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                        controller: _calCtrl,
                        decoration: const InputDecoration(labelText: 'Calories'),
                        keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                        onPressed: _addEntry,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Entry'),
                    ),
                    const SizedBox(height: 20),
                    Text('Total: $_totalCalories kcal'),
                    const Divider(),
                    ...List.generate(_entries.length, (i) {
                        final e = _entries[i];
                        return Dismissible(
                            key: ValueKey(e['food']),
                            direction: DismissDirection.endToStart,
                            background: Container(
                                alignment: Alignment.centerRight,
                                color: Colors.red,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => _deleteEntry(i),
                            child: ListTile(
                                title: Text(e['food']),
                                trailing: Text('${e['calories']} kcal'),
                            ),
                        );
                    }),
                ],
            ),
        ));
    }
}