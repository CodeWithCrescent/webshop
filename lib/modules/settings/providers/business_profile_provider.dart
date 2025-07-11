import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:webshop/core/network/api_endpoints.dart';
import 'package:webshop/core/network/http_client.dart';
import 'package:webshop/modules/settings/data/local/business_profile_local_data_source.dart';
import 'package:webshop/modules/settings/models/business_profile.dart';

class BusinessProfileProvider with ChangeNotifier {
  BusinessProfile? _businessProfile;
  bool _isLoading = false;
  String? _error;
  final HttpClient _httpClient;
  final BusinessProfileLocalDataSource _localDataSource;

  BusinessProfile? get businessProfile => _businessProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  BusinessProfileProvider({
    required HttpClient httpClient,
    required BusinessProfileLocalDataSource localDataSource,
  })  : _httpClient = httpClient,
        _localDataSource = localDataSource;

  Future<void> fetchBusinessProfile() async {
    // First try local cache
    _businessProfile = await _localDataSource.getBusinessProfile();
    if (_businessProfile != null) notifyListeners();

    // Then fetch from API
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _httpClient.get(ApiEndpoints.businessProfile);
      if (response!.statusCode == 200) {
        final data = json.decode(response.body);
        _businessProfile = BusinessProfile.fromMap(data);
        await _localDataSource.saveBusinessProfile(_businessProfile!);
        _error = null;
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching business profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearProfile() async {
    await _localDataSource.deleteBusinessProfile();
    _businessProfile = null;
    notifyListeners();
  }
}
