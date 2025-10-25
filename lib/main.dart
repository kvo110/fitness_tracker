import 'package:flutter/material.dart';
import 'package:timezone/data/latest_all.dart' as tz;

// importing the screens files
import 'screens/home_screen.dart';
import 'screens/workout_logs_screen.dart';
import 'screens/workout_plans_screen.dart';
import 'screens/calorie_screen.dart';
import 'screens/insights_screen.dart'; // Updated name to follow the updated label of progress_screen.dart to insights_screen.dart
import 'screens/settings_screen.dart';
import 'notifications/notification.dart'; // notification file

// import widgets
import 'widgets/nav_bar.dart';

// Entry point of the Fitness App
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await NotificationService().init();
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
    // Light theme
    final light = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF2F2F2),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1E88E5),
        secondary: Color(0xFF42A5F5),
        tertiary: Color(0xFF66BB6A),
        error: Color(0xFFE53935),
        surface: Colors.white,
        onSurface: Colors.black,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onError: Colors.white,
      ),
      textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)),
    );

    // Dark theme
    final dark = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF1E1E1E),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF0D47A1),
        secondary: Color(0xFF1565C0),
        tertiary: Color(0xFF2E7D32),
        error: Color(0xFFFF5252),
        surface: Color(0xFF2B2B2B),
        onSurface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onError: Colors.white,
      ),
      textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
    );

    // Define each screen in the nav bar
    final List<Widget> tabs = [
      HomeScreen(onOpenWorkout: () => setState(() => _index = 1)),
      const WorkoutLogsScreen(),
      const WorkoutPlansScreen(),
      const CalorieScreen(),
      const InsightsScreen(), // Replaced with new Insights screen
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
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        extendBody: true,
        body: tabs[_index],
        bottomNavigationBar: NavBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: const [
            NavItem(icon: Icons.home, label: 'Home'),
            NavItem(icon: Icons.fitness_center, label: 'Workout Logs'),
            NavItem(icon: Icons.play_lesson, label: 'Plans'),
            NavItem(icon: Icons.local_dining, label: 'Calories'),
            NavItem(icon: Icons.bar_chart, label: 'Insights'),
            NavItem(icon: Icons.settings, label: 'Settings'),
          ],
        ),
      ),
    );
  }
}
