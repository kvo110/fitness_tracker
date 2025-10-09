import 'package:flutter/material.dart';

// Workout entry as temporary data
class WorkoutItem {
    final String type;
    final int sets;
    final int reps;
    final int durationMin;
    final DateTime date;

    WorkoutItem({
        required this.type,
        required this.sets,
        required this.reps,
        required this.durationMin,
        required this.date,
    });
}

// Screen to log your workouts
class WorkoutScreen extends StatefulWidget {
    const WorkoutScreen({super.key});

    @override
    State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
    final _formKey = GlobalKey<FormState>();
    final _typeCtrl = TextEditingController();
    final _setsCtrl = TextEditingController(text: '0');
    final _repsCtrl = TextEditingController(text: '0');
    final _durCtrl = TextEditingController(text: '10');
    final List<WorkoutItem> _workouts = [];

    // Add new workouts
    void _addWorkout() {
        if (!_formKey.currentState!.validate())
        return;
        setState(() {
            _workouts.insert(
                0,
                WorkoutItem(
                    type: _typeCtrl.text.trim(),
                    sets: int.tryParse(_setsCtrl.text) ?? 0,
                    reps: int.tryParse(_repsCtrl.text) ?? 0,
                    durationMin: int.parse(_durCtrl.text),
                    date: DateTime.now(),
                ),
            );
            _typeCtrl.clear();
            _setsCtrl.text = '0';
            _repsCtrl.text = '0';
            _durCtrl.text = '10';
        });
    }

    // Delete workout
  void _deleteWorkout(int index) => setState(() => _workouts.removeAt(index));

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          Text('Workout Log', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          _buildForm(),
          const SizedBox(height: 16),
          if (_workouts.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('No workouts yet — Add your first above'),
            ),
          // Display logged workouts
          ...List.generate(_workouts.length, (i) {
            final w = _workouts[i];
            return Dismissible(
              key: ValueKey('${w.type}-${w.date}-$i'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) => _deleteWorkout(i),
              child: ListTile(
                leading: CircleAvatar(child: Text(w.type[0].toUpperCase())),
                title: Text('${w.type} — ${w.durationMin} min'),
                subtitle: Text('Sets: ${w.sets}, Reps: ${w.reps}'),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Workout input form
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(children: [
        TextFormField(
          controller: _typeCtrl,
          decoration: const InputDecoration(labelText: 'Workouts'),
          validator: (v) => v!.isEmpty ? 'Enter a workout' : null,
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: TextFormField(
              controller: _setsCtrl,
              decoration: const InputDecoration(labelText: 'Sets'),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: _repsCtrl,
              decoration: const InputDecoration(labelText: 'Reps'),
              keyboardType: TextInputType.number,
            ),
          ),
        ]),
        const SizedBox(height: 8),
        TextFormField(
          controller: _durCtrl,
          decoration: const InputDecoration(labelText: 'Duration (min)'),
          keyboardType: TextInputType.number,
          validator: (v) {
            final n = int.tryParse(v ?? '');
            if (n == null || n <= 0) return 'Invalid Input: Please input duration (in Minutes)';
            return null;
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _addWorkout,
            icon: const Icon(Icons.add),
            label: const Text('Add Workout'),
          ),
        ),
      ]),
    );
  }  
}