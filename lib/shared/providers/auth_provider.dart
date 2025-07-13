import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:webshop/core/network/api_endpoints.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  late SharedPreferences _prefs;
  Function()? _onLoginSuccess;
  Function()? _onLogout;

  AuthProvider() {
    _initialize();
  }

  void setCallbacks({
    required Function() onLoginSuccess,
    required Function() onLogout,
  }) {
    _onLoginSuccess = onLoginSuccess;
    _onLogout = onLogout;
  }

  void setError(String error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await checkAuthStatus();
  }

  /// Check if the token is still valid
  Future<void> checkAuthStatus() async {
    final token = _prefs.getString('access_token');
    final expiry = _prefs.getInt('token_expiry');
    final now = DateTime.now().millisecondsSinceEpoch;

    final wasAuthenticated = _isAuthenticated;
    _isAuthenticated = token != null && expiry != null && now < expiry;

    if (wasAuthenticated != _isAuthenticated) {
      notifyListeners();
    }
  }

  Future<void> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final url = Uri.parse(ApiEndpoints.login);
    final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    final body = {'client_id': username, 'client_secret': password};

    try {
      final response = await http.post(url, headers: headers, body: body);
      final data = jsonDecode(response.body);

      if (data.containsKey('success') && data['success'] == false) {
        _error = data['message'] ?? 'Invalid credentials.';
      } else if (data.containsKey('access_token')) {
        // final expiresIn = int.tryParse(data['expires_in'].toString()) ?? 0;
        final expiresIn = int.tryParse("30") ?? 0;
        final expiryTimestamp = DateTime.now()
            .add(Duration(seconds: expiresIn))
            .millisecondsSinceEpoch;

        await _prefs.setString('access_token', data['access_token']);
        await _prefs.setInt('token_expiry', expiryTimestamp);
        await _prefs.setString('name', data['name'] ?? '');
        await _prefs.setString('email', data['email'] ?? '');
        _isAuthenticated = true;

        if (_onLoginSuccess != null) {
          await _onLoginSuccess!();
        }
      }
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _prefs.remove('access_token');
    await _prefs.remove('token_expiry');
    await _prefs.remove('name');
    await _prefs.remove('email');
    _isAuthenticated = false;

    if (_onLogout != null) {
      await _onLogout!();
    }

    _isLoading = false;
    notifyListeners();
  }
}
