import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static Future<SharedPreferences> get _instance async =>
      await SharedPreferences.getInstance();

  /// Generic Setters
  Future<bool> setString(String key, String value) async {
    final prefs = await _instance;
    return prefs.setString(key, value);
  }

  Future<bool> setInt(String key, int value) async {
    final prefs = await _instance;
    return prefs.setInt(key, value);
  }

  Future<bool> setBool(String key, bool value) async {
    final prefs = await _instance;
    return prefs.setBool(key, value);
  }

  /// Generic Getters
  Future<String?> getString(String key) async {
    final prefs = await _instance;
    return prefs.getString(key);
  }

  Future<int?> getInt(String key) async {
    final prefs = await _instance;
    return prefs.getInt(key);
  }

  Future<bool?> getBool(String key) async {
    final prefs = await _instance;
    return prefs.getBool(key);
  }

  /// Specific Setters/Getters (Optional)
  Future<bool> setAuthToken(String token) =>
      setString(UserPrefKeys.authToken, token);

  Future<String?> getAuthToken() =>
      getString(UserPrefKeys.authToken);

  Future<bool> setUserName(String name) =>
      setString(UserPrefKeys.name, name);

  Future<String?> getUserName() =>
      getString(UserPrefKeys.name);

  Future<bool> setUserEmail(String email) =>
      setString(UserPrefKeys.email, email);

  Future<String?> getUserEmail() =>
      getString(UserPrefKeys.email);

  /// Remove specific key
  Future<bool> remove(String key) async {
    final prefs = await _instance;
    return prefs.remove(key);
  }

  /// Clear all stored data
  Future<bool> clearAllData() async {
    final prefs = await _instance;
    return prefs.clear();
  }
}

class UserPrefKeys {
  static const String authToken = 'access_token';
  static const String tokenExpiry = 'token_expiry';
  static const String name = 'name';
  static const String email = 'email';
}
