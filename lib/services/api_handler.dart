import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiHandler {
  static const String baseUrl = 'http://betgramapp.xyz';

  static Future<ApiResponse> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          ...?headers,
        },
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        statusCode: 500,
        errorMessage: "Errore di rete: $e",
      );
    }
  }

  static ApiResponse _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return ApiResponse(success: true, data: data, statusCode: response.statusCode); 
      } catch (e) {
        return ApiResponse(
          success: false,
          statusCode: response.statusCode,
          errorMessage: "Errore nel parsing JSON: $e",
        );
      }
    } else {
      return ApiResponse(
        success: false,
        data: data,
        statusCode: response.statusCode,
        errorMessage: data['error'],
      );
    }
  }
}

class ApiResponse {
  final bool success;
  final dynamic data;
  final int statusCode;
  final String? errorMessage;

  ApiResponse({
    required this.success,
    this.data,
    this.statusCode = 200,
    this.errorMessage,
  });
}
