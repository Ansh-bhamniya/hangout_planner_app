import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ✅ Use this for Android Emulator
  static const String baseUrl = 'http://10.0.2.2:5050';

  // Save token to local storage
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

  // Get saved token
  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken') ?? '';
  }

  // ✅ Register API
  static Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': 'false',
          'message': 'Server error: ${response.statusCode}\n${response.body}',
        };
      }
    } catch (e) {
      return {'success': 'false', 'message': 'Exception: $e'};
    }
  }

  // ✅ Login API
  static Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phone, 'password': password}),
      );

      final decoded = jsonDecode(response.body);

      if (decoded['success'] == 'true' && decoded['data']['token'] != null) {
        await saveToken(decoded['data']['token']); // Save token locally
      }

      return decoded;
    } catch (e) {
      return {'success': 'false', 'message': 'Login failed: $e'};
    }
  }

  // ✅ OTP Verification API
  static Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phone, 'otp': otp}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': 'false', 'message': 'OTP verification failed: $e'};
    }
  }
}
