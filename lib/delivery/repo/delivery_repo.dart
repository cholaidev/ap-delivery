import 'dart:convert';
import 'package:flutter_application_1/auth/bloc/auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DeliverRepository {
  final String? baseUrl = dotenv.env['API_URL'];

  String _getToken() {
    final token = AuthManager().session?.accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('Auth token missing');
    }
    return token;
  }

  Future<Map<String, dynamic>> fetchDeliveryItems({
    required int employeeId,
    String? filter,
    String? fromDate,
    String? toDate,
  }) async {
    final token = _getToken();

    final query = <String, String>{};

    if (filter != null) query['filter'] = filter;
    if (fromDate != null) query['from_date'] = fromDate;
    if (toDate != null) query['to_date'] = toDate;

    final uri = Uri.parse(
      '$baseUrl/supplies/supply-items/$employeeId',
    ).replace(queryParameters: query);

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body ?? {};
    } else {
      throw Exception('Failed to fetch delivery items');
    }
  }

  /// 🔹 Mark items delivered (employee + customers)
  Future<void> markDelivered({
    required int employeeId,
    required List<int> supplyIds,
  }) async {
    final token = _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/supplies/mark-delivered'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'employee_id': employeeId, 'supply_ids': supplyIds}),
    );

    if (response.statusCode != 200) {
      throw Exception('Delivery update failed');
    }
  }
}
