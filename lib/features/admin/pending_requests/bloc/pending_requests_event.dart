part of 'pending_requests_bloc.dart';

abstract class PendingRequestsEvent extends Equatable {
  const PendingRequestsEvent();

  @override
  List<Object> get props => [];
}

class FetchPendingRequests extends PendingRequestsEvent {}

class ApproveRequest extends PendingRequestsEvent {
  final String id;
  const ApproveRequest(this.id);
  @override
  List<Object> get props => [id];
}

class RejectRequest extends PendingRequestsEvent {
  final String id;
  const RejectRequest(this.id);
  @override
  List<Object> get props => [id];
}
