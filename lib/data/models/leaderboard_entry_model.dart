class LeaderboardEntryModel {
  final String userId;
  final String userName;
  final String password;
  final int rank;
  final double efficiency;
  final int tasksCompleted;

  const LeaderboardEntryModel({
    required this.userId,
    required this.userName,
    required this.password,
    required this.rank,
    required this.efficiency,
    required this.tasksCompleted,
  });
}
