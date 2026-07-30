class PendingRequestModel {
  final String id;
  final String name;
  final String email;
  final DateTime requestedDate;

  const PendingRequestModel({
    required this.id,
    required this.name,
    required this.email,
    required this.requestedDate,
  });
}
