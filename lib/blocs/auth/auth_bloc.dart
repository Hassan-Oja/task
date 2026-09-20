import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../API/firebase_manager.dart';

sealed class AuthEvent {}

final class AuthStatusRequested extends AuthEvent {}

final class AuthLoggedOut extends AuthEvent {}

sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthAuthenticated extends AuthState {}

final class AuthUnauthenticated extends AuthState {}

final class AuthFailure extends AuthState {
  AuthFailure(this.message);

  final String message;
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthStatusRequested>(_onStatusRequested);
    on<AuthLoggedOut>(_onLoggedOut);
  }

  void _onStatusRequested(
    AuthStatusRequested event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthLoading());
    final user = FirebaseAuth.instance.currentUser;
    emit(user == null ? AuthUnauthenticated() : AuthAuthenticated());
  }

  Future<void> _onLoggedOut(
    AuthLoggedOut event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await FirebaseManager.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
