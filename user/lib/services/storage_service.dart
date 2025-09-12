import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  

  static const String _authTokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _rememberMeKey = 'remember_me';
  static const String _loginTimestampKey = 'login_timestamp';
  static const String _aiChatMessagesKey = 'ai_chat_messages';  
  static Future<void> storeAuthToken(String token) async {
    try {
      await _secureStorage.write(key: _authTokenKey, value: token);
    } catch (e) {
      rethrow;
    }
  }
  
  // Get token dari storage
  static Future<String?> getAuthToken() async {
    try {
      final token = await _secureStorage.read(key: _authTokenKey);
      if (token != null) {
      }
      return token;
    } catch (e) {
      return null;
    }
  }
  
  // hapus token dari storage
  static Future<void> removeAuthToken() async {
    try {
      await _secureStorage.delete(key: _authTokenKey);
    } catch (e) {
      rethrow;
    }
  }
  static Future<void> storeUserData(String userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, userData);
  }
  static Future<String?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userDataKey);
  }
  static Future<void> removeUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
  }
  static Future<void> setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, value);
  }
  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }
  static Future<void> clearAllData() async {
    await removeAuthToken();
    await removeUserData();
    await setRememberMe(false);
    await clearLoginTimestamp();
  }
    static Future<bool> hasValidCredentials() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }
  

  static Future<void> setLoginTimestampNow() async {
    final prefs = await SharedPreferences.getInstance();
    final nowMillis = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt(_loginTimestampKey, nowMillis);
  }

  static Future<int?> getLoginTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_loginTimestampKey);
  }

  static Future<void> clearLoginTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loginTimestampKey);
  }

  static Future<bool> isLoginSessionValid({int maxHours = 12}) async {
    final ts = await getLoginTimestamp();
    
    if (ts == null) {
      return false;
    }
    
    final loginTime = DateTime.fromMillisecondsSinceEpoch(ts);
    final now = DateTime.now();
    final diff = now.difference(loginTime);
    
    return diff.inHours < maxHours;
  }

  static Future<bool> isLoginSessionValidSeconds({int maxSeconds = 43200}) async {
    final ts = await getLoginTimestamp();
    
    if (ts == null) {
      return false;
    }
    
    final loginTime = DateTime.fromMillisecondsSinceEpoch(ts);
    final now = DateTime.now();
    final diff = now.difference(loginTime);
    
    return diff.inSeconds < maxSeconds;
  }

  // AI Chat persistence
  static Future<void> saveAiChatMessages(String jsonMessages) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_aiChatMessagesKey, jsonMessages);
  }

  static Future<String?> getAiChatMessages() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_aiChatMessagesKey);
  }

  static Future<void> clearAiChatMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_aiChatMessagesKey);
  }
}
