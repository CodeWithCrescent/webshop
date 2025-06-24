import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HttpClient {
  final SharedPreferences prefs;

  HttpClient({required this.prefs});

  Future<Map<String, String>> _getHeaders() async {
    final token = prefs.getString('access_token');

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String url) async {
    final headers = await _getHeaders();
    return http.get(Uri.parse(url), headers: headers);
  }

  Future<http.Response> post(String url, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    return http.post(Uri.parse(url), headers: headers, body: jsonEncode(data));
  }
}
