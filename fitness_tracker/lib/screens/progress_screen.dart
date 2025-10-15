import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// Static progress chart placeholder for Milestone 1
class ProgressScreen extends StatelessWidget {
    const ProgressScreen({super.key});

    @override
    Widget build(BuildContext context) {
        final isLight = Theme.of(context).brightness == Brightness.light;
        final bgColor = isLight ? Colors.white : Colors.grey[900];
        final textColor = isLight ? Colors.black : Colors.white;

        return SafeArea(
            child: Scaffold(
                appBar: AppBar(
                    title: const Text('Progress Overview'),
                    centerTitle: true,
                    elevation: 0,
                ),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView(
                        children: [
                            Text(
                                'Weekly Workout Progress',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: textColor, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),

                            Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                        BoxShadow(color: isLight ? Colors.black.withOpacity(0.1) : Colors.white.withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                        ),
                                    ],
                                ),
                                height: 280,
                                child: LineChart(
                                    LineChartData(
                                        minX: 0,
                                        maxX: 6,
                                        minY: 0,
                                        maxY: 100,
                                        gridData: FlGridData(show: true),
                                        borderData: FlBorderData(
                                            show: true,
                                            border: Border.all(
                                                color: Colors.grey.withOpacity(0.4),
                                            ),
                                        ),
                                        titlesData: FlTitlesData(
                                            leftTitles: AxisTitles(
                                                sideTitles: SideTitles(showTitles: true),
                                            ),
                                            bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                    showTitles: true,
                                                    interval: 1,
                                                    getTitlesWidget: (value, meta) {
                                                        const days = [
                                                            'MON',
                                                            'TUE',
                                                            'WED',
                                                            'THU',
                                                            'FRI',
                                                            'SAT',
                                                            'SUN',
                                                        ];
                                                        if(value < 0 || value > 6) return const SizedBox();
                                                        return Padding(
                                                            padding: const EdgeInsets.only(top: 8.0),
                                                            child: Text(
                                                                days[value.toInt()],
                                                                style: TextStyle(
                                                                    color: textColor.withOpacity(0.9),
                                                                    fontSize: 12,
                                                                ),
                                                            ),
                                                        );
                                                    },
                                                ),
                                            ),
                                        ),
                                        lineBarsData: [
                                            LineChartBarData(
                                                spots: const [
                                                    FlSpot(0,20),
                                                    FlSpot(1,40),
                                                    FlSpot(2,30),
                                                    FlSpot(3,55),
                                                    FlSpot(4,67),
                                                    FlSpot(5,70),
                                                    FlSpot(6,95),
                                                ],
                                                isCurved: true,
                                                color: Theme.of(context).colorScheme.primary,
                                                barWidth: 4,
                                                dotData: FlDotData(show: true),
                                                belowBarData: BarAreaData(
                                                    show: true,
                                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                            ),
                            const SizedBox(height: 20),

                            // Shows the summary of the data
                            Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                        BoxShadow(color: isLight ? Colors.black.withOpacity(0.1) : Colors.white.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                        ),
                                    ],
                                ),
                                child: Column(
                                    children: [
                                        Text(
                                            'Summary Overview',
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: textColor),
                                        ),

                                        const SizedBox(height: 8),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.local_dining, size: 48),
                                              onPressed: () {
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.calendar_today, size: 48),
                                              onPressed: () {
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.show_chart, size: 48),
                                              onPressed: () {
                                              },
                                            ),
                                          ],
                                        ),

                                        Text(
                                            'Stay Disciplined\nPay the price now to enjoy the prize later',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: textColor.withOpacity(0.85),
                                                fontSize: 15,
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        ],
                    ),
                ),
            ),
        );
    }
}


