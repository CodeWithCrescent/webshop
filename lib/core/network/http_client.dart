import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HttpClient {
  final SharedPreferences prefs;
  final GlobalKey<NavigatorState> navigatorKey;

  HttpClient({required this.prefs, required this.navigatorKey});

  Future<Map<String, String>> _getHeaders() async {
    final token = prefs.getString('access_token');
    final expiry = prefs.getInt('token_expiry');

    final currentTime = DateTime.now().millisecondsSinceEpoch;

    if (token == null || expiry == null || currentTime >= expiry) {
      // Token expired or missing
      await prefs.remove('access_token');
      await prefs.remove('token_expiry');

      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
        arguments: {'error': 'Session expired. Please log in again.'},
      );

      throw Exception('Session expired. Redirecting to login.');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response?> get(String url) async {
    try {
      final headers = await _getHeaders();
      return await http.get(Uri.parse(url), headers: headers);
    } on SocketException {
      _showSnackBar('No internet connection.');
    } on Exception catch (e) {
      _showSnackBar(e.toString());
    }
    return null;
  }

  Future<http.Response?> post(String url, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      return await http.post(Uri.parse(url), headers: headers, body: jsonEncode(data));
    } on SocketException {
      _showSnackBar('No internet connection.');
    } on Exception catch (e) {
      _showSnackBar(e.toString());
    }
    return null;
  }

  void _showSnackBar(String message) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
