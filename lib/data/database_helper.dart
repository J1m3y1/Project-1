import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'gym_tracker.db');
    return openDatabase(
      path,
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.delete('exercises');
      await _seedDefaultExercises(db);
    }
    if (oldVersion < 3) {
      await db.execute('DROP TABLE IF EXISTS sets');
      await db.execute('''
        CREATE TABLE sets (
          id TEXT PRIMARY KEY,
          sessionId TEXT NOT NULL,
          exerciseId TEXT NOT NULL,
          weightLbs REAL NOT NULL,
          reps INTEGER NOT NULL,
          setNumber INTEGER NOT NULL,
          FOREIGN KEY (sessionId) REFERENCES sessions (id) ON DELETE CASCADE,
          FOREIGN KEY (exerciseId) REFERENCES exercises (id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 5) {
      final columns = await db.rawQuery('PRAGMA table_info(sessions)');
      final hasEndedAt = columns.any((c) => c['name'] == 'endedAt');
      if (!hasEndedAt) {
        await db.execute('ALTER TABLE sessions ADD COLUMN endedAt TEXT');
      }
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE exercises (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        muscleGroup TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        name TEXT NOT NULL,
        endedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sets (
        id TEXT PRIMARY KEY,
        sessionId TEXT NOT NULL,
        exerciseId TEXT NOT NULL,
        weightLbs REAL NOT NULL,
        reps INTEGER NOT NULL,
        setNumber INTEGER NOT NULL,
        FOREIGN KEY (sessionId) REFERENCES sessions (id) ON DELETE CASCADE,
        FOREIGN KEY (exerciseId) REFERENCES exercises (id) ON DELETE CASCADE
      )
    ''');

    await _seedDefaultExercises(db);
  }

  Future<void> _seedDefaultExercises(Database db) async {
    final defaults = <Map<String, Object?>>[
      {'id': 'ex_weighted_pullups', 'name': 'Weighted Pull-Ups', 'muscleGroup': 'Back'},
      {'id': 'ex_cable_rows', 'name': 'Cable Rows', 'muscleGroup': 'Back'},
      {'id': 'ex_low_high_machine_row', 'name': 'Low-High Machine Row', 'muscleGroup': 'Back'},
      {'id': 'ex_machine_row', 'name': 'Machine Row', 'muscleGroup': 'Back'},
      {'id': 'ex_weighted_dips', 'name': 'Weighted Dips', 'muscleGroup': 'Chest'},
      {'id': 'ex_bench', 'name': 'Bench', 'muscleGroup': 'Chest'},
      {'id': 'ex_incline_bench', 'name': 'Incline Bench', 'muscleGroup': 'Chest'},
      {'id': 'ex_decline_bench', 'name': 'Decline Bench', 'muscleGroup': 'Chest'},
      {'id': 'ex_iso_lateral_chest_machine', 'name': 'Iso-Lateral Chest Machine', 'muscleGroup': 'Chest'},
      {'id': 'ex_iso_lateral_incline_chest_machine', 'name': 'Iso-Lateral Incline Chest Machine', 'muscleGroup': 'Chest'},
      {'id': 'ex_iso_lateral_decline_chest_machine', 'name': 'Iso-Lateral Decline Chest Machine', 'muscleGroup': 'Chest'},
      {'id': 'ex_chest_flys', 'name': 'Chest Flys', 'muscleGroup': 'Chest'},
      {'id': 'ex_ohp', 'name': 'Overhead Press', 'muscleGroup': 'Shoulders'},
      {'id': 'ex_lateral_raise_cable', 'name': 'Lateral Raise Cable', 'muscleGroup': 'Shoulders'},
      {'id': 'ex_lateral_raise_machine', 'name': 'Lateral Raise Machine', 'muscleGroup': 'Shoulders'},
      {'id': 'ex_bicep_curls', 'name': 'Bicep Curls', 'muscleGroup': 'Arms'},
      {'id': 'ex_hammer_curls', 'name': 'Hammer Curls', 'muscleGroup': 'Arms'},
      {'id': 'ex_seated_bicep_curls', 'name': 'Seated Bicep Curls', 'muscleGroup': 'Arms'},
      {'id': 'ex_cable_curls', 'name': 'Cable Curls', 'muscleGroup': 'Arms'},
      {'id': 'ex_deadlift', 'name': 'DeadLift', 'muscleGroup': 'Legs'},
      {'id': 'ex_squat', 'name': 'Squat', 'muscleGroup': 'Legs'},
      {'id': 'ex_leg_press', 'name': 'Leg Press', 'muscleGroup': 'Legs'},
      {'id': 'ex_machine_leg_press', 'name': 'Machine Leg Press', 'muscleGroup': 'Legs'},
      {'id': 'ex_machine_hamstring_curl', 'name': 'Machine Hamstring Curl', 'muscleGroup': 'Legs'},
      {'id': 'ex_machine_quad_curl', 'name': 'Machine Quad Curl', 'muscleGroup': 'Legs'},
      {'id': 'ex_romanian_deadlift', 'name': 'Romanian DeadLift', 'muscleGroup': 'Legs'},
    ];
    for (final exercise in defaults) {
      await db.insert('exercises', exercise);
    }
  }
}
