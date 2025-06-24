import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  Future<bool> setAuthToken(String token) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setString(UserPref.authToken.toString(), token);
  }

  Future<String?> getAuthToken() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(UserPref.authToken.toString());
  }

  // Function to remove the Auth Token
  Future<bool> removeAuthToken() async {
    final pref = await SharedPreferences.getInstance();
    return pref.remove(UserPref.authToken.toString());
  }

  // Function to clear all data from SharedPreference
  Future<bool> clearAllData() async {
    final pref = await SharedPreferences.getInstance();
    return pref.clear();
  }
}

enum UserPref {
  authToken,
}
