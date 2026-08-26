class Exercise {
  final String id;
  final String name;
  final String muscleGroup;

  Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'muscleGroup': muscleGroup,
      };

  factory Exercise.fromMap(Map<String, Object?> map) => Exercise(
        id: map['id'] as String,
        name: map['name'] as String,
        muscleGroup: map['muscleGroup'] as String,
      );
}
