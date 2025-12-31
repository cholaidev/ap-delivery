import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/bloc/auth_bloc.dart';
import 'package:flutter_application_1/auth/bloc/auth_event.dart';
import 'package:flutter_application_1/auth/bloc/auth_state.dart';
import 'package:flutter_application_1/delivery/screen/delivery_page_screen.dart';
import 'package:flutter_application_1/models/usermodel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter phone number and password")),
      );
      return;
    }

    context.read<AuthBloc>().add(
      LoginRequested(
        phone: phone, // ✅ use phone instead of email
        password: password,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }

          if (state is Authenticated) {
            UserModel user = (state as Authenticated).user;
            print('check user model ${user.employeeId}');
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('logged in')));
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => DeliveryPage(employeeId: user.employeeId!),
              ),
            );
          }

          if (state is AuthFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Image.asset('assets/images/app_logo.png', height: 120),
                const SizedBox(height: 30),
                const Text(
                  "Welcome Back 👋",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 40),

                // 🔢 Phone number field
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  // inputFormatters: [
                  //   FilteringTextInputFormatter.digitsOnly,
                  // ],
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    counterText: "", // hides the counter below
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔒 Password field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 100,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _login,
                      child: const Text(
                        "Login",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),

                // const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
