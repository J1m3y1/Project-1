class WorkoutSet {
  final String id;
  final String sessionId;
  final String exerciseId;
  final double weightLbs;
  final int reps;
  final int setNumber;

  WorkoutSet({
    required this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.weightLbs,
    required this.reps,
    required this.setNumber,
  });

  double get volume => weightLbs * reps;

  Map<String, Object?> toMap() => {
        'id': id,
        'sessionId': sessionId,
        'exerciseId': exerciseId,
        'weightLbs': weightLbs,
        'reps': reps,
        'setNumber': setNumber,
      };

  factory WorkoutSet.fromMap(Map<String, Object?> map) => WorkoutSet(
        id: map['id'] as String,
        sessionId: map['sessionId'] as String,
        exerciseId: map['exerciseId'] as String,
        weightLbs: (map['weightLbs'] as num).toDouble(),
        reps: map['reps'] as int,
        setNumber: map['setNumber'] as int,
      );
}
