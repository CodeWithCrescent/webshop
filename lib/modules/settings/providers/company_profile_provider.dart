import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webshop/core/network/api_endpoints.dart';
import 'package:webshop/core/network/http_client.dart';
import 'package:webshop/modules/settings/models/company_profile.dart';

class CompanyProfileProvider with ChangeNotifier {
  CompanyProfile? _companyProfile;
  bool _isLoading = false;
  String? _error;
  final HttpClient _httpClient;

  CompanyProfileProvider({required HttpClient httpClient}) : _httpClient = httpClient;

  CompanyProfile? get companyProfile => _companyProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCompanyProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _httpClient.get(ApiEndpoints.companyProfile);
      
      if (response!.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _companyProfile = CompanyProfile.fromMap(data);
        _error = null;
      } else {
        throw Exception('Failed to load company profile: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching company profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}