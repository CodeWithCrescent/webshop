import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HttpClient {
  final SharedPreferences prefs;
  final GlobalKey<NavigatorState> navigatorKey;
  bool _isRedirecting = false;

  HttpClient({required this.prefs, required this.navigatorKey});

  Future<Map<String, String>> _getHeaders() async {
    final token = prefs.getString('access_token');
    final expiry = prefs.getInt('token_expiry');
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    if (token == null || expiry == null || currentTime >= expiry) {
      if (!_isRedirecting) {
        _isRedirecting = true;
        await _handleSessionExpired(message: 'Your session has expired. Please log in again.');
      }
      throw Exception('Session expired');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> _handleSessionExpired({required String message}) async {
    // Clear all auth-related data
    await prefs.remove('access_token');
    await prefs.remove('token_expiry');
    await prefs.remove('user_data');

    // Navigate to login page with message
    if (navigatorKey.currentState?.mounted ?? false) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
        arguments: {
          'message': message,
          'messageType': 'error'
        },
      );
    }
  }

  Future<http.Response?> _handleResponse(http.Response response) async {
    try {
      // Check for token errors in response body
      final body = json.decode(response.body);
      if (body is Map && body.containsKey('ACCESS_TOKEN_ERRORS')) {
        final error = body['ACCESS_TOKEN_ERRORS'].toString();
        if (error == 'Expired token') {
          await _handleSessionExpired(message: 'Your session has expired. Please log in again.');
        } else {
          await _handleSessionExpired(message: 'Unexpected error occurred. Please log in again.');
        }
        return null;
      }
      return response;
    } catch (e) {
      return response; // Return original response if parsing fails
    }
  }

  Future<http.Response?> get(String url) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);
      return await _handleResponse(response);
    } on SocketException {
      _showSnackBar('No internet connection.');
    } on Exception catch (e) {
      if (e.toString().contains('Session expired')) {
        // Already handled in _handleSessionExpired
        return null;
      }
      _showSnackBar(e.toString());
    }
    return null;
  }

  Future<http.Response?> post(String url, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      );
      return await _handleResponse(response);
    } on SocketException {
      _showSnackBar('No internet connection.');
    } on Exception catch (e) {
      if (e.toString().contains('Session expired')) {
        // Already handled in _handleSessionExpired
        return null;
      }
      _showSnackBar(e.toString());
    }
    return null;
  }

  void _showSnackBar(String message) {
    final context = navigatorKey.currentContext;
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}