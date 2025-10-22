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
    final plans = await dbHelper.getAllPlans();
    setState(() {
      _workoutPlans = plans;
    });
  }
  
  // Deletes a workout plan
  Future<void> _deletePlan(int planId) async {
    await dbHelper.deletePlan(planId);
    await _loadPlans();
  }

  void _showAddWorkoutDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    // Creates pop up to add new plan
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Workout Plans'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddWorkoutDialog,
            ),
          ],
        ),

        // Displays workout plans or a message if empty
        body: _workoutPlans.isEmpty
            ? const Center(
                child: Text(
                  'No workout plans. \nTap + to add one!',
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
