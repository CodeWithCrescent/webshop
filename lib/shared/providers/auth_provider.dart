import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_endpoints.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  late SharedPreferences _prefs;

  AuthProvider() {
    _initialize();
  }

  void setError(String error) {
    _error = error;
    notifyListeners();
  }

  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();

    final token = _prefs.getString('access_token');
    final expiry = _prefs.getInt('token_expiry');
    final now = DateTime.now().millisecondsSinceEpoch;

    if (token != null && expiry != null && now < expiry) {
      _isAuthenticated = true;
    } else {
      _isAuthenticated = false;
      await _prefs.remove('access_token');
      await _prefs.remove('token_expiry');
    }

    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final url = Uri.parse(ApiEndpoints.login);

    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    final body = {
      'client_id': username,
      'client_secret': password,
    };

    try {
      final response = await http.post(url, headers: headers, body: body);
      final data = jsonDecode(response.body);

      if (data.containsKey('success') && data['success'] == false) {
        _error = data['message'] ?? 'Invalid credentials.';
        _isAuthenticated = false;
      } else if (data.containsKey('access_token')) {
        final expiresIn = int.tryParse(data['expires_in'].toString()) ?? 0;
        final expiryTimestamp = DateTime.now()
            .add(Duration(seconds: expiresIn))
            .millisecondsSinceEpoch;

        await _prefs.setString('access_token', data['access_token']);
        await _prefs.setInt('token_expiry', expiryTimestamp);
        await _prefs.setString('name', data['name'] ?? '');
        await _prefs.setString('email', data['email'] ?? '');

        _isAuthenticated = true;
      } else {
        _error = 'Unexpected response from server.';
        _isAuthenticated = false;
      }
    } catch (e) {
      _error = '$e';
      _isAuthenticated = false;
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
    _isLoading = false;

    notifyListeners();
  }
}
