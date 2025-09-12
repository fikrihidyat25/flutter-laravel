import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/transaction.dart';
import '../models/debt.dart';
import 'storage_service.dart';
import '../config/app_config.dart';

class ApiService {
  static final String baseUrl = AppConfig.baseUrl;

  // Helper method untuk mendapatkan token dari storage
  static Future<String?> _getToken() async {
    return await StorageService.getAuthToken();
  }

  // Helper method untuk membuat header
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    if (token == null) {
      return {'Content-Type': 'application/json', 'Accept': 'application/json'};
    }
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  //  Auth Methods 
  static Future<Map<String, dynamic>> register(String name, String email, String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirmation': password,
        }),
      );
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> logout() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Logged out successfully'};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Logout failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: headers,
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': User.fromJson(data)};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to get profile'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/user/password'),
        headers: headers,
        body: json.encode({
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPassword,
        }),
      );

      final decoded = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': decoded['message'] ?? 'Password berhasil diubah'};
      } else {
        final message = decoded is Map && decoded.containsKey('message')
            ? decoded['message']
            : 'Failed to change password';
        return {'success': false, 'message': message};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateProfile(String name, String email, String phone) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/user'),
        headers: headers,
        body: json.encode({
          'name': name,
          'email': email,
          'phone': phone,
        }),
      );

      final decoded = json.decode(response.body);
      if (response.statusCode == 200) {
        // Support either { user: {...} } or direct user object
        final payload = decoded is Map && decoded.containsKey('user') ? decoded['user'] : decoded;
        return { 'success': true, 'data': User.fromJson(payload) };
      } else {
        final message = decoded is Map && decoded.containsKey('message')
            ? decoded['message']
            : 'Failed to update profile';
        return { 'success': false, 'message': message };
      }
    } catch (e) {
      return { 'success': false, 'message': 'Network error: $e' };
    }
  }

  // Forgot Password Methods
  static Future<Map<String, dynamic>> requestPasswordReset(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({
          'phone': phone,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'message': data['message'] ?? 'OTP berhasil dikirim'};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Gagal mengirim OTP'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> resetPasswordWithOTP(String phone, String otp, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({
          'phone': phone,
          'otp': otp,
          'password': newPassword,
          'password_confirmation': newPassword,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'message': data['message'] ?? 'Password berhasil direset'};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Gagal reset password'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // --- Transaction Methods ---
  static Future<Map<String, dynamic>> getTransactions() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/transactions'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> transactionsList = (data is List) ? data : data['data'];
        final transactions = transactionsList.map((json) => Transaction.fromJson(json)).toList();
        return {'success': true, 'data': transactions};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to get transactions'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> createTransaction(Transaction transaction) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/transactions'),
        headers: headers,
        body: json.encode(transaction.toJson()),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': Transaction.fromJson(data)};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to create transaction'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateTransaction(Transaction transaction) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/transactions/${transaction.id}'),
        headers: headers,
        body: json.encode(transaction.toJson()),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': Transaction.fromJson(data)};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to update transaction'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteTransaction(int id) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/transactions/$id'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Transaction deleted successfully'};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to delete transaction'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteAllUserTransactions() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/transactions/all'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'All transactions deleted successfully'};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to delete all transactions'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // --- Debt Methods ---
  static Future<Map<String, dynamic>> getDebts() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/debts'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final debts = (data['data'] as List).map((json) => Debt.fromJson(json)).toList();
        return {'success': true, 'data': debts};
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': 'Token expired or invalid. Please login again.'};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to get debts. Status: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> createDebt(Debt debt) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/debts'),
        headers: headers,
        body: json.encode(debt.toJson()),
      );
      if (response.statusCode == 201) {
        final decoded = json.decode(response.body);
        final payload = decoded is Map && decoded.containsKey('data') ? decoded['data'] : decoded;
        return {'success': true, 'data': Debt.fromJson(payload)};
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to create debt',
          'raw': error,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateDebt(int id, Debt debt) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/debts/$id'),
        headers: headers,
        body: json.encode(debt.toJson()),
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final payload = decoded is Map && decoded.containsKey('data') ? decoded['data'] : decoded;
        return {'success': true, 'data': Debt.fromJson(payload)};
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to update debt',
          'raw': error,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteDebt(int id) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/debts/$id'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Debt deleted successfully'};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to delete debt'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteAllDebts() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/debts/all'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'All debts deleted successfully'};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to delete all debts'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Stats Methods
  static Future<Map<String, dynamic>> getBalance() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/stats/balance'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to get balance'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getDebtStats() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/stats/debts'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to get debt stats'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}