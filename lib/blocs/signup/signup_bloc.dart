import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../API/firebase_manager.dart';

sealed class SignupEvent {}

final class SignupSubmitted extends SignupEvent {
  SignupSubmitted({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;
}

sealed class SignupState {}

final class SignupInitial extends SignupState {}

final class SignupLoading extends SignupState {}

final class SignupSuccess extends SignupState {}

final class SignupFailure extends SignupState {
  SignupFailure(this.message);

  final String message;
}

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  SignupBloc() : super(SignupInitial()) {
    on<SignupSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    SignupSubmitted event,
    Emitter<SignupState> emit,
  ) async {
    emit(SignupLoading());
    try {
      await FirebaseManager.createUser(event.name, event.email, event.password);
      await FirebaseManager.sendVerificationEmail();
      emit(SignupSuccess());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        emit(SignupFailure('Email already exists'));
        return;
      }
      emit(SignupFailure(e.code));
    } catch (e) {
      emit(SignupFailure(e.toString()));
    }
  }
}
