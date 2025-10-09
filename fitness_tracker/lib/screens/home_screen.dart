import 'package:flutter/material.dart';

// Home dashboard screen
class HomeScreen extends StatelessWidget {
  final VoidCallback onOpenWorkout;
  final VoidCallback onOpenCalories;

  const HomeScreen({
    super.key,
    required this.onOpenWorkout,
    required this.onOpenCalories,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          // Title
          Text(
            'Fitness Tracker',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Track workouts, calories, and see your progress.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // 🖼️ App header image
          Center(
            child: Image.asset(
              'assets/images/homescreen.png', // Path inside assets/images/
              height: 140,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 20),

          // Quick action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onOpenWorkout,
                  icon: const Icon(Icons.fitness_center),
                  label: const Text('Workout Log'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onOpenCalories,
                  icon: const Icon(Icons.local_dining),
                  label: const Text('Calorie Tracker'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Motivational tip
          _infoCard(context, 'Tip of the Day', 'Stay consistent — even short workouts count 💪'),
        ],
      ),
    );
  }

  // Reusable info card widget
  Widget _infoCard(BuildContext context, String title, String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(text),
        ],
      ),
    );
  }
}