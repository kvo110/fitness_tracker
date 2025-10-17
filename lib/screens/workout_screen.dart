import 'package:flutter/material.dart';
import '../api/workout_api.dart';
import '../database/database_helper.dart';

// Workout screen allows users to temporarily log workouts (no DB yet)
class WorkoutScreen extends StatefulWidget {
    const WorkoutScreen({super.key});

    @override
    State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> { 
    // Temporary in-memory list of workouts
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

    @override
    void initState() {
        super.initState();
        _loadWorkoutPlans();
    }

    // Fetch the workout plans from the API
    Future <void> _loadWorkoutPlans() async {
        try {
            final plans = await WorkoutAPI.fetchWorkoutPlans();
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

    // Pick time and date 
    Future <void> _pickDateTime() async {
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

    // Add workout to list
    Future<void> _addWorkout() async {
        if (_exerciseController.text.isEmpty ||
            _setsController.text.isEmpty ||
            _repsController.text.isEmpty) return;

        final workoutData = {
            'exercise': _exerciseController.text,
            'sets': int.parse(_setsController.text),
            'reps': int.parse(_repsController.text),
            'duration': int.parse(_durationController.text),
            'rpe': _selectedRPE ?? 'N/A',
            'date_time': _selectedDateTime?.toIso8601String() ?? DateTime.now().toIso8601String(),
        };

        // Save entry into the database
        await DatabaseHelper.instance.insertWorkout(workoutData);

        setState(() {
            _workouts.add(workoutData);
            _exerciseController.clear();
            _setsController.clear();
            _repsController.clear();
            _durationController.clear();
            _selectedRPE = null;
            _selectedDateTime = null; 
        });
    }

    // Delete workout from list
    void _deleteWorkout(int index) {
        setState(() {
        _workouts.removeAt(index);
        });
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
                                        ? [
                                            const DropdownMenuItem(
                                                value: 'loading...',
                                                child: Text('Loading Workout Plans\nOne Moment...'),
                                            ),
                                        ] : _plans.map((plan) {
                                            return DropdownMenuItem<String> (
                                                value: '${plan['name']}_${plan.hashCode}',
                                                child: Text(plan['name'] ?? 'Unknown Plan'),
                                            );
                                        }).toList(),

                                        onChanged: (value) {
                                            setState(() {
                                                _selectedPlan = value;
                                                _exerciseController.text = value?.split('_').first ?? ''; // Auto fill for exercise name
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

                                    // Dropdown menu for rep intensity (RPE) with a 1-10 scale, 1 being effortless and 10 being highly difficult (unable to do another rep)
                                    DropdownButtonFormField<String> (
                                        value: _selectedRPE,
                                        decoration: const InputDecoration(
                                            labelText: 'Intesity (RPE)',
                                            prefixIcon: Icon(Icons.bolt),
                                        ),
                                        items: List.generate(
                                            10, (i) => DropdownMenuItem(
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
                                                _selectedDateTime == null ? 'No Date Selected' : 'Date: ${_selectedDateTime.toString()}',
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
                            child: _workouts.isEmpty
                                ? Center( 
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                        child: Text(
                                            'No workouts have been logged yet. \nEnter a new workout to view it here',
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                                            ),
                                        ),
                                    ),
                                )

                                : ListView.builder(
                                    itemCount: _workouts.length,
                                    itemBuilder: (context, index) {
                                        final w = _workouts[index];
                                        return Dismissible(
                                            key: Key(w['exercise'] + index.toString()),
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
                                                    title: Text(w['exercise']),
                                                    subtitle: Text('${w['sets']} sets × ${w['reps']} reps\nDuration: ${w['duration']} min\nRPE: ${w['rpe']}'),
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