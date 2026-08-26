import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exercise.dart';
import '../models/workout_session.dart';
import '../models/workout_set.dart';
import '../providers/workout_provider.dart';
import 'exercise_log_screen.dart';

class ExerciseSelectionScreen extends StatefulWidget {
  final WorkoutSession session;

  const ExerciseSelectionScreen({super.key, required this.session});

  @override
  State<ExerciseSelectionScreen> createState() =>
      _ExerciseSelectionScreenState();
}

class _ExerciseSelectionScreenState extends State<ExerciseSelectionScreen> {
  late Future<List<WorkoutSet>> _setsFuture;
  String? _statsExerciseId;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _setsFuture =
        context.read<WorkoutProvider>().getSetsForSession(widget.session.id);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final exercises = provider.exercises;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session.name),
        actions: [
          TextButton(
            onPressed: () => _endWorkout(context),
            child: const Text('End Workout'),
          ),
        ],
      ),
      body: FutureBuilder<List<WorkoutSet>>(
        future: _setsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final sets = snapshot.data!;
          final setCounts = <String, int>{};
          for (final set in sets) {
            setCounts[set.exerciseId] = (setCounts[set.exerciseId] ?? 0) + 1;
          }
          final loggedExercises = exercises
              .where((e) => setCounts.containsKey(e.id))
              .toList();

          return Column(
            children: [
              if (loggedExercises.isNotEmpty)
                _SessionStatsPanel(
                  loggedExercises: loggedExercises,
                  sets: sets,
                  selectedExerciseId: _statsExerciseId,
                  onChanged: (id) => setState(() => _statsExerciseId = id),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    final count = setCounts[exercise.id] ?? 0;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: ListTile(
                        leading: const Icon(Icons.fitness_center),
                        title: Text(exercise.name),
                        subtitle: Text(exercise.muscleGroup),
                        trailing: count > 0
                            ? Chip(
                                label:
                                    Text('$count set${count == 1 ? '' : 's'}'))
                            : const Icon(Icons.chevron_right),
                        onTap: () => _openExercise(context, exercise),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _endWorkout(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  Future<void> _openExercise(BuildContext context, Exercise exercise) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ExerciseLogScreen(session: widget.session, exercise: exercise),
      ),
    );
    setState(_refresh);
  }
}

class _SessionStatsPanel extends StatelessWidget {
  final List<Exercise> loggedExercises;
  final List<WorkoutSet> sets;
  final String? selectedExerciseId;
  final ValueChanged<String?> onChanged;

  const _SessionStatsPanel({
    required this.loggedExercises,
    required this.sets,
    required this.selectedExerciseId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedId = selectedExerciseId ?? loggedExercises.first.id;
    final exerciseSets =
        sets.where((s) => s.exerciseId == selectedId).toList()
          ..sort((a, b) => a.setNumber.compareTo(b.setNumber));

    final bestSet = exerciseSets.isEmpty
        ? null
        : exerciseSets.reduce((a, b) => a.weightLbs > b.weightLbs ? a : b);
    final totalVolume =
        exerciseSets.fold<double>(0, (sum, s) => sum + s.volume);

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Session stats',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedId,
              isExpanded: true,
              menuMaxHeight: kMinInteractiveDimension * 4,
              items: loggedExercises
                  .map((e) => DropdownMenuItem(
                        value: e.id,
                        child: Text(e.name),
                      ))
                  .toList(),
              onChanged: onChanged,
              decoration: const InputDecoration(labelText: 'Exercise'),
            ),
            const SizedBox(height: 12),
            if (bestSet != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Best set: ${bestSet.weightLbs} lbs x ${bestSet.reps}'),
                  Text('Total volume: ${totalVolume.toStringAsFixed(0)} lbs'),
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
          ],
        ),
      ),
    );
  }
}
