import '../models/friend_achievement.dart';
import 'database_helper.dart';

class FriendAchievementRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<FriendAchievement>> getFriendAchievements() async {
    final db = await _dbHelper.database;
    final rows = await db.query('friend_achievements', orderBy: 'date DESC');
    return rows.map(FriendAchievement.fromMap).toList();
  }

  Future<void> addFriendAchievement(FriendAchievement achievement) async {
    final db = await _dbHelper.database;
    await db.insert('friend_achievements', achievement.toMap());
  }
}
