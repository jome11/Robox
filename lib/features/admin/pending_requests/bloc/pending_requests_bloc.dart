import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../data/models/pending_request_model.dart';
import '../../../../data/repositories/admin_repository.dart';

part 'pending_requests_event.dart';
part 'pending_requests_state.dart';

class PendingRequestsBloc extends Bloc<PendingRequestsEvent, PendingRequestsState> {
  final AdminRepository _adminRepository;

  PendingRequestsBloc(this._adminRepository) : super(PendingRequestsLoading()) {
    on<FetchPendingRequests>((event, emit) async {
      emit(PendingRequestsLoading());
      try {
        final requests = await _adminRepository.getPendingRequests();
        emit(PendingRequestsLoaded(requests));
      } catch (e) {
        emit(const PendingRequestsError('Failed to load pending requests'));
      }
    });

    on<ApproveRequest>((event, emit) async {
      try {
        await _adminRepository.approveRequest(event.id);
        add(FetchPendingRequests());
      } catch (e) {
        emit(const PendingRequestsError('Failed to approve request'));
      }
    });

    on<RejectRequest>((event, emit) async {
      try {
        await _adminRepository.rejectRequest(event.id);
        add(FetchPendingRequests());
      } catch (e) {
        emit(const PendingRequestsError('Failed to reject request'));
      }
    });
  }
}
