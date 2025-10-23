import 'package:flutter/material.dart';
import '../api/workout_api.dart';
import '../database/database_helper.dart';
import '../utils/date_time_formatter.dart';

// Workout screen allows users to log workouts (now persisted in DB)
class WorkoutLogsScreen extends StatefulWidget {
    const WorkoutLogsScreen({super.key});

    @override
    State<WorkoutLogsScreen> createState() => _WorkoutLogsScreenState();
}

class _WorkoutLogsScreenState extends State<WorkoutLogsScreen> {
    // Backing list populated from the database
    final List<Map<String, dynamic>> _workouts = [];

    // Form controllers
    final TextEditingController _exerciseController = TextEditingController();
    final TextEditingController _setsController = TextEditingController();
    final TextEditingController _repsController = TextEditingController();
    final TextEditingController _durationController = TextEditingController();

    List<Map<String, dynamic>> _plans = []; // Workout plans from API

    // Select RPE value
    String? _selectedRPE;
    // Select workout plan
    String? _selectedPlan;
    // Select a timestamp
    DateTime? _selectedDateTime;

    bool _loading = true;

    @override
    void initState() {
        super.initState();
        _loadWorkoutPlans();
        _loadWorkouts(); // pull any saved entries from DB at start
    }

    // Fetch the workout plans from the API
    Future<void> _loadWorkoutPlans() async {
        try {
            final plans = await WorkoutAPI.fetchWorkoutPlans();
            if (!mounted) return;
            setState(() {
                _plans = plans;
                _selectedPlan = null;
            });

            debugPrint('Loaded ${_plans.length} workout plans');
            for (final p in _plans.take(5)) {
                debugPrint('${p['name']}');
            }
        } catch (e) {
            debugPrint('Workout Plan Loading Error: $e');
        }
    }

    // Read saved workouts from the database
    Future<void> _loadWorkouts() async {
        setState(() => _loading = true);
        try {
            final rows = await DatabaseHelper.instance.getAllWorkouts();
            if (!mounted) return;
            setState(() {
                _workouts
                    ..clear()
                    ..addAll(rows);
            });
        } catch (e) {
            debugPrint('Load workouts error: $e');
        } finally {
            if (mounted) {
                setState(() => _loading = false);
            }
        }
    }

    // Pick time and date
    Future<void> _pickDateTime() async {
        final DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
            final TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
            );
            if (pickedTime != null) {
                setState(() {
                    _selectedDateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                    );
                });
            }
        }
    }

    // Add workout to DB then refresh list from DB
    Future<void> _addWorkout() async {
        if (_exerciseController.text.isEmpty ||
            _setsController.text.isEmpty ||
            _repsController.text.isEmpty) {
            return;
        }

        final durationParsed = int.tryParse(_durationController.text);
        final workoutData = {
            'exercise': _exerciseController.text,
            'sets': int.parse(_setsController.text),
            'reps': int.parse(_repsController.text),
            'duration': durationParsed ?? 0,
            'rpe': _selectedRPE ?? 'N/A',
            'date_time': (_selectedDateTime ?? DateTime.now()).toIso8601String(),
        };

        try {
            await DatabaseHelper.instance.insertWorkout(workoutData);
            await _loadWorkouts(); // ensure we have row IDs and latest order
            setState(() {
                _exerciseController.clear();
                _setsController.clear();
                _repsController.clear();
                _durationController.clear();
                _selectedRPE = null;
                _selectedDateTime = null;
            });
        } catch (e) {
            debugPrint('Insert workout error: $e');
        }
    }

    // Delete workout from DB (if it has an ID) then refresh
    Future<void> _deleteWorkout(int index) async {
        final row = _workouts[index];
        final id = row['id'] as int?;
        if (id != null) {
            try {
                final db = await DatabaseHelper.instance.database;
                await db.delete(
                    DatabaseHelper.instance.workoutsTable,
                    where: 'id = ?',
                    whereArgs: [id],
                );
            } catch (e) {
                debugPrint('Delete workout error: $e');
            }
        }
        await _loadWorkouts();
    }

    @override
    Widget build(BuildContext context) {
        final isLight = Theme.of(context).brightness == Brightness.light;
        final bgColor = isLight ? Colors.white : Colors.grey[850];

        return SafeArea(
            child: Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                appBar: AppBar(
                    title: const Text('Workout Log'),
                    centerTitle: true,
                    elevation: 0,
                    actions: [
                        IconButton(
                            tooltip: 'Refresh',
                            icon: const Icon(Icons.refresh),
                            onPressed: _loadWorkouts,
                        ),
                    ],
                ),
                body: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                        children: [
                            // Input form
                            Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                        BoxShadow(
                                            color: isLight
                                                ? Colors.black.withOpacity(0.1)
                                                : Colors.white.withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                        ),
                                    ],
                                ),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        DropdownButtonFormField<String>(
                                            value: _selectedPlan,
                                            decoration: const InputDecoration(
                                                labelText: 'Select Workout Plan',
                                                prefixIcon: Icon(Icons.sports_gymnastics),
                                            ),
                                            items: _plans.isEmpty
                                                ? const [
                                                    DropdownMenuItem(
                                                        value: 'loading...',
                                                        child: Text('Loading Workout Plans\nOne Moment...'),
                                                    ),
                                                  ]
                                                : _plans.map((plan) {
                                                    return DropdownMenuItem<String>(
                                                        value: '${plan['name']}_${plan.hashCode}',
                                                        child: Text(plan['name'] ?? 'Unknown Plan'),
                                                    );
                                                  }).toList(),
                                            onChanged: (value) {
                                                setState(() {
                                                    _selectedPlan = value;
                                                    _exerciseController.text =
                                                        value?.split('_').first ?? ''; // Auto fill for exercise name
                                                });
                                            },
                                        ),
                                        TextField(
                                            controller: _exerciseController,
                                            decoration: const InputDecoration(
                                                labelText: 'Exercise Name',
                                                prefixIcon: Icon(Icons.fitness_center),
                                            ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                            children: [
                                                Expanded(
                                                    child: TextField(
                                                        controller: _setsController,
                                                        keyboardType: TextInputType.number,
                                                        decoration: const InputDecoration(
                                                            labelText: 'Sets',
                                                            prefixIcon: Icon(Icons.repeat),
                                                        ),
                                                    ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                    child: TextField(
                                                        controller: _repsController,
                                                        keyboardType: TextInputType.number,
                                                        decoration: const InputDecoration(
                                                            labelText: 'Reps',
                                                            prefixIcon: Icon(Icons.numbers),
                                                        ),
                                                    ),
                                                ),
                                            ],
                                        ),
                                        const SizedBox(height: 10),
                                        TextField(
                                            controller: _durationController,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                                labelText: 'Duration (min)',
                                                prefixIcon: Icon(Icons.timer),
                                            ),
                                        ),
                                        const SizedBox(height: 10),

                                        // Dropdown menu for rep intensity (RPE) with a 1-10 scale
                                        DropdownButtonFormField<String>(
                                            value: _selectedRPE,
                                            decoration: const InputDecoration(
                                                labelText: 'Intensity (RPE)',
                                                prefixIcon: Icon(Icons.bolt),
                                            ),
                                            items: List.generate(
                                                10,
                                                (i) => DropdownMenuItem(
                                                    value: '${i + 1}',
                                                    child: Text('RPE ${i + 1} - ${_rpeDescriptions[i]}'),
                                                ),
                                            ),
                                            onChanged: (value) {
                                                setState(() {
                                                    _selectedRPE = value;
                                                });
                                            },
                                        ),

                                        // UI to select timestamp
                                        const SizedBox(height: 12),
                                        Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                                Text(
                                                    _selectedDateTime == null
                                                        ? 'No Date Selected'
                                                        : 'Date: ${_selectedDateTime.toString()}',
                                                ),
                                                ElevatedButton(
                                                    onPressed: _pickDateTime,
                                                    child: const Text('Pick Date/Time'),
                                                ),
                                            ],
                                        ),

                                        const SizedBox(height: 12),
                                        ElevatedButton.icon(
                                            onPressed: _addWorkout,
                                            icon: const Icon(Icons.add),
                                            label: const Text('Add Workout'),
                                            style: ElevatedButton.styleFrom(
                                                minimumSize: const Size(double.infinity, 45),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                ),
                                            ),
                                        ),
                                    ],
                                ),
                            ),

                            const SizedBox(height: 20),

                            // Workout list
                            Expanded(
                                child: _loading
                                    ? const Center(child: CircularProgressIndicator())
                                    : _workouts.isEmpty
                                        ? Center(
                                            child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                                child: Text(
                                                    'No workouts have been logged yet.\nEnter a new workout to view it here',
                                                    textAlign: TextAlign.center,
                                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w500,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface
                                                            .withOpacity(0.8),
                                                    ),
                                                ),
                                            ),
                                        )
                                        : RefreshIndicator(
                                            onRefresh: _loadWorkouts,
                                            child: ListView.builder(
                                                itemCount: _workouts.length,
                                                itemBuilder: (context, index) {
                                                    final w = _workouts[index];
                                                    final id = w['id'];
                                                    return Dismissible(
                                                        key: ValueKey('workout-$id-$index'),
                                                        direction: DismissDirection.endToStart,
                                                        background: Container(
                                                            color: Colors.redAccent,
                                                            alignment: Alignment.centerRight,
                                                            padding: const EdgeInsets.symmetric(horizontal: 20),
                                                            child: const Icon(Icons.delete, color: Colors.white),
                                                        ),
                                                        onDismissed: (_) => _deleteWorkout(index),
                                                        child: Card(
                                                            margin: const EdgeInsets.symmetric(vertical: 8),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(16),
                                                            ),
                                                            elevation: 3,
                                                            child: ListTile(
                                                                title: Text(w['exercise'] ?? ''),
                                                                subtitle: Text(
                                                                    '${w['sets']} sets × ${w['reps']} reps\n'
                                                                    'Duration: ${w['duration']} min\n'
                                                                    'RPE: ${w['rpe']}\n'
                                                                    'Time: ${DateTimeFormatter.format(DateTime.parse(w['date_time']))}',
                                                                ),
                                                                trailing: IconButton(
                                                                    icon: const Icon(Icons.delete_outline),
                                                                    onPressed: () => _deleteWorkout(index),
                                                                ),
                                                            ),
                                                        ),
                                                    );
                                                },
                                            ),
                                        ),
                            ),
                        ],
                    ),
                ),
            ),
        );
    }

    // RPE description for user to understand what each RPE means
    static const List<String> _rpeDescriptions = [
        'Very Easy',
        'Easy',
        'Moderate',
        'Somewhat Hard',
        'Hard',
        'Challenging',
        'Very Challenging',
        'Intense',
        'Highly Intense',
        'Max Effort',
    ];

    @override
    void dispose() {
        _exerciseController.dispose();
        _setsController.dispose();
        _repsController.dispose();
        _durationController.dispose();
        super.dispose();
    }
}