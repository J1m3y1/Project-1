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
      version: 9,
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
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS friend_achievements (
          id TEXT PRIMARY KEY,
          friendName TEXT NOT NULL,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          date TEXT NOT NULL
        )
      ''');
      await _seedFriendAchievements(db);
    }
    if (oldVersion < 5) {
      final columns = await db.rawQuery('PRAGMA table_info(sessions)');
      final hasEndedAt = columns.any((c) => c['name'] == 'endedAt');
      if (!hasEndedAt) {
        await db.execute('ALTER TABLE sessions ADD COLUMN endedAt TEXT');
      }
    }
    if (oldVersion < 6) {
      await _seedV6Exercises(db);
    }
    if (oldVersion < 7) {
      await db.insert(
        'exercises',
        {
          'id': 'ex_seated_single_arm_seated_row',
          'name': 'Seated Single Arm Seated Row',
          'muscleGroup': 'Back',
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    if (oldVersion < 8) {
      await db.delete('friend_achievements');
      await _seedFriendAchievements(db);
    }
    if (oldVersion < 9) {
      await db.delete('friend_achievements');
      await _seedFriendAchievements(db);
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

    await db.execute('''
      CREATE TABLE friend_achievements (
        id TEXT PRIMARY KEY,
        friendName TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    await _seedDefaultExercises(db);
    await _seedFriendAchievements(db);
  }

  Future<void> _seedFriendAchievements(Database db) async {
    final now = DateTime.now();
    final defaults = <Map<String, Object?>>[
      {
        'id': 'fa_hoa_bench',
        'friendName': 'Hoa',
        'title': 'New PR: Bench Press',
        'description': 'Hit 100 lbs x 2 reps',
        'date': now.subtract(const Duration(hours: 5)).toIso8601String(),
      },
      {
        'id': 'fa_cardin_deadlift',
        'friendName': 'Cardin',
        'title': 'New PR: Deadlift',
        'description': 'Hit 245 lbs x 1 rep',
        'date': now.subtract(const Duration(days: 1)).toIso8601String(),
      },
      {
        'id': 'fa_vy_dips',
        'friendName': 'Vy',
        'title': 'New PR: Weighted Dips',
        'description': 'Hit 60 lbs x 10 reps',
        'date': now.subtract(const Duration(days: 2)).toIso8601String(),
      },
      {
        'id': 'fa_teydenn_bench',
        'friendName': 'Teydenn',
        'title': 'New PR: Bench',
        'description': 'Hit 145 lbs x 2 reps',
        'date': now.subtract(const Duration(days: 4)).toIso8601String(),
      },
      {
        'id': 'fa_you_pullups',
        'friendName': 'You',
        'title': 'New PR: Weighted Pull-Ups',
        'description': 'Hit 115 lbs x 4 reps',
        'date': now.subtract(const Duration(hours: 1)).toIso8601String(),
      },
    ];
    for (final achievement in defaults) {
      await db.insert('friend_achievements', achievement);
    }
  }

  Future<void> _seedV6Exercises(Database db) async {
    final defaults = <Map<String, Object?>>[
      {'id': 'ex_tricep_pushdown', 'name': 'Tricep Pushdown', 'muscleGroup': 'Arms'},
      {'id': 'ex_seated_tricep_pushdown', 'name': 'Seated Tricep Pushdown', 'muscleGroup': 'Arms'},
      {'id': 'ex_single_arm_tricep_pushdown', 'name': 'Single Arm Tricep Pushdown', 'muscleGroup': 'Arms'},
    ];
    for (final exercise in defaults) {
      await db.insert(
        'exercises',
        exercise,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<void> _seedDefaultExercises(Database db) async {
    final defaults = <Map<String, Object?>>[
      {'id': 'ex_weighted_pullups', 'name': 'Weighted Pull-Ups', 'muscleGroup': 'Back'},
      {'id': 'ex_cable_rows', 'name': 'Cable Rows', 'muscleGroup': 'Back'},
      {'id': 'ex_low_high_machine_row', 'name': 'Low-High Machine Row', 'muscleGroup': 'Back'},
      {'id': 'ex_machine_row', 'name': 'Machine Row', 'muscleGroup': 'Back'},
      {'id': 'ex_seated_single_arm_seated_row', 'name': 'Seated Single Arm Seated Row', 'muscleGroup': 'Back'},
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
      {'id': 'ex_tricep_pushdown', 'name': 'Tricep Pushdown', 'muscleGroup': 'Arms'},
      {'id': 'ex_seated_tricep_pushdown', 'name': 'Seated Tricep Pushdown', 'muscleGroup': 'Arms'},
      {'id': 'ex_single_arm_tricep_pushdown', 'name': 'Single Arm Tricep Pushdown', 'muscleGroup': 'Arms'},
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
