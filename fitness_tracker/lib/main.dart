import 'package:flutter/material.dart';

// importing the screens files
import 'screens/home_screen.dart';
import 'screens/workout_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    // Light theme mode
    final light = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF2F2F2),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1E88E5), // Bright blue color
        secondary: Colors.blueAccent,
        surface: Colors.white,
        onSurface: Colors.black,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black),
      ),
    );

    // Dark theme mode
    final dark = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF1E1E1E),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF0D47A1), // darker blue
        secondary: Color(0xFF1565C0),
        surface: Color(0xFF2B2B2B),
        onSurface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white),
      ),
    );

    // Define each screen in the nav bar 
    final List<Widget> tabs = [
      HomeScreen(
        onOpenWorkout: () => setState(() => _index = 1),
        // onOpenCalories: () => setState(() => _index = 2),
      ),
      const WorkoutScreen(),
      // const CalorieScreen(),
      const ProgressScreen(),
      SettingsScreen(
        isDark: _isDark,
        onToggleTheme: (v) => setState(() => _isDark = v),
      ),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fitness Tracker App',
      theme: light,
      darkTheme: dark,
      // Switch theme based on toggled option in the settings screen
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        extendBody: true, // Creates the floating effect of the nav bar
        body: tabs[_index],
        // Bottom nav bar
        bottomNavigationBar: NavBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: const [
            NavItem(icon: Icons.home, label: 'Home'),
            NavItem(icon: Icons.fitness_center, label: 'Workout'),
            // NavItem(icon: Icons.local_dining, label: 'Calories'),
            NavItem(icon: Icons.bar_chart, label: 'Progress'),
            NavItem(icon: Icons.settings, label: 'Settings'),
          ],
        ),
      ),
    );
  }
}