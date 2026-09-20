import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../API/firebase_manager.dart';

sealed class LoginEvent {}

final class LoginSubmitted extends LoginEvent {
  LoginSubmitted({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}

sealed class LoginState {}

final class LoginInitial extends LoginState {}

final class LoginLoading extends LoginState {}

final class LoginSuccess extends LoginState {
  LoginSuccess({required this.isEmailVerified});

  final bool isEmailVerified;
}

final class LoginFailure extends LoginState {
  LoginFailure(this.message);

  final String message;
}

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      await FirebaseManager.loginUser(event.email, event.password);
      final isEmailVerified =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;
      emit(LoginSuccess(isEmailVerified: isEmailVerified));
    } on FirebaseAuthException catch (e) {
      emit(LoginFailure(e.code));
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}
