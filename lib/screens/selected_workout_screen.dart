import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class SelectedWorkoutScreen extends StatefulWidget {
  final int planId;
  final String planTitle;

  const SelectedWorkoutScreen({
    super.key,
    required this.planId,
    required this.planTitle,
  });

  @override
  State<SelectedWorkoutScreen> createState() => _SelectedWorkoutScreenState();
}

class _SelectedWorkoutScreenState extends State<SelectedWorkoutScreen> {
  final dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _workouts = [];

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  // Loads all workouts for the selected plan
  Future<void> _loadWorkouts() async {
    final workouts = await dbHelper.getWorkoutsForPlan(widget.planId);
    setState(() {
      _workouts = workouts;
    });
  }

  // Deletes a workout plan
  Future<void> _deleteWorkout(int workoutId) async {
    await dbHelper.deleteWorkoutFromPlan(workoutId);
    await _loadWorkouts();
  }

  void _showAddWorkoutDialog() {
    final nameController = TextEditingController();
    final setsController = TextEditingController();
    final repsController = TextEditingController();

    // Creates pop up to add new workout
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Workout'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Workout name input
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Workout Name',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              // Sets input
              TextField(
                controller: setsController,
                decoration: const InputDecoration(
                  labelText: 'Sets',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),

              // Reps input
              TextField(
                controller: repsController,
                decoration: const InputDecoration(
                  labelText: 'Reps',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            // Cancel and Add buttons
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final sets = setsController.text.trim();
                final reps = repsController.text.trim();

                // Only add if all fields are filled
                if (name.isNotEmpty && sets.isNotEmpty && reps.isNotEmpty) {
                  await dbHelper.insertWorkoutToPlan({
                    'plan_id': widget.planId,
                    'workout_name': name,
                    'sets': int.parse(sets),
                    'reps': int.parse(reps),
                  });
                  await _loadWorkouts();
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.planTitle),
          centerTitle: true,
          actions: [
            // Add new workout button
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddWorkoutDialog,
            ),
          ],
        ),

        // No workouts exist, show a message
        body: _workouts.isEmpty
          ? const Center(
              child: Text(
                'No workouts added yet.\nTap + to add one!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )

          // Otherwise, show list of workouts
          : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _workouts.length,
            itemBuilder: (context, index) {
              final workout = _workouts[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: ListTile(
                  title: Text(
                    workout['workout_name'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  subtitle: Text(
                    '${workout['sets']} sets × ${workout['reps']} reps',
                    style: const TextStyle(fontSize: 15),
                  ),

                  // Delete workout button
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        _deleteWorkout(workout['id'] as int),
                  ),
                ),
              );
            },
          ),
      ),
    );
  }
}
