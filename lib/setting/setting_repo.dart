import 'package:flutter_application_1/auth/bloc/auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class SettingRepository {
  final String? baseUrl = dotenv.env['API_URL'];

  String? _getToken() {
    final token = AuthManager().session?.accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('No access token found — user may not be logged in.');
    }
    return token;
  }

  Future<dynamic> getMilkPrice() async {
    try {
      final token = _getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/settings'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 getMilkPrice → Status: ${response.statusCode}');
      print('📦 getMilkPrice → Body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        final price = body['data']?['milk_price'];
        print('💰 Milk Price: ${price.runtimeType}');

        return num.tryParse(price);
      } else {
        print('❌ getMilkPrice failed — status: ${response.statusCode}');
        return null;
      }
    } catch (e, stackTrace) {
      print('❌ getMilkPrice ERROR: $e');
      print('📌 STACK TRACE:\n$stackTrace');
      return null;
    }
  }

  Future<void> updateMilkPrice(num? price) async {
    final token = _getToken();

    await http.post(
      Uri.parse('$baseUrl/settings'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'milk_price': price}),
    );
  }
}
