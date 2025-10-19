import 'package:flutter/material.dart';

class CalorieChartScreen extends StatelessWidget {
  const CalorieChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Calorie Chart'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'Calorie Chart Screen\n (Waiting for database integration)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
