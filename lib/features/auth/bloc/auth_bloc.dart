import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AppStarted>((event, emit) async {
      final user = await _authRepository.getCurrentUser();
      emit(user != null ? AuthAuthenticated(user) : AuthUnauthenticated());
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await _authRepository.login(event.email, event.password);
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(const AuthError('Invalid credentials. Please check your email and password.'));
        }
      } catch (e) {
        final error = e.toString();
        if (error.contains('ACCOUNT_PENDING')) {
          emit(const AuthError('Your account is still pending admin approval.'));
        } else if (error.contains('TimeoutException') || error.contains('SocketException')) {
          emit(const AuthError('Connection failed. Please check your network or server status.'));
        } else {
          emit(AuthError('Authentication error: ${error.replaceAll('Exception: ', '')}'));
        }
      }
    });

    on<LogoutRequested>((event, emit) async {
      await _authRepository.logout();
      emit(AuthUnauthenticated());
    });

    on<UserUpdated>((event, emit) {
      emit(AuthAuthenticated(event.user));
    });

    add(AppStarted());
  }
}