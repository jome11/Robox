import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await _authRepository.login(event.email, event.password);
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(const AuthError('Invalid credentials'));
        }
      } catch (e) {
        if (e.toString().contains('ACCOUNT_PENDING')) {
          emit(const AuthError('Your account is still pending admin approval'));
        } else {
          emit(AuthError('Network error: ${e.toString()}'));
        }
      }
    });

    on<LogoutRequested>((event, emit) {
      emit(AuthInitial());
    });
  }
}
