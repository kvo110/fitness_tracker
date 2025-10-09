import 'package:flutter/material.dart';

// Settings screen that manages theme toggling
class SettingsScreen extends StatelessWidget {
  final bool isDark; // current theme state
  final ValueChanged<bool> onToggleTheme; // callback to toggle theme

  const SettingsScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Theme mode toggle
          SwitchListTile(
            title: Text(
              isDark ? 'Dark Mode Enabled' : 'Light Mode Enabled',
            ),
            subtitle: Text(
              isDark
                  ? 'Switch to Light Mode'
                  : 'Switch to Dark Mode',
            ),
            value: isDark,
            onChanged: onToggleTheme,
          ),
        ],
      ),
    );
  }
}