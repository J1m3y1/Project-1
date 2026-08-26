class WorkoutSession {
  final String id;
  final DateTime date;
  final String name;

  WorkoutSession({
    required this.id,
    required this.date,
    required this.name,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'name': name,
      };

  factory WorkoutSession.fromMap(Map<String, Object?> map) => WorkoutSession(
        id: map['id'] as String,
        date: DateTime.parse(map['date'] as String),
        name: map['name'] as String,
      );
}
