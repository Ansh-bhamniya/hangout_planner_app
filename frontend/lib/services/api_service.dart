import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ✅ Use this for Android Emulator
  static const String baseUrl = 'http://localhost:5050';

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
  // fetch all users 
  static Future<List<dynamic>> fetchAllUsers() async {
    final token = await getToken();
    print(' this_is_my_token ${token}');

    final response = await http.get(
      Uri.parse('$baseUrl/auth/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']; // assuming response.success_data returns { data: [...] }
    } else {
      throw Exception('Failed to load users');
    }
  }

  static Future<void> sendFollowRequest(String targetUserId) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse("$baseUrl/auth/follow/$targetUserId"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode != 200) {
      print("❌ Response body: ${response.body}");
      print("❌ Response status: ${response.statusCode}");
      throw Exception('Failed to send follow request');
    }

    print("✅ Follow request successful for $targetUserId");
  }

  // Get all follow requests receive
  static Future<List<dynamic>> fetchPendingFollowRequests() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/auth/pending-requests'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    print('body : ${response.statusCode}');    
    print('body : ${response.body}');
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Failed to load follow requests');
    }
  }
    // Accept a follow request
  static Future<void> acceptFollowRequest(String requesterId) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/auth/accept/$requesterId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    print("📥 Response status: ${response.statusCode}");
    print("📥 Response body: ${response.body}");
    if (response.statusCode != 200) {
      throw Exception('Failed to accept follow request');
    }
  }

  static Future<List<dynamic>> fetchFriends() async {
  final token = await getToken();
  final response = await http.get(
    Uri.parse('$baseUrl/auth/friends'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body)['data'];
  } else {
    throw Exception('Failed to load friends');
  }
}

  static Future<String> getCurrentUserId() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return data['_id'];
    } else {
      throw Exception('Failed to fetch current user ID');
    }
  }
  // used in profile page 
  static Future<Map<String, dynamic>> getCurrentUserDetails() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Failed to fetch current user');
    }
  }
}
