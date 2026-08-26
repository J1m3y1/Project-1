class WorkoutSession {
  final String id;
  final DateTime date;
  final String name;
  final DateTime? endedAt;

  WorkoutSession({
    required this.id,
    required this.date,
    required this.name,
    this.endedAt,
  });

  bool get isEnded => endedAt != null;

  Map<String, Object?> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'name': name,
        'endedAt': endedAt?.toIso8601String(),
      };

  factory WorkoutSession.fromMap(Map<String, Object?> map) => WorkoutSession(
        id: map['id'] as String,
        date: DateTime.parse(map['date'] as String),
        name: map['name'] as String,
        endedAt: map['endedAt'] == null
            ? null
            : DateTime.parse(map['endedAt'] as String),
      );
}
