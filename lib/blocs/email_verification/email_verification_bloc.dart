import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../API/firebase_manager.dart';

sealed class EmailVerificationEvent {}

final class EmailVerificationStarted extends EmailVerificationEvent {}

final class EmailVerificationChecked extends EmailVerificationEvent {}

sealed class EmailVerificationState {}

final class EmailVerificationInitial extends EmailVerificationState {}

final class EmailVerificationWaiting extends EmailVerificationState {}

final class EmailVerificationVerified extends EmailVerificationState {}

final class EmailVerificationFailure extends EmailVerificationState {
  EmailVerificationFailure(this.message);

  final String message;
}

class EmailVerificationBloc
    extends Bloc<EmailVerificationEvent, EmailVerificationState> {
  EmailVerificationBloc() : super(EmailVerificationInitial()) {
    on<EmailVerificationStarted>(_onStarted);
    on<EmailVerificationChecked>(_onChecked);
  }

  Timer? _timer;

  void _onStarted(
    EmailVerificationStarted event,
    Emitter<EmailVerificationState> emit,
  ) {
    emit(EmailVerificationWaiting());
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => add(EmailVerificationChecked()),
    );
  }

  Future<void> _onChecked(
    EmailVerificationChecked event,
    Emitter<EmailVerificationState> emit,
  ) async {
    try {
      final isVerified = await FirebaseManager.checkIfUserVerified();
      if (!isVerified) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(EmailVerificationFailure('No signed-in user found'));
        return;
      }

      await FirebaseManager.saveUserIntoDatabase(
        user.displayName ?? '',
        user.email ?? '',
        user,
      );
      await _timer?.cancel();
      emit(EmailVerificationVerified());
    } catch (e) {
      emit(EmailVerificationFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
