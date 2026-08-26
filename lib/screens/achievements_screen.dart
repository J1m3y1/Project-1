import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/friend_achievement_repository.dart';
import '../models/friend_achievement.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final _repository = FriendAchievementRepository();
  late Future<List<FriendAchievement>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.getFriendAchievements();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FriendAchievement>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final achievements = snapshot.data!;
        if (achievements.isEmpty) {
          return const Center(child: Text('No friend activity yet.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(achievement.friendName[0]),
                ),
                title: Text(achievement.title),
                subtitle: Text(
                  '${achievement.friendName} · ${achievement.description}',
                ),
                trailing: Text(
                  DateFormat.MMMd().format(achievement.date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
