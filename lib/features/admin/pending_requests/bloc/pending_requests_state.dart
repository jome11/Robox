part of 'pending_requests_bloc.dart';

abstract class PendingRequestsState extends Equatable {
  const PendingRequestsState();

  @override
  List<Object> get props => [];
}

class PendingRequestsLoading extends PendingRequestsState {}

class PendingRequestsLoaded extends PendingRequestsState {
  final List<PendingRequestModel> requests;
  const PendingRequestsLoaded(this.requests);
  @override
  List<Object> get props => [requests];
}

class PendingRequestsError extends PendingRequestsState {
  final String message;
  const PendingRequestsError(this.message);
  @override
  List<Object> get props => [message];
}

class RequestActionSuccess extends PendingRequestsState {
  final String message;
  const RequestActionSuccess(this.message);
  @override
  List<Object> get props => [message];
}
