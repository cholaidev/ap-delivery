// auth_event.dart
sealed class AuthEvent {
  const AuthEvent();
}

/// 🔐 Login Event
class LoginRequested extends AuthEvent {
  final String phone;
  final String password;

  const LoginRequested({required this.phone, required this.password});
}

/// 🧾 Register Event
class RegisterRequested extends AuthEvent {
  final String name;
  final String phone;
  final String email;
  final String password;
  final String role;

  const RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.role,
  });
}

/// 🚪 Optional: Logout Event
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class AuthCheckStatus extends AuthEvent {}

class LogoutEvent extends AuthEvent {}
