import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/workout_session.dart';
import '../models/workout_set.dart';
import '../providers/workout_provider.dart';

class SessionSummaryScreen extends StatefulWidget {
  final WorkoutSession session;

  const SessionSummaryScreen({super.key, required this.session});

  @override
  State<SessionSummaryScreen> createState() => _SessionSummaryScreenState();
}

class _SessionSummaryScreenState extends State<SessionSummaryScreen> {
  late Future<List<WorkoutSet>> _setsFuture;

  @override
  void initState() {
    super.initState();
    _setsFuture =
        context.read<WorkoutProvider>().getSetsForSession(widget.session.id);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.session.name)),
      body: FutureBuilder<List<WorkoutSet>>(
        future: _setsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final sets = snapshot.data!;
          if (sets.isEmpty) {
            return const Center(
              child: Text('No sets were logged in this workout.'),
            );
          }

          final byExercise = <String, List<WorkoutSet>>{};
          for (final set in sets) {
            byExercise.putIfAbsent(set.exerciseId, () => []).add(set);
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 8),
                child: Text(
                  DateFormat.yMMMd().add_jm().format(widget.session.date),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              ...byExercise.entries.map((entry) {
                final exercise = provider.exerciseById(entry.key);
                final exerciseSets = entry.value
                  ..sort((a, b) => a.setNumber.compareTo(b.setNumber));
                final totalVolume =
                    exerciseSets.fold<double>(0, (sum, s) => sum + s.volume);

                return Card(
                  elevation: 2,
                  color: Theme.of(context).colorScheme.surface,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              exercise.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'Volume: ${totalVolume.toStringAsFixed(0)} lbs',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...exerciseSets.map(
                          (s) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              'Set ${s.setNumber}: ${s.weightLbs} lbs x ${s.reps} reps',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
