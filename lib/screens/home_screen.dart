import 'package:flutter/material.dart';

// Home dashboard screen
class HomeScreen extends StatefulWidget {
    final VoidCallback onOpenWorkout;
    final VoidCallback? onOpenCalories;

    const HomeScreen({
        super.key,
        required this.onOpenWorkout,
        this.onOpenCalories,
    });

    @override
    State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
    final TextEditingController _calorieController = TextEditingController();
    int? _lastCheckIn; // Stores today's calorie check-in temporarily

    // Handles calorie check-in logic
    void _handleCheckIn() {
        if (_calorieController.text.isEmpty) return;
        final calories = int.tryParse(_calorieController.text);
        if (calories == null) return;

        setState(() {
            _lastCheckIn = calories;
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Check-in saved: $_lastCheckIn calories 🍽️'),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
            ),
        );

        _calorieController.clear();
    }

    @override
    Widget build(BuildContext context) {
        final isLight = Theme.of(context).brightness == Brightness.light;
        final bgColor = isLight ? Colors.white : Colors.grey[850];
        final textColor = isLight ? Colors.black : Colors.white;

        return SafeArea(
            child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                children: [
                // Title and Subtitle for home/introduction page
                Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                            BoxShadow(color: isLight
                                ? Colors.black.withOpacity(0.1)
                                : Colors.white.withOpacity(0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                            ),
                        ],
                    ),
                    child: Column(
                        children: [
                            Text(
                                'Fitness Tracker',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                                'Track workouts, calories, and see your progress.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: textColor.withOpacity(0.8)),
                            ),
                        ],
                    ),
                ),

                const SizedBox(height: 20),

                // Displays image for the homepage
                Center(
                    child: Image.asset(
                    'assets/images/homescreen.png',
                    height: 200,
                    fit: BoxFit.contain,
                    ),
                ),

                const SizedBox(height: 20),
                // Quick action buttons
                // Row(
                //     children: [
                //         Expanded(
                //             child: ElevatedButton.icon(
                //                 onPressed: widget.onOpenWorkout,
                //                 icon: const Icon(Icons.fitness_center),
                //                 label: const Text('Workout Log'),
                //             ),
                //         ),
                //         const SizedBox(width: 12),
                //         Expanded(
                //             child: OutlinedButton.icon(
                //                 onPressed: widget.onOpenCalories,
                //                 icon: const Icon(Icons.local_dining),
                //                 label: const Text('Calorie Tracker'),
                //             ),
                //         ),
                //     ],
                // ),
                const SizedBox(height: 24),
                // Daily Calorie Check-In box
                Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                            BoxShadow(color: isLight
                                ? Colors.black.withOpacity(0.1)
                                : Colors.white.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                            ),
                        ],
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text(
                                'Daily Calorie Check-In',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                                children: [
                                    Expanded(
                                        child: TextField(
                                            controller: _calorieController,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                                labelText: 'Calories eaten today',
                                                prefixIcon: Icon(Icons.local_fire_department),
                                            ),
                                        ),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton(
                                        onPressed: _handleCheckIn,
                                        style: ElevatedButton.styleFrom(
                                            shape: const CircleBorder(),
                                            padding: const EdgeInsets.all(14),
                                        ),
                                        child: const Icon(Icons.check, size: 26),
                                    ),
                                ],
                            ),
                            if (_lastCheckIn != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                    'Last check-in: $_lastCheckIn calories',
                                    style: TextStyle(
                                        color: textColor.withOpacity(0.8),
                                        fontSize: 15,
                                    ),
                                ),
                            ],
                        ],
                    ),
                ),

                const SizedBox(height: 24),
                // Motivational tip
                _infoCard(
                    context,
                    'Tip of the Day',
                    '1% growth per day is better than 0% growth.',
                    ),
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

    @override
    void dispose() {
        _calorieController.dispose();
        super.dispose();
    }
}