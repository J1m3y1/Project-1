class FriendAchievement {
  final String id;
  final String friendName;
  final String title;
  final String description;
  final DateTime date;

  FriendAchievement({
    required this.id,
    required this.friendName,
    required this.title,
    required this.description,
    required this.date,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'friendName': friendName,
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
      };

  factory FriendAchievement.fromMap(Map<String, Object?> map) =>
      FriendAchievement(
        id: map['id'] as String,
        friendName: map['friendName'] as String,
        title: map['title'] as String,
        description: map['description'] as String,
        date: DateTime.parse(map['date'] as String),
      );
}
