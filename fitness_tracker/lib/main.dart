import 'package:flutter/material.dart';

// importing the screens files
import 'screens/home_screen.dart';
import 'screnns/workout_screen.dart';
import 'screens/calorie_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/settings_screen.dart';

// import widgets
import 'widgets/nav_bar.dart';

// Entry point of the Fitness App
void main() {
  runApp(const FitnessApp());
}

// Widget that manages app theme and navigation
class FitnessApp extends StatefulWidget {
  const FitnessApp({super.key});

  @override
  State<FitnessApp> createState() => _FitnessAppState();
}

class _FitnessAppState extends State<FitnessApp> {
  int _index = 0; // Tracks current tab index
  bool _isDark = false; // Light/Dark mode toggle
  late final List<Widget> _tabs; // List of pages displayed in the nav bar

  @override
  void initState() {
    super.initState();
    // Define each screen in the nav bar 
    _tabs = [
      HomeScreen(
        onOpenWorkout: () => setState(() => _index = 1),
        onOpenCalories: () => setState(() => _index = 2),
      ),
      const WorkoutScreen(),
      const CalorieScreen(),
      const ProgressScreen(),
      SettingsScreen(
        isDark: _isDark,
        onToggleTheme: (v) => setState(() => _isDark = v),
      ),
    ];
  }

  @override
  Widget build(BuildContext_context) {
    // Light theme mode
    final light = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.grey[200],
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    );
    // Dark theme mode
    final dark = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fitness Tracker App',
      theme: light,
      darkTheme: dark,
      // Switch theme based on toggled option in the settings screen
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        extendBody: true, // Creates the floating effect of the nav bar
        body: _tabs[_index], 
        // Bottom nav bar
        bottomNavigationBar: NavBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: const [
            NavItem(icon: Icons.home, label: 'Home'),
            NavItem(icon: Icons.fitness_center, label: 'Workout'),
            NavItem(icon: Icons.local_dining, label: 'Calories'),
            NavItem(icon: Icons.bar_chart, label: 'Progress'),
            NavItem(icon: Icons.settings, label: 'Settings'),
          ],
        ),
      ),
    );
  }
}