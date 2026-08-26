import 'package:sqflite/sqflite.dart';

import '../models/exercise.dart';
import '../models/workout_session.dart';
import '../models/workout_set.dart';
import 'database_helper.dart';

class WorkoutRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Exercise>> getExercises() async {
    final db = await _dbHelper.database;
    final rows = await db.query('exercises', orderBy: 'name ASC');
    return rows.map(Exercise.fromMap).toList();
  }

  Future<void> addExercise(Exercise exercise) async {
    final db = await _dbHelper.database;
    await db.insert('exercises', exercise.toMap());
  }

  Future<List<WorkoutSession>> getSessions() async {
    final db = await _dbHelper.database;
    final rows = await db.query('sessions', orderBy: 'date DESC');
    return rows.map(WorkoutSession.fromMap).toList();
  }

  Future<void> addSession(WorkoutSession session) async {
    final db = await _dbHelper.database;
    await db.insert('sessions', session.toMap());
  }

  Future<void> deleteSession(String sessionId) async {
    final db = await _dbHelper.database;
    await db.delete('sets', where: 'sessionId = ?', whereArgs: [sessionId]);
    await db.delete('sessions', where: 'id = ?', whereArgs: [sessionId]);
  }

  Future<List<WorkoutSet>> getSetsForSession(String sessionId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'sets',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
      orderBy: 'setNumber ASC',
    );
    return rows.map(WorkoutSet.fromMap).toList();
  }

  Future<void> addSet(WorkoutSet set) async {
    final db = await _dbHelper.database;
    await db.insert('sets', set.toMap());
  }

  Future<void> deleteSet(String setId) async {
    final db = await _dbHelper.database;
    await db.delete('sets', where: 'id = ?', whereArgs: [setId]);
  }

  /// All sets ever logged for a given exercise, most recent session first.
  Future<List<Map<String, Object?>>> getHistoryForExercise(
      String exerciseId) async {
    final db = await _dbHelper.database;
    return db.rawQuery('''
      SELECT sets.*, sessions.date as sessionDate
      FROM sets
      JOIN sessions ON sets.sessionId = sessions.id
      WHERE sets.exerciseId = ?
      ORDER BY sessions.date DESC, sets.setNumber ASC
    ''', [exerciseId]);
  }

  /// Best (max weight) set per session for an exercise, ascending by date -
  /// used to chart progress over time.
  Future<List<Map<String, Object?>>> getProgressForExercise(
      String exerciseId) async {
    final db = await _dbHelper.database;
    return db.rawQuery('''
      SELECT sessions.date as date, MAX(sets.weightLbs) as maxWeight
      FROM sets
      JOIN sessions ON sets.sessionId = sessions.id
      WHERE sets.exerciseId = ?
      GROUP BY sessions.id
      ORDER BY sessions.date ASC
    ''', [exerciseId]);
  }

  Future<Database> rawDb() => _dbHelper.database;
}
