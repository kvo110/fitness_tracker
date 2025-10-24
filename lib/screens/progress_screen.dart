import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database/database_helper.dart';

class ProgressScreen extends StatefulWidget {
    const ProgressScreen({super.key});

    @override
    State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> with TickerProviderStateMixin {
    late final TabController _tab;
    bool _loading = true;

    // Data grouped by date (yyyy-MM-dd)
    final List<String> _dates = [];                 // ordered x-axis labels
    final List<double> _durationPerDay = [];        // minutes sum
    final List<double> _volumePerDay = [];          // sets*reps sum
    final List<double> _intensityAvgPerDay = [];    // RPE avg (skips 'N/A')
    final List<double> _frequencyPerDay = [];       // entry count

    @override
    void initState() {
        super.initState();
        _tab = TabController(length: 4, vsync: this);
        _load();
    }

    Future<void> _load() async {
        try {
        final rows = await DatabaseHelper.instance.getAllWorkouts();

        // Group rows by date (yyyy-MM-dd)
        final Map<String, List<Map<String, dynamic>>> byDate = {};
        for (final r in rows) {
            final raw = r['date_time']?.toString();
            if (raw == null) continue;
            final dt = DateTime.tryParse(raw);
            if (dt == null) continue;
            final key = '${dt.year.toString().padLeft(4, '0')}-'
                '${dt.month.toString().padLeft(2, '0')}-'
                '${dt.day.toString().padLeft(2, '0')}';
            (byDate[key] ??= []).add(r);
        }

        // Sort by date ascending to make x-axis chronological
        final sortedKeys = byDate.keys.toList()..sort();

        final List<String> dates = [];
        final List<double> duration = [];
        final List<double> volume = [];
        final List<double> intensity = [];
        final List<double> freq = [];

        for (final d in sortedKeys) {
            final list = byDate[d]!;
            dates.add(d);

            // Duration: sum of 'duration'
            final dur = list.fold<num>(0, (sum, e) {
                final v = e['duration'];
                if (v is num) return sum + v;
                final parsed = int.tryParse(v?.toString() ?? '');
                return sum + (parsed ?? 0);
            });
            duration.add(dur.toDouble());

            // Volume: sum of (sets * reps)
            final vol = list.fold<num>(0, (sum, e) {
                final sets = (e['sets'] is num)
                    ? (e['sets'] as num).toInt()
                    : int.tryParse(e['sets']?.toString() ?? '') ?? 0;
                final reps = (e['reps'] is num)
                    ? (e['reps'] as num).toInt()
                    : int.tryParse(e['reps']?.toString() ?? '') ?? 0;
                return sum + (sets * reps);
            });
            volume.add(vol.toDouble());

            // Intensity: average RPE, skipping 'N/A' or non-numeric
            final rpes = <int>[];
            for (final e in list) {
                final rawRpe = e['rpe']?.toString();
                final r = int.tryParse(rawRpe ?? '');
                if (r != null) rpes.add(r);
            }
            final avg = rpes.isEmpty ? 0.0 : (rpes.reduce((a, b) => a + b) / rpes.length);
            intensity.add(avg);

            // Frequency: total entries that day
            freq.add(list.length.toDouble());
        }

        setState(() {
            _dates
            ..clear()
            ..addAll(dates);
            _durationPerDay
            ..clear()
            ..addAll(duration);
            _volumePerDay
            ..clear()
            ..addAll(volume);
            _intensityAvgPerDay
            ..clear()
            ..addAll(intensity);
            _frequencyPerDay
            ..clear()
            ..addAll(freq);
            _loading = false;
        });
        } catch (e) {
            debugPrint('Progress load error: $e');
            setState(() => _loading = false);
        }
    }

    @override
    void dispose() {
        _tab.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        final isLight = Theme.of(context).brightness == Brightness.light;
        final bg = isLight ? Colors.white : Colors.grey[900];
        final text = isLight ? Colors.black : Colors.white;

        return SafeArea(
            child: Scaffold(
                appBar: AppBar(
                    title: const Text('Progress'),
                    centerTitle: true,
                    bottom: TabBar(
                        controller: _tab,
                        isScrollable: true,
                        tabs: const [
                            Tab(text: 'Duration'),
                            Tab(text: 'Volume'),
                            Tab(text: 'Intensity'),
                            Tab(text: 'Frequency'),
                        ],
                    ),
                ),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                        controller: _tab,
                        children: [
                            _chartCard(
                                context,
                                bg,
                                text,
                                title: 'Daily Duration (min)',
                                series: _durationPerDay,
                                yHint: 'minutes',
                            ),
                            _chartCard(
                                context,
                                bg,
                                text,
                                title: 'Daily Volume (sets × reps)',
                                series: _volumePerDay,
                                yHint: 'volume',
                            ),
                            _chartCard(
                                context,
                                bg,
                                text,
                                title: 'Average Intensity (RPE)',
                                series: _intensityAvgPerDay,
                                yHint: 'RPE',
                                maxYOverride: 10, // RPE scale top
                            ),
                            _chartCard(
                                context,
                                bg,
                                text,
                                title: 'Workout Frequency (entries/day)',
                                series: _frequencyPerDay,
                                yHint: 'count',
                            ),
                        ],
                    ),
            ),
        );
    }

    Widget _chartCard(
        BuildContext context,
        Color? bg,
        Color text, {
            required String title,
            required List<double> series,
            required String yHint,
            double? maxYOverride,
        }
    ) {
        final hasData = _dates.isNotEmpty && series.isNotEmpty;
        return Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                    BoxShadow(
                    color: (Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white)
                        .withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                    ),
                ],
            ),
            child: hasData
                ? _scrollableLineChart(title, series, text, maxYOverride)
                : Center(
                    child: Text(
                    'No data yet.\nStart logging workouts to see $yHint over time.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: text.withOpacity(0.8)),
                    ),
                ),
            ),
        );
    }

    Widget _scrollableLineChart(
        String title,
        List<double> series,
        Color text,
        double? maxYOverride,
    ) {
        // Convert to spots with x=index
        final spots = <FlSpot>[];
        for (var i = 0; i < series.length; i++) {
            spots.add(FlSpot(i.toDouble(), series[i]));
        }

        // Axis bounds
        final minY = 0.0;
        final maxY = maxYOverride ?? (series.reduce((a, b) => a > b ? a : b) * 1.2 + 1);
        final viewWidth = (series.length <= 7) ? 7.0 : series.length.toDouble();

        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: text)),
                const SizedBox(height: 10),
                SizedBox(
                    height: 280,
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: SizedBox(
                            width: 60.0 * viewWidth, // space per day for readability
                            child: LineChart(
                                LineChartData(
                                    minX: 0,
                                    maxX: (series.length - 1).toDouble(),
                                    minY: minY,
                                    maxY: maxY,
                                    gridData: FlGridData(show: true),
                                    borderData: FlBorderData(
                                        show: true,
                                        border: Border.all(color: text.withOpacity(0.3)),
                                    ),
                                    titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 36,
                                                getTitlesWidget: (value, meta) {
                                                    return Text(
                                                        value.toInt().toString(),
                                                        style: TextStyle(fontSize: 10, color: text.withOpacity(0.8)),
                                                    );
                                                },
                                            ),
                                        ),
                                        bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                                showTitles: true,
                                                interval: 1,
                                                getTitlesWidget: (value, meta) {
                                                    final i = value.toInt();
                                                    if (i < 0 || i >= _dates.length) {
                                                        return const SizedBox.shrink();
                                                    }
                                                    final d = _dates[i]; // yyyy-MM-dd
                                                    // Short label M/D
                                                    final parts = d.split('-');
                                                    final label = '${int.parse(parts[1])}/${int.parse(parts[2])}';
                                                    return Padding(
                                                        padding: const EdgeInsets.only(top: 6),
                                                        child: Text(
                                                        label,
                                                        style: TextStyle(fontSize: 10, color: text.withOpacity(0.9)),
                                                        ),
                                                    );
                                                },
                                            ),
                                        ),
                                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    ),
                                    lineBarsData: [
                                        LineChartBarData(
                                        spots: spots,
                                        isCurved: true,
                                        color: Colors.blue,
                                        barWidth: 3,
                                        dotData: FlDotData(show: true),
                                        belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.25)),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                    ),
                ),
            ],
        );
    }
}