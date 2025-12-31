import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/bloc/auth_bloc.dart';
import 'package:flutter_application_1/auth/repo/auth_repo.dart';
import 'package:flutter_application_1/auth/screen/login_page.dart';
import 'package:flutter_application_1/auth/screen/splash_screen.dart';
import 'package:flutter_application_1/delivery/bloc/deliver_bloc_bloc.dart';
import 'package:flutter_application_1/shared/theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
BuildContext get globalContext => navigatorKey.currentContext!;

/// ⚠️ For local API / self-signed SSL
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HttpOverrides.global = MyHttpOverrides();

  await dotenv.load(fileName: ".env");

  /// ✅ IMPORTANT: use UNIQUE storage directory
  final dir = await getApplicationDocumentsDirectory();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory('${dir.path}/emp'),
  );

  runApp(const MilkApp());
}

class MilkApp extends StatelessWidget {
  const MilkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => AuthRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(context.read<AuthRepository>()),
          ),
          BlocProvider(create: (_) => DeliverBlocBloc()),
        ],
        child: MaterialApp(
          title: 'Milk Company',
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          home: const SplashScreen(),
          routes: {'/login': (_) => const LoginPage()},
        ),
      ),
    );
  }
}
