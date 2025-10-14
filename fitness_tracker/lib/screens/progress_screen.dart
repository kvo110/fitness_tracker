import 'package:flutter/material.dart';

// Static progress chart placeholder for Milestone 1
class ProgressScreen extends StatelessWidget {
    const ProgressScreen({super.key});

    @override
    Widget build(BuildContext context) {
        return SafeArea(
            child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Icon(Icons.show_chart, size: 80, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 20),
                        Text('Progress Dashboard', style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 8),
                        const Text('Charts will be dynamic in Milestone 2'),
                    ],
                ),
            ),
        );
    }
}


