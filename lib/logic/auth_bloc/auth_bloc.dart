import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc(this.authService) : super(AuthInitial()) {
    
    on<AuthCheckRequested>((event, emit) async {
      final user = authService.currentUser;
      if (user != null) {
        // Lấy profile từ service để có username
        final profile = await authService.getUserProfile();
        emit(AuthAuthenticated(user.uid, profile?['username'] ?? "Thành viên"));
      } else {
        emit(AuthUnauthenticated());
      }
    });

    on<AuthSignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authService.signUp(
          email: event.email,
          password: event.password,
          username: event.username,
        );
        final user = authService.currentUser;
        emit(AuthAuthenticated(user!.uid, event.username));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final credential = await authService.signIn(event.email, event.password);
        final profile = await authService.getUserProfile();
        emit(AuthAuthenticated(credential.user!.uid, profile?['username'] ?? "Thành viên"));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<AuthForgotPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authService.sendPasswordReset(event.email);
        emit(AuthForgotPasswordEmailSent());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<AuthLogoutRequested>((event, emit) async {
      await authService.signOut();
      emit(AuthUnauthenticated());
    });
  }
}