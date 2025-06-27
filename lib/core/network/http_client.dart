import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HttpClient {
  final SharedPreferences prefs;

  HttpClient({required this.prefs});

  Future<Map<String, String>> _getHeaders() async {
    final token = prefs.getString('access_token');
    final expiry = prefs.getInt('token_expiry');

    final currentTime = DateTime.now().millisecondsSinceEpoch;

    if (token == null || expiry == null || currentTime >= expiry) {
      // Token is missing or expired, clear session
      await prefs.remove('access_token');
      await prefs.remove('token_expiry');
      throw Exception('Session expired. Please log in again.');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String url) async {
    try {
      final headers = await _getHeaders();
      return await http.get(Uri.parse(url), headers: headers);
    } catch (e) {
      // Optionally handle logout or redirection from here
      rethrow;
    }
  }

  Future<http.Response> post(String url, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      return await http.post(Uri.parse(url), headers: headers, body: jsonEncode(data));
    } catch (e) {
      // Optionally handle logout or redirection from here
      rethrow;
    }
  }
}
