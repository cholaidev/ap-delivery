import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/bloc/auth_bloc.dart';
import 'package:flutter_application_1/auth/bloc/auth_state.dart';
import 'package:flutter_application_1/auth/screen/login_page.dart';
import 'package:flutter_application_1/delivery/screen/delivery_page_screen.dart';
import 'package:flutter_application_1/models/usermodel.dart';
import 'package:flutter_application_1/shared/helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await Future.delayed(const Duration(seconds: 1)); // splash delay
    final authBlocState = BlocProvider.of<AuthBloc>(context).state;
    final appSetup = await preInstall(context);

    if (appSetup) {
      if (authBlocState is Authenticated) {
        UserModel user = (authBlocState as Authenticated).user;
        print('check user model ${user.id}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DeliveryPage(employeeId: user.employeeId!),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Loading...")));
  }
}
