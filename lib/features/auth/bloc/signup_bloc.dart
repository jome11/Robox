import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repositories/auth_repository.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final AuthRepository _authRepository;

  SignupBloc(this._authRepository) : super(SignupInitial()) {
    on<SignupSubmitted>((event, emit) async {
      emit(SignupLoading());
      try {
        await _authRepository.signup(event.name, event.email, event.password);
        emit(SignupSuccess());
      } catch (e) {
        final errorStr = e.toString();
        if (errorStr.contains('EMAIL_EXISTS')) {
          emit(const SignupError('This email is already registered', field: 'email'));
        } else if (errorStr.contains('EMAIL_PENDING')) {
          emit(const SignupError('A request for this email is already pending approval', field: 'email'));
        } else {
          emit(const SignupError('Registration failed. Please try again.'));
        }
      }
    });
  }
}
