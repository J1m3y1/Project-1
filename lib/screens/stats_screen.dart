import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/exercise.dart';
import '../providers/workout_provider.dart';

enum _DateRange { week, month, threeMonths, year, all }

extension on _DateRange {
  String get label {
    switch (this) {
      case _DateRange.week:
        return '1W';
      case _DateRange.month:
        return '1M';
      case _DateRange.threeMonths:
        return '3M';
      case _DateRange.year:
        return '1Y';
      case _DateRange.all:
        return 'All';
    }
  }

  DateTime? cutoff(DateTime now) {
    switch (this) {
      case _DateRange.week:
        return now.subtract(const Duration(days: 7));
      case _DateRange.month:
        return now.subtract(const Duration(days: 30));
      case _DateRange.threeMonths:
        return now.subtract(const Duration(days: 90));
      case _DateRange.year:
        return now.subtract(const Duration(days: 365));
      case _DateRange.all:
        return null;
    }
  }
}

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Exercise? _selected;
  _DateRange _range = _DateRange.threeMonths;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final exercises = provider.exercises;

    if (exercises.isEmpty) {
      return const Center(child: Text('No exercises available.'));
    }

    _selected ??= exercises.first;
    final cutoff = _range.cutoff(DateTime.now());

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownMenu<Exercise>(
            initialSelection: _selected,
            expandedInsets: EdgeInsets.zero,
            menuHeight: kMinInteractiveDimension * 4,
            label: const Text('Exercise'),
            dropdownMenuEntries: exercises
                .map((e) => DropdownMenuEntry(value: e, label: e.name))
                .toList(),
            onSelected: (value) => setState(() => _selected = value),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<
                (List<Map<String, Object?>>, List<Map<String, Object?>>)>(
              future: _loadData(provider, _selected!.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final (progressRows, historyRows) = snapshot.data!;

                final chartRows = progressRows.where((row) {
                  if (cutoff == null) return true;
                  return DateTime.parse(row['date'] as String).isAfter(cutoff);
                }).toList();
                final setRows = historyRows.where((row) {
                  if (cutoff == null) return true;
                  return DateTime.parse(row['sessionDate'] as String)
                      .isAfter(cutoff);
                }).toList();

                return ListView(
                  children: [
                    if (chartRows.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text('No sets logged for this range.'),
                        ),
                      )
                    else
                      _ProgressChart(rows: chartRows),
                    const SizedBox(height: 16),
                    SegmentedButton<_DateRange>(
                      segments: _DateRange.values
                          .map((r) =>
                              ButtonSegment(value: r, label: Text(r.label)))
                          .toList(),
                      selected: {_range},
                      onSelectionChanged: (selection) =>
                          setState(() => _range = selection.first),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sets',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (setRows.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('No sets logged for this range.'),
                      )
                    else
                      ...setRows.map((row) {
                        final date =
                            DateTime.parse(row['sessionDate'] as String);
                        final weight = (row['weightLbs'] as num).toDouble();
                        final reps = row['reps'] as int;
                        return Card(
                          elevation: 1,
                          color: Theme.of(context).colorScheme.surface,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text('$weight lbs x $reps reps'),
                            subtitle: Text(
                              DateFormat.yMMMd().add_jm().format(date),
                            ),
                          ),
                        );
                      }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<(List<Map<String, Object?>>, List<Map<String, Object?>>)> _loadData(
      WorkoutProvider provider, String exerciseId) async {
    final progress = await provider.getProgressForExercise(exerciseId);
    final history = await provider.getHistoryForExercise(exerciseId);
    return (progress, history);
  }
}

class _ProgressChart extends StatelessWidget {
  final List<Map<String, Object?>> rows;

  const _ProgressChart({required this.rows});

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    final dates = <DateTime>[];
    for (var i = 0; i < rows.length; i++) {
      final weight = (rows[i]['maxWeight'] as num).toDouble();
      spots.add(FlSpot(i.toDouble(), weight));
      dates.add(DateTime.parse(rows[i]['date'] as String));
    }

    final maxWeight = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Best set: ${maxWeight.toStringAsFixed(1)} lbs',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 260,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= dates.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          DateFormat.Md().format(dates[index]),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Theme.of(context).colorScheme.primary,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
