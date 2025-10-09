import 'package:flutter/material.dart';

// importing the screens files
import 'screens/home_screen.dart';
import 'screnns/workout_screen.dart';
import 'screens/calorie_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/settings_screen.dart';

// import widgets
import 'widgets/nav_bar.dart';

void main() {
  runApp(const FitnessApp());
}

class FitnessApp extends StatefulWidget {
  int _index = 0;
  bool _isDark = false;

  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
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
    final light = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.grey[200],
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    );

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
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        extendBody: true,
        body: _tabs[_index],
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