import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exercise.dart';
import '../models/workout_session.dart';
import '../models/workout_set.dart';
import '../providers/workout_provider.dart';

class ExerciseLogScreen extends StatefulWidget {
  final WorkoutSession session;
  final Exercise exercise;

  const ExerciseLogScreen({
    super.key,
    required this.session,
    required this.exercise,
  });

  @override
  State<ExerciseLogScreen> createState() => _ExerciseLogScreenState();
}

class _ExerciseLogScreenState extends State<ExerciseLogScreen> {
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  late Future<List<WorkoutSet>> _setsFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _refresh() {
    _setsFuture = context
        .read<WorkoutProvider>()
        .getSetsForSession(widget.session.id)
        .then((sets) =>
            sets.where((s) => s.exerciseId == widget.exercise.id).toList());
  }

  Future<void> _addSet() async {
    final weight = double.tryParse(_weightController.text);
    final reps = int.tryParse(_repsController.text);
    if (weight == null || reps == null) return;

    final provider = context.read<WorkoutProvider>();
    final existing = await _setsFuture;

    await provider.addSet(
      sessionId: widget.session.id,
      exerciseId: widget.exercise.id,
      weightLbs: weight,
      reps: reps,
      setNumber: existing.length + 1,
    );

    _weightController.clear();
    _repsController.clear();
    setState(_refresh);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.exercise.name)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Weight (lbs)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Reps'),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _addSet,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<WorkoutSet>>(
              future: _setsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final sets = snapshot.data!;
                if (sets.isEmpty) {
                  return const Center(
                    child: Text('No sets logged yet for this exercise.'),
                  );
                }
                return ListView.builder(
                  itemCount: sets.length,
                  itemBuilder: (context, index) {
                    final set = sets[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text('${set.setNumber}')),
                      title: Text('${set.weightLbs} lbs x ${set.reps} reps'),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () async {
                          await provider.deleteSet(set.id);
                          setState(_refresh);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done with this exercise'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
