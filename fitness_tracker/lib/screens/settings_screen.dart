import 'package:flutter/material.dart';

// Settings screen for toggling light/dark theme
class SettingsScreen extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onToggleTheme;

  const SettingsScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle between light and dark themes'),
            value: isDark,
            onChanged: onToggleTheme,
          ),
        ],
      ),
    );
  }
}