import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator (maps to localhost on host machine)
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  // static const String baseUrl = 'http://192.168.18.8/api';

  // Get token from shared preferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Get admin token
  static Future<String?> getAdminToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('admin_token');
  }

  // Save token to shared preferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Save admin token
  static Future<void> saveAdminToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_token', token);
  }

  // Remove token from shared preferences
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_data');
  }

  // Remove admin token
  static Future<void> removeAdminToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_token');
    await prefs.remove('admin_data');
  }

  // Save user data
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
  }

  // Save admin data
  static Future<void> saveAdminData(Map<String, dynamic> adminData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_data', jsonEncode(adminData));
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('user_data');
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  // Get admin data
  static Future<Map<String, dynamic>?> getAdminData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('admin_data');
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  // Check if logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Check if admin logged in
  static Future<bool> isAdminLoggedIn() async {
    final token = await getAdminToken();
    return token != null;
  }

  // Get headers with token
  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get admin headers with token
  static Future<Map<String, String>> getAdminHeaders() async {
    final token = await getAdminToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // User Registration
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        // Don't auto-save token, let user login manually
        return {'success': true, 'data': data['data']};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Registration failed',
      };
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // User Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        await saveToken(data['data']['token']);
        await saveUserData(data['data']['user']);
        return {'success': true, 'data': data['data']};
      }

      return {'success': false, 'message': data['message'] ?? 'Login failed'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // User Logout
  static Future<Map<String, dynamic>> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: await getHeaders(),
      );
      await removeToken();
      return {'success': true, 'message': 'Logged out'};
    } catch (e) {
      await removeToken();
      return {'success': true, 'message': 'Logged out'};
    }
  }

  // Get current user profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: await getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        await saveUserData(data['data']);
        return {'success': true, 'data': data['data']};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to get profile',
      };
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? birthDate,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (phone != null) body['phone'] = phone;
      if (birthDate != null) body['birth_date'] = birthDate;

      final response = await http.put(
        Uri.parse('$baseUrl/profile'),
        headers: await getHeaders(),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        await saveUserData(data['data']);
        return {'success': true, 'data': data['data']};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to update',
      };
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Upload profile picture
  static Future<Map<String, dynamic>> uploadProfilePicture(
      File imageFile) async {
    try {
      final token = await getToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/profile/picture'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });

      request.files.add(await http.MultipartFile.fromPath(
        'profile_picture',
        imageFile.path,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Update stored user data with new profile picture
        final userData = await getUserData();
        if (userData != null) {
          userData['profile_picture'] = data['data']['profile_picture'];
          userData['profile_picture_url'] = data['data']['profile_picture_url'];
          await saveUserData(userData);
        }
        return {
          'success': true,
          'data': data['data'],
          'message': 'Profile picture uploaded successfully',
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to upload profile picture',
      };
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Delete profile picture
  static Future<Map<String, dynamic>> deleteProfilePicture() async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/profile/picture'),
        headers: await getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Update stored user data to remove profile picture
        final userData = await getUserData();
        if (userData != null) {
          userData['profile_picture'] = null;
          userData['profile_picture_url'] = null;
          await saveUserData(userData);
        }
        return {'success': true, 'message': 'Profile picture deleted'};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to delete profile picture',
      };
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Save Screening Result
  static Future<Map<String, dynamic>> saveScreeningResult({
    required Map<String, dynamic> answers,
    required String resultCategory,
    required String resultDescription,
    required int totalScore,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/screening'),
        headers: await getHeaders(),
        body: jsonEncode({
          'answers': answers,
          'result_category': resultCategory,
          'result_description': resultDescription,
          'total_score': totalScore,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      }

      return {'success': false, 'message': data['message'] ?? 'Failed to save'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Get Screening History
  static Future<Map<String, dynamic>> getScreeningHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/screening/history'),
        headers: await getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to fetch',
      };
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Delete screening result
  static Future<Map<String, dynamic>> deleteScreening(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/screening/$id'),
        headers: await getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to delete',
      };
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Get screening questions
  static Future<Map<String, dynamic>> getScreeningQuestions({
    String? category,
  }) async {
    try {
      String url = '$baseUrl/questions';
      if (category != null) {
        url += '?category=$category';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to fetch questions',
      };
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ============== ADMIN API METHODS ==============

  // Admin Login
  static Future<Map<String, dynamic>> adminLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        await saveAdminToken(data['data']['token']);
        await saveAdminData(data['data']['admin']);
        return {'success': true, 'data': data['data']};
      }

      return {'success': false, 'message': data['message'] ?? 'Login failed'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Admin Logout
  static Future<Map<String, dynamic>> adminLogout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/admin/logout'),
        headers: await getAdminHeaders(),
      );
      await removeAdminToken();
      return {'success': true, 'message': 'Logged out'};
    } catch (e) {
      await removeAdminToken();
      return {'success': true, 'message': 'Logged out'};
    }
  }

  // Admin - Get All Users
  static Future<Map<String, dynamic>> adminGetUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: await getAdminHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to fetch users',
      };
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Admin - Delete User
  static Future<Map<String, dynamic>> adminDeleteUser(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/users/$id'),
        headers: await getAdminHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to delete user',
      };
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Admin - Get All Screening Questions
  static Future<Map<String, dynamic>> adminGetQuestions({
    String? category,
    bool? active,
  }) async {
    try {
      String url = '$baseUrl/admin/screening-questions';
      final params = <String>[];
      if (category != null) params.add('category=$category');
      if (active != null) params.add('active=$active');
      if (params.isNotEmpty) url += '?${params.join('&')}';

      final response = await http.get(
        Uri.parse(url),
        headers: await getAdminHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to fetch questions',
      };
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Admin - Create Question
  static Future<Map<String, dynamic>> adminCreateQuestion({
    required String questionText,
    required String category,
    List<Map<String, dynamic>>? options,
    int? order,
    bool isActive = true,
  }) async {
    try {
      final body = {
        'question_text': questionText,
        'category': category,
        'is_active': isActive,
      };
      if (options != null) body['options'] = options;
      if (order != null) body['order'] = order;

      final response = await http.post(
        Uri.parse('$baseUrl/admin/screening-questions'),
        headers: await getAdminHeaders(),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        return {'success': true, 'data': data['data']};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to create question',
      };
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Admin - Update Question
  static Future<Map<String, dynamic>> adminUpdateQuestion({
    required int id,
    String? questionText,
    String? category,
    List<Map<String, dynamic>>? options,
    int? order,
    bool? isActive,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (questionText != null) body['question_text'] = questionText;
      if (category != null) body['category'] = category;
      if (options != null) body['options'] = options;
      if (order != null) body['order'] = order;
      if (isActive != null) body['is_active'] = isActive;

      final response = await http.put(
        Uri.parse('$baseUrl/admin/screening-questions/$id'),
        headers: await getAdminHeaders(),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to update question',
      };
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Admin - Delete Question
  static Future<Map<String, dynamic>> adminDeleteQuestion(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/screening-questions/$id'),
        headers: await getAdminHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to delete question',
      };
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Admin - Toggle Question Active Status
  static Future<Map<String, dynamic>> adminToggleQuestionActive(int id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/screening-questions/$id/toggle-active'),
        headers: await getAdminHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to toggle status',
      };
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Admin - Get All Screening Results
  static Future<Map<String, dynamic>> adminGetScreeningResults({
    int? userId,
    String? category,
    int page = 1,
  }) async {
    try {
      String url = '$baseUrl/admin/screening-results?page=$page';
      if (userId != null) url += '&user_id=$userId';
      if (category != null) url += '&category=$category';

      final response = await http.get(
        Uri.parse(url),
        headers: await getAdminHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to fetch results',
      };
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Admin - Delete Screening Result
  static Future<Map<String, dynamic>> adminDeleteScreeningResult(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/screening-results/$id'),
        headers: await getAdminHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to delete result',
      };
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Admin - Get Statistics
  static Future<Map<String, dynamic>> adminGetStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/statistics'),
        headers: await getAdminHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to fetch statistics',
      };
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
