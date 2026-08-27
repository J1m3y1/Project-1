import '../models/friend_achievement.dart';

/// Placeholder data source for the friends/achievements feed.
///
/// There is no backend or auth wired up yet, so this returns static
/// in-memory data. Swap this for a real API/repository once a social
/// backend exists.
class MockFriendsRepository {
  Future<List<FriendAchievement>> getFriendAchievements() async {
    final now = DateTime.now();
    return [
      FriendAchievement(
        id: 'a1',
        friendName: 'Alex',
        title: 'New PR: Bench Press',
        description: 'Hit 225 lbs x 3 reps',
        date: now.subtract(const Duration(hours: 5)),
      ),
      FriendAchievement(
        id: 'a2',
        friendName: 'Sam',
        title: '7-day streak',
        description: 'Worked out 7 days in a row',
        date: now.subtract(const Duration(days: 1)),
      ),
      FriendAchievement(
        id: 'a3',
        friendName: 'Jordan',
        title: 'New PR: Deadlift',
        description: 'Hit 405 lbs x 1 rep',
        date: now.subtract(const Duration(days: 2)),
      ),
      FriendAchievement(
        id: 'a4',
        friendName: 'Casey',
        title: '50 workouts logged',
        description: 'Reached 50 total sessions tracked',
        date: now.subtract(const Duration(days: 4)),
      ),
    ];
  }
}
