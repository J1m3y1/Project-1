import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/workout_repository.dart';
import '../models/exercise.dart';
import '../models/workout_session.dart';
import '../models/workout_set.dart';

class WorkoutProvider extends ChangeNotifier {
  final WorkoutRepository _repository = WorkoutRepository();
  final _uuid = const Uuid();

  List<Exercise> _exercises = [];
  List<WorkoutSession> _sessions = [];
  bool _loading = false;

  List<Exercise> get exercises => _exercises;
  List<WorkoutSession> get sessions => _sessions;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _exercises = await _repository.getExercises();
    _sessions = await _repository.getSessions();
    _loading = false;
    notifyListeners();
  }

  Future<WorkoutSession> createSession(String name) async {
    final session = WorkoutSession(
      id: _uuid.v4(),
      date: DateTime.now(),
      name: name,
    );
    await _repository.addSession(session);
    _sessions = await _repository.getSessions();
    notifyListeners();
    return session;
  }

  Future<void> endSession(String sessionId) async {
    await _repository.endSession(sessionId, DateTime.now());
    _sessions = await _repository.getSessions();
    notifyListeners();
  }

  Future<void> deleteSession(String sessionId) async {
    await _repository.deleteSession(sessionId);
    _sessions = await _repository.getSessions();
    notifyListeners();
  }

  Future<Exercise> createExercise(String name, String muscleGroup) async {
    final exercise = Exercise(
      id: _uuid.v4(),
      name: name,
      muscleGroup: muscleGroup,
    );
    await _repository.addExercise(exercise);
    _exercises = await _repository.getExercises();
    notifyListeners();
    return exercise;
  }

  Future<List<WorkoutSet>> getSetsForSession(String sessionId) {
    return _repository.getSetsForSession(sessionId);
  }

  Future<void> addSet({
    required String sessionId,
    required String exerciseId,
    required double weightLbs,
    required int reps,
    required int setNumber,
  }) async {
    final set = WorkoutSet(
      id: _uuid.v4(),
      sessionId: sessionId,
      exerciseId: exerciseId,
      weightLbs: weightLbs,
      reps: reps,
      setNumber: setNumber,
    );
    await _repository.addSet(set);
    notifyListeners();
  }

  Future<void> deleteSet(String setId) async {
    await _repository.deleteSet(setId);
    notifyListeners();
  }

  Future<List<Map<String, Object?>>> getHistoryForExercise(String exerciseId) {
    return _repository.getHistoryForExercise(exerciseId);
  }

  Future<List<Map<String, Object?>>> getProgressForExercise(
      String exerciseId) {
    return _repository.getProgressForExercise(exerciseId);
  }

  Exercise exerciseById(String id) =>
      _exercises.firstWhere((e) => e.id == id);
}
