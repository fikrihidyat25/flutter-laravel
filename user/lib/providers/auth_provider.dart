import 'package:flutter/material.dart';
import '/models/user.dart';
import '/services/api_service.dart';
import '/services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isAuthenticated = false;
  String? _token;
  bool _isLoading = true;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  bool get isLoading => _isLoading;

  Future<bool> checkAuthStatus() async {
    try {
      _isLoading = true;
      notifyListeners();

      // remember me method untuk auto login
      final rememberMe = await StorageService.getRememberMe();
      if (!rememberMe) {
        _isAuthenticated = false;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Get token dari storage
      final storedToken = await StorageService.getAuthToken();
      final sessionValid = await StorageService.isLoginSessionValid(maxHours: 1);
      
      if (storedToken != null && storedToken.isNotEmpty && sessionValid) {
        _token = storedToken;
        
        final result = await ApiService.getProfile();
        
        if (result['success']) {
          _user = result['data'] as User;
          _isAuthenticated = true;
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
        }
      }
      
      // kalau token tidak ditemukan, sesi tidak valid, atau validasi gagal
      await StorageService.clearAllData();
      _token = null;
      _user = null;
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return false;
      
    } catch (e) {
      _token = null;
      _user = null;
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return false;
    } finally {
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final result = await ApiService.login(email, password);
      if (result['success']) {
        final userData = result['data']['user'];
        final token = result['data']['token'];
        
        // token disimpan
        await StorageService.storeAuthToken(token);
        await StorageService.setLoginTimestampNow();
        
        _user = User(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          phone: userData['phone'] ?? '',
          createdAt: userData['created_at'] ?? DateTime.now().toIso8601String(),
          updatedAt: userData['updated_at'] ?? DateTime.now().toIso8601String(),
        );
        _token = token;
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String phone, String password) async {
    final result = await ApiService.register(name, email, phone, password);
    if (result['success']) {
      final userData = result['data']['user'];
      final token = result['data']['token'];
      
      await StorageService.storeAuthToken(token);
      await StorageService.setLoginTimestampNow();
      
      _user = User(
        id: userData['id'],
        name: userData['name'],
        email: userData['email'],
        phone: userData['phone'] ?? '',
        createdAt: userData['created_at'] ?? DateTime.now().toIso8601String(),
        updatedAt: userData['updated_at'] ?? DateTime.now().toIso8601String(),
      );
      _token = token;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
    }
    return result;
  }

  Future<void> logout() async {
    try {
      await ApiService.logout();
    } catch (e) {
    } finally {
      await StorageService.clearAllData();
      
      _token = null;
      _user = null;
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUser() async {
    await checkAuthStatus();
  }

  Future<void> clearAuth() async {
    await StorageService.clearAllData();
    _token = null;
    _user = null;
    _isAuthenticated = false;
    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> updateProfile(String name, String email, String phone) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await ApiService.updateProfile(name, email, phone);
      
      if (result['success']) {
        _user = result['data'] as User;
        _isLoading = false;
        notifyListeners();
        return {'success': true, 'message': 'Profile updated successfully'};
      } else {
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'message': result['message']};
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Error updating profile: $e'};
    }
  }
}