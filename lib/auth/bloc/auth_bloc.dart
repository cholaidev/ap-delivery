import 'package:flutter_application_1/auth/repo/auth_repo.dart';
import 'package:flutter_application_1/models/usermodel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'auth_event.dart';
import 'auth_state.dart';
import 'auth.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutEvent>(_onLogout);
  }

  /// ✅ Prevent collision with old apps
  @override
  String get id => 'emp';

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await authRepository.login(event.phone, event.password);

      final user = UserModel.fromJson(result['user']);
      final token = result['token'];

      AuthManager().setSession(Authenticated(user, token));

      emit(Authenticated(user, token));
    } catch (e, stack) {
      print('❌ Login error: $e');
      print('🧱 StackTrace: $stack');
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      AuthManager().clearSession();
      await HydratedBloc.storage.clear();
      emit(Unauthenticated());
    } catch (_) {
      emit(Unauthenticated());
    }
  }

  /// ✅ SAVE (JSON ONLY)
  @override
  Map<String, dynamic>? toJson(AuthState state) {
    if (state is Authenticated) {
      return {
        'user': state.user.toJson(), // 👈 MUST be json
        'token': state.token,
      };
    }
    return null;
  }

  /// ✅ RESTORE
  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    try {
      final user = UserModel.fromJson(json['user']);
      final token = json['token'];

      AuthManager().setSession(Authenticated(user, token));

      return Authenticated(user, token);
    } catch (e) {
      print('❌ Restore error: $e');
      return null;
    }
  }
}
