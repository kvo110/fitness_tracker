import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database/database_helper.dart';

enum _Metric { frequency, duration, intensity, calories }

class InsightsScreen extends StatefulWidget {
    const InsightsScreen({super.key});

    @override
    State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
    final _db = DatabaseHelper.instance;

    _Metric _selected = _Metric.frequency;
    List<_DayValue> _freq = [];
    List<_DayValue> _duration = [];
    List<_DayValue> _intensity = [];
    List<_DayValue> _calories = [];

    bool _loading = true;
    String? _error;

    @override
    void initState() {
        super.initState();
        _load();
    }

    Future<void> _load() async {
        setState(() {
            _loading = true;
            _error = null;
        });
        try {
            final freqRows = await _db.getWorkoutCountsByDay();
            final durRows = await _db.getWorkoutDurationByDay();
            final rpeRows = await _db.getAverageRPEByDay();
            final calRows = await _db.getCaloriesByDay();

            _freq = _parseRows(freqRows, dayKey: 'day', valueKey: 'count');
            _duration = _parseRows(durRows, dayKey: 'day', valueKey: 'total_duration');
            _intensity = _parseRows(rpeRows, dayKey: 'day', valueKey: 'avg_rpe');
            _calories = _parseRows(calRows, dayKey: 'day', valueKey: 'total_calories');

            _freq = _takeTail(_freq, 30);
            _duration = _takeTail(_duration, 30);
            _intensity = _takeTail(_intensity, 30);
            _calories = _takeTail(_calories, 30);
        } catch (e) {
            _error = 'Could not load insights. ($e)';
        } finally {
            if (mounted) {
                setState(() {
                    _loading = false;
                });
            }
        }
    }

    @override
    Widget build(BuildContext context) {
        final isLight = Theme.of(context).brightness == Brightness.light;
        final cardBg = isLight ? Colors.white : Colors.grey[900];
        final series = _seriesFor(_selected);
        final hasData = series.isNotEmpty;

        return SafeArea(
            child: Scaffold(
                appBar: AppBar(
                    title: const Text('Insights'),
                    centerTitle: true,
                ),
                body: RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        children: [
                            _segmentedControl(context),
                            const SizedBox(height: 16),
                            Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                        BoxShadow(
                                            color: isLight
                                                ? Colors.black.withOpacity(0.08)
                                                : Colors.white.withOpacity(0.08),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                        ),
                                    ],
                                ),
                                height: 300,
                                child: _loading
                                    ? const Center(child: CircularProgressIndicator())
                                    : _error != null
                                        ? Center(
                                            child: Text(
                                                _error!,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(color: Colors.red),
                                            ),
                                        )
                                        : hasData
                                            ? LineChart(_lineChartData(context, series))
                                            : const _EmptyState(),
                            ),
                            const SizedBox(height: 16),
                            _summaryCard(
                                context: context,
                                bg: cardBg,
                                title: _summaryTitle(),
                                lines: _summaryLines(series, _selected),
                            ),
                        ],
                    ),
                ),
            ),
        );
    }

    Widget _segmentedControl(BuildContext context) {
        final isLight = Theme.of(context).brightness == Brightness.light;
        final selectedBg = Theme.of(context).colorScheme.primary;
        final unselectedBg = isLight ? Colors.grey[300] : Colors.grey[800];
        final selectedTextColor = Colors.white;
        final unselectedTextColor = isLight ? Colors.black87 : Colors.white70;

        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _Metric.values.map((metric) {
                final bool isSelected = _selected == metric;
                return Expanded(
                    child: GestureDetector(
                        onTap: () {
                            setState(() {
                                _selected = metric;
                            });
                        },
                        child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                                color: isSelected ? selectedBg : unselectedBg,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                            color: selectedBg.withOpacity(0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                        ),
                                    ]
                                    : [],
                            ),
                            child: Center(
                                child: Text(
                                    _metricLabel(metric),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? selectedTextColor
                                            : unselectedTextColor,
                                    ),
                                ),
                            ),
                        ),
                    ),
                );
            }).toList(),
        );
    }

    String _metricLabel(_Metric m) {
        switch (m) {
            case _Metric.frequency:
                return 'Frequency';
            case _Metric.duration:
                return 'Duration';
            case _Metric.intensity:
                return 'Intensity';
            case _Metric.calories:
                return 'Calories';
        }
    }

    Widget _summaryCard({
        required BuildContext context,
        required Color? bg,
        required String title,
        required List<String> lines,
    }) {
        final textColor = Theme.of(context).colorScheme.onSurface;
        return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black.withOpacity(0.06)
                            : Colors.white.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                    ),
                ],
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    for (final line in lines)
                        Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                                line,
                                style: TextStyle(
                                    color: textColor.withOpacity(0.9),
                                    fontSize: 14,
                                ),
                            ),
                        ),
                ],
            ),
        );
    }

    LineChartData _lineChartData(BuildContext context, List<_DayValue> data) {
        final primary = Theme.of(context).colorScheme.primary;
        final spots = [
            for (int i = 0; i < data.length; i++)
                FlSpot(i.toDouble(), data[i].value)
        ];

        final ys = data.map((e) => e.value).toList();
        final minY = ys.isEmpty ? 0.0 : ys.reduce((a, b) => a < b ? a : b);
        final maxY = ys.isEmpty ? 1.0 : ys.reduce((a, b) => a > b ? a : b);
        final rangeMin = minY <= 0 ? 0.0 : (minY * 0.9);
        final rangeMax = maxY == 0 ? 1.0 : (maxY * 1.1);

        return LineChartData(
            minX: 0,
            maxX: (data.length - 1).clamp(0, 999).toDouble(),
            minY: rangeMin,
            maxY: rangeMax,
            gridData: FlGridData(show: true),
            borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: _selected == _Metric.calories ? 60 : 40,
                        interval: _niceInterval(rangeMax),
                    ),
                ),
                bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                        interval: _labelInterval(data.length),
                        getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= data.length) return const SizedBox();

                            // Only show labels based on intervals
                            int interval = _labelInterval(data.length).toInt();
                            if (i % interval != 0) return const SizedBox();

                            return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                    data[i].shortLabel,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
                                    ),
                                ),
                            );
                        },
                    ),
                ),
            ),
            lineBarsData: [
                LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    barWidth: 4,
                    color: primary,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                                primary.withOpacity(0.3),
                                primary.withOpacity(0),
                            ],
                        ),
                    ),
                ),
            ],
        );
    }

    double _niceInterval(double maxY) {
        if (maxY <= 500) return 50;
        if (maxY <= 1500) return 100;
        if (maxY <= 3000) return 200;
        return 500;
    }

    double _labelInterval(int length) {
        if (length <= 10) return 1;
        if (length <= 20) return 2;
        if (length <= 40) return 3;
        return 4;
    }

    List<_DayValue> _seriesFor(_Metric metric) {
        switch (metric) {
            case _Metric.frequency:
                return _freq;
            case _Metric.duration:
                return _duration;
            case _Metric.intensity:
                return _intensity;
            case _Metric.calories:
                return _calories;
        }
    }

    List<_DayValue> _parseRows(List<Map<String, Object?>> rows, {required String dayKey, required String valueKey}) {
        final out = <_DayValue>[];
        for (final r in rows) {
            final dayStr = (r[dayKey] ?? '').toString();
            final rawVal = r[valueKey];
            final val = rawVal is num ? rawVal.toDouble() : double.tryParse(rawVal.toString()) ?? 0.0;

            DateTime? d;
            try {
                d = DateTime.parse(dayStr);
            } catch (_) {
                d = null;
            }
            if (d == null) continue;

            out.add(_DayValue(date: d, value: val));
        }
        out.sort((a, b) => a.date.compareTo(b.date));
        return out;
    }

    List<_DayValue> _takeTail(List<_DayValue> src, int n) {
        if (src.length <= n) return src;
        return src.sublist(src.length - n);
    }

    String _summaryTitle() {
        switch (_selected) {
            case _Metric.frequency:
                return 'Workout Frequency';
            case _Metric.duration:
                return 'Total Duration';
            case _Metric.intensity:
                return 'Average Intensity';
            case _Metric.calories:
                return 'Calories Logged';
        }
    }

    List<String> _summaryLines(List<_DayValue> series, _Metric metric) {
        if (series.isEmpty) {
            return ['No data yet. Log some entries to see insights.'];
        }

        final last = series.last.value;
        final avg = series.map((e) => e.value).reduce((a, b) => a + b) / series.length;
        final previous = series.length >= 2 ? series[series.length - 2].value : last;
        final change = last - previous;

        String unit;
        switch (metric) {
            case _Metric.frequency:
                unit = 'workouts';
                break;
            case _Metric.duration:
                unit = 'min';
                break;
            case _Metric.intensity:
                unit = 'RPE';
                break;
            case _Metric.calories:
                unit = 'kcal';
                break;
        }

        final changeText = change == 0
            ? 'No change vs last day.'
            : change > 0
                ? 'Up by ${change.toStringAsFixed(1)} $unit vs last day.'
                : 'Down by ${change.abs().toStringAsFixed(1)} $unit vs last day.';

        return [
            'Latest: ${last.toStringAsFixed(1)} $unit',
            'Average (${series.length} days): ${avg.toStringAsFixed(1)} $unit',
            changeText,
        ];
    }
}

class _DayValue {
    final DateTime date;
    final double value;

    _DayValue({required this.date, required this.value});

    String get shortLabel {
        final m = date.month.toString().padLeft(2, '0');
        final d = date.day.toString().padLeft(2, '0');
        return '$m/$d';
    }
}

class _EmptyState extends StatelessWidget {
    const _EmptyState();

    @override
    Widget build(BuildContext context) {
        return Center(
            child: Text(
                'No data to chart yet.\nLog workouts or calories to see insights.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.75),
                    ),
            ),
        );
    }
}