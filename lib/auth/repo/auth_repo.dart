import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthRepository {
  final String? baseUrl = dotenv.env['API_URL'];

  /// 🧩 User login
  Future<Map<String, dynamic>> login(String phone, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Accept': 'application/json'},
      body: {'phone': phone, 'password': password},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {
        "message": data["message"],
        "token": data["token"],
        "user": data["user"],
      };
    } else {
      throw Exception(data["message"] ?? "Login failed");
    }
  }

  /// 🧾 User register

  // Future<UserModel?> getSavedUser() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final userData = prefs.getString('user');
  //   if (userData != null) {
  //     return UserModel.fromJson(jsonDecode(userData));
  //   }
  //   return null;
  // }
}
