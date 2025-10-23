// Professor Henry approved of our guides to be Push, Pull, and Legs rather than beginner, intermediate, and advanced

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'selected_workout_screen.dart';

class WorkoutPlansScreen extends StatefulWidget {
  const WorkoutPlansScreen({super.key});

  @override
  State<WorkoutPlansScreen> createState() => _WorkoutPlansScreenState();
}

class _WorkoutPlansScreenState extends State<WorkoutPlansScreen> {
  final dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _workoutPlans = [];

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  // Loads all workout plans
  Future<void> _loadPlans() async {
    final data = await dbHelper.getAllPlans();
    setState(() => _workoutPlans = data);
  }

  // Deletes a workout plan
  Future<void> _deletePlan(int planId) async {
    await dbHelper.deletePlan(planId);
    await _loadPlans();
  }

  // Creates a predefined workout plan guide
  Future<void> _createGuide(String guideType) async {
    int planId;

    if (guideType == 'Push') {
      planId = await dbHelper.insertPlan({
        'title': 'Push',
        'description': 'Chest, Shoulder, Tricep workout',
      });

      final workouts = [
        {'workout_name': 'Bench Press', 'sets': 3, 'reps': 5},
        {'workout_name': 'Barbell Overhead Press', 'sets': 2, 'reps': 8},
        {'workout_name': 'Skull Crushers', 'sets': 4, 'reps': 10},
        {'workout_name': 'Lateral Raises', 'sets': 3, 'reps': 10},
        {'workout_name': 'Incline Chest Press', 'sets': 3, 'reps': 8},
      ];

      for (var w in workouts) {
        await dbHelper.insertWorkoutToPlan({
          'plan_id': planId,
          'workout_name': w['workout_name'],
          'sets': w['sets'],
          'reps': w['reps'],
        });
      }
    } else if (guideType == 'Pull') {
      planId = await dbHelper.insertPlan({
        'title': 'Pull',
        'description': 'Back, Bicep workout',
      });

      final workouts = [
        {'workout_name': 'Hyper Back Extension', 'sets': 4, 'reps': 12},
        {'workout_name': 'Bent Over Barbell Row', 'sets': 3, 'reps': 10},
        {'workout_name': 'Preacher Curls', 'sets': 3, 'reps': 8},
        {'workout_name': 'Rear-Delt Flies', 'sets': 3, 'reps': 12},
        {'workout_name': 'Dumbbell Curls', 'sets': 3, 'reps': 10},
      ];

      for (var w in workouts) {
        await dbHelper.insertWorkoutToPlan({
          'plan_id': planId,
          'workout_name': w['workout_name'],
          'sets': w['sets'],
          'reps': w['reps'],
        });
      }
    } else if (guideType == 'Legs & Core') {
      planId = await dbHelper.insertPlan({
        'title': 'Legs & Core',
        'description': 'Lower body and core workout',
      });

      final workouts = [
        {'workout_name': 'Barbell Squats', 'sets': 4, 'reps': 5},
        {'workout_name': 'Lunges', 'sets': 3, 'reps': 20},
        {'workout_name': 'Romanian Deadlift', 'sets': 3, 'reps': 8},
        {'workout_name': 'Leg Extension', 'sets': 3, 'reps': 12},
        {'workout_name': 'Hamstring Curls', 'sets': 3, 'reps': 10},
        {'workout_name': 'Weighted Planks', 'sets': 3, 'reps': 0},
      ];

      for (var w in workouts) {
        await dbHelper.insertWorkoutToPlan({
          'plan_id': planId,
          'workout_name': w['workout_name'],
          'sets': w['sets'],
          'reps': w['reps'],
        });
      }
    }

    _loadPlans(); // refresh UI
  }

  void _showAddWorkoutDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    // Creates pop up to add new custom plan
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Workout Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // Title input
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              // Description input
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),

          // Cancel and Add buttons
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final desc = descController.text.trim();

                if (title.isNotEmpty) {
                  await dbHelper.insertPlan({
                    'title': title,
                    'description': desc,
                  });
                  await _loadPlans();
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

  // Creates pop up to choose a workout guide
  void _showGuideDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose a Workout Guide'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGuideButton('Push'),
              _buildGuideButton('Pull'),
              _buildGuideButton('Legs & Core'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGuideButton(String guideName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ElevatedButton(
        onPressed: () async {
          Navigator.pop(context);
          await _createGuide(guideName);
        },
        child: Text(guideName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Workout Plans'),
          centerTitle: true,
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.add),
              onSelected: (value) {
                if (value == 'manual') {
                  _showAddWorkoutDialog();
                } else if (value == 'guide') {
                  _showGuideDialog();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'manual',
                  child: Text('Add Custom Plan'),
                ),
                const PopupMenuItem(
                  value: 'guide',
                  child: Text('Add Guide Plan'),
                ),
              ],
            ),
          ],
        ),

        // Displays workout plans or a message if empty
        body: _workoutPlans.isEmpty
            ? const Center(
                child: Text(
                  'No workout plans.\nTap + to add one!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _workoutPlans.length,
                itemBuilder: (context, index) {
                  final plan = _workoutPlans[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: ListTile(
                      title: Text(
                        plan['title'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(plan['description'] ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletePlan(plan['id']),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SelectedWorkoutScreen(
                              planId: plan['id'],
                              planTitle: plan['title'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
