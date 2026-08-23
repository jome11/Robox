class LeaderboardEntryModel {
  final String userId;
  final String userName;
  final int rank;
  final double totalIncome;
  final int tasksCompleted;

  const LeaderboardEntryModel({
    required this.userId,
    required this.userName,
    required this.rank,
    required this.totalIncome,
    required this.tasksCompleted,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      userId: json['userId'].toString(),
      userName: json['userName']?.toString() ?? 'Unknown',
      rank: json['rank'] as int,
      totalIncome: (json['totalIncome'] as num).toDouble(),
      tasksCompleted: json['tasksCompleted'] as int,
    );
  }
}