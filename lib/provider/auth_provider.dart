import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _accessToken;
  Map<String, dynamic>? _profile;

  String? get accessToken => _accessToken;
  Map<String, dynamic>? get profile => _profile;

  Future<void> login(String accessToken, Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    _accessToken = accessToken;
    _profile = profile;
    notifyListeners();
  }

  getAccount() {
    return profile;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = null;
    _profile = null;
    await prefs.remove('access_token');
    notifyListeners();
  }
}
