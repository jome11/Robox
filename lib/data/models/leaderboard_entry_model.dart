class LeaderboardEntryModel {
  final String userId;
  final String userName;
  final int rank;
  final double efficiency;
  final int tasksCompleted;

  const LeaderboardEntryModel({
    required this.userId,
    required this.userName,
    required this.rank,
    required this.efficiency,
    required this.tasksCompleted,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      userId: json['userId'].toString(),
      userName: json['userName']?.toString() ?? 'Unknown',
      rank: json['rank'] as int,
      efficiency: (json['efficiency'] as num).toDouble(),
      tasksCompleted: json['tasksCompleted'] as int,
    );
  }
}
