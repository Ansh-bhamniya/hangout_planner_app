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
  // new api for get user id for currecnt user 
  static Future<String> getUserId() async {
    final token = await getToken(); // fetch from secure storage

    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'), // you must have this route in backend
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['_id']; // or data['user']['_id'] based on your backend
    } else {
      throw Exception('Failed to fetch user ID');
    }
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
  // new api is added 
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
    // print('data : ${response.body}');

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
    // print('macbook1 : ${response.statusCode}');    
    // print('macbook2 : ${response.body}');
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
    final body = jsonDecode(response.body);
    final data = body['data'];
    if (data != null && data['_id'] != null) {
      return data['_id'];
    } else {
      throw Exception("No _id in response: $body");
    }
  } else {
    throw Exception("Failed to fetch current user ID: ${response.body}");
  }
}
  // used in profile page 
static Future<Map<String, dynamic>> getCurrentUserDetails() async {
  final token = await getToken();
  final response = await http.get(
    Uri.parse('$baseUrl/auth/me'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data; // 👈 Directly return user object
    
  }
  throw Exception('Failed to fetch current user');
}


    static Future<Map<String, dynamic>> fetchNetwork() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('$baseUrl/auth/network'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final body = jsonDecode(res.body);
    if (res.statusCode == 200 && body['success'] == 'true') {
      return body['data'];
    }
    throw Exception('Failed to fetch network');
  }



static Future<List<dynamic>> fetchFoF() async {
  final token = await getToken();
  final res = await http.get(
    Uri.parse('$baseUrl/auth/friends-of-friends'),
    headers: {'Authorization': 'Bearer $token'},
  );

  final body = jsonDecode(res.body);
  if (res.statusCode == 200 && body['success'] == 'true') {
    return List<dynamic>.from(body['data']);
  } else {
    throw Exception('Failed to fetch friends of friends');
  }
}
static Future<List<dynamic>> fetchDirectFriends() async {
  final token = await getToken();
  final res = await http.get(
    Uri.parse('$baseUrl/auth/direct-friends'),
    headers: {'Authorization': 'Bearer $token'},
  );

  final body = jsonDecode(res.body);
  if (res.statusCode == 200 && body['success'] == 'true') {
    return List<dynamic>.from(body['data']);
  } else {
    throw Exception('Failed to fetch direct friends');
  }
}

// this is send trip request to 2 degree but only send by 1 degree 
static Future<void> sendTripRequest({
  // required String creatorId,
  required List<String> selectedIds,
  required String title,
  required String message,
}) async {
  final token = await getToken();

  final res = await http.post(
    Uri.parse('$baseUrl/auth/trips/create'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      "selectedIds": selectedIds,
      "title": title,
      "message": message,
    }),
  );

  final body = jsonDecode(res.body);
  print("📦 Response: $body");

  if (res.statusCode == 201) {
    // success
    return;
  } else {
    throw Exception('Failed to send trip request: ${body['message']}');
  }
}

  // ✅ Fetch incoming trip invitations
static Future<List<dynamic>> fetchIncomingTrips() async {
  final token = await getToken(); // <-- token must exist
  final response = await http.get(
    Uri.parse('$baseUrl/auth/trips/incoming'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to fetch incoming trips');
  }
}
    // ✅ Approve a specific trip by tripId
    static Future<void> approveTripRequest(String tripId) async {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/auth/trips/$tripId/approve'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to approve trip: ${response.body}");
      }
    }
  static Future<void> sendTripInvite(String tripId, String userId) async {
    final token = await getToken();

    final url = Uri.parse('$baseUrl/auth/trips/$tripId/invite/$userId');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    final body = jsonDecode(response.body);
    print(" invite_response : ${body}");
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to send trip invite');
    }
  }

static Future<List<String>> getFriendListOf(String userId) async {
  final token = await getToken();
  final res = await http.get(
    Uri.parse('$baseUrl/auth/direct-friends'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (res.statusCode == 200) {
    final body = jsonDecode(res.body);

    // Handle success: string vs bool in `success`
    final success = body['success'].toString().toLowerCase() == 'true';
    if (success && body['data'] is List) {
      final List<dynamic> friends = body['data'];
      return friends.map<String>((u) => u['_id'].toString()).toList();
    }
  }

  throw Exception('Failed to fetch direct friends');
}
// Add this method to your ApiService class

static Future<List<String>> getCreatorFriends(String creatorId) async {
  final token = await getToken();
  final res = await http.get(
    Uri.parse('$baseUrl/auth/users/$creatorId/friends'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (res.statusCode == 200) {
    final body = jsonDecode(res.body);
    final success = body['success'].toString().toLowerCase() == 'true';
    if (success && body['data'] is List) {
      final List<dynamic> friends = body['data'];
      return friends.map<String>((u) => u['_id'].toString()).toList();
    }
  }

  throw Exception('Failed to fetch creator friends');
}
}
