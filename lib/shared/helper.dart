import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/bloc/auth.dart';
import 'package:flutter_application_1/auth/bloc/auth_bloc.dart';
import 'package:flutter_application_1/auth/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 🧩 Basic initialization logic using only AuthBloc
Future<bool> preInstall(BuildContext context) async {
  final authState = BlocProvider.of<AuthBloc>(context).state;

  final releaseType = dotenv.env['RELEASE'] ?? 'dev';
  print('🔧 Release type: $releaseType');

  final authManager = AuthManager();

  if (authState is Authenticated) {
    // ✅ Save user session (optional if you use HydratedBloc)
    authManager.setSession(authState);

    print("✅ User session restored");
    return true;
  } else {
    print("🚫 No user session found");
    return false;
  }
}
