import '../models/pending_request_model.dart';

abstract class AdminRepository {
  Future<List<PendingRequestModel>> getPendingRequests();
  Future<void> approveRequest(String id);
  Future<void> rejectRequest(String id);
}

class AdminRepositoryImpl implements AdminRepository {
  // Mock internal list for session testing
  final List<PendingRequestModel> _pending = [
    PendingRequestModel(
      id: 'req_1',
      name: 'Sarah Connor',
      email: 'sarah@resistance.com',
      requestedDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
    PendingRequestModel(
      id: 'req_2',
      name: 'John Doe',
      email: 'john.doe@worker.com',
      requestedDate: DateTime.now().subtract(const Duration(hours: 4)),
    ),
  ];

  @override
  Future<List<PendingRequestModel>> getPendingRequests() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return List.from(_pending);
  }

  @override
  Future<void> approveRequest(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _pending.removeWhere((e) => e.id == id);
  }

  @override
  Future<void> rejectRequest(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _pending.removeWhere((e) => e.id == id);
  }
}
