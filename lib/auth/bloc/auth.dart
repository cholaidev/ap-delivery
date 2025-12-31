import 'package:flutter_application_1/auth/bloc/auth_state.dart';
import 'package:flutter_application_1/models/usermodel.dart';

/// 🔒 Global Auth Manager
/// Stores the currently authenticated user, access token,
/// tenant info, and role — accessible anywhere in the app.
class AuthManager {
  static AuthSession? _session;
  static int? _tenantId;
  static int? _userId;
  static Map<String, dynamic>? _role;

  /// Access current session data (e.g., token)
  AuthSession? get session => _session;

  /// Access IDs and roles
  int? get tenantId => _tenantId;
  int? get userId => _userId;
  Map<String, dynamic>? get role => _role;

  /// Set session when login succeeds
  void setSession(Authenticated state) {
    _session = AuthSession(user: state.user, accessToken: state.token ?? '');
  }

  void clearSession() {
    _session = null;
    _tenantId = null;
    _userId = null;
    _role = null;
  }

  /// Example: set tenant data from API response
  void setTenant(Map<String, dynamic> tenantData) {
    _tenantId = tenantData['pivot']?['tenant_id'];
    _userId = tenantData['pivot']?['user_id'];
  }

  /// Set role from an install success state
  void setRole(Map<String, dynamic> roleData) {
    _role = roleData;
  }

  /// Clear all stored session data
  void clear() {
    _session = null;
    _tenantId = null;
    _userId = null;
    _role = null;
  }
}

/// 🧩 Session data
class AuthSession {
  final String accessToken;
  final UserModel user;

  AuthSession({required this.accessToken, required this.user});
}
