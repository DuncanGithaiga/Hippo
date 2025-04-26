import 'package:hippo/services/authapi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  final storage = FlutterSecureStorage();
  bool _isLoggedIn = false;
  bool _isLoading = true;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _checkTokenValidity();
  }

  Future<void> _checkTokenValidity() async {
    bool isValid = await _isTokenValid();
    _isLoggedIn = isValid;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    bool success = await AuthApi().logout();
    if (success) {
      _isLoggedIn = false;
      notifyListeners();
    }
  }

  Future<bool> _isTokenValid() async {
    final token = await storage.read(key: 'token');
    final userId = await storage.read(key: 'user_id');
    print('Token: $token');
    print('User ID: $userId');

    if (token == null || userId == null) {
      return false;
    }

    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:8000/api/auth/checkToken"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
          'User-Id': userId, // Add the user ID to the headers
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        return responseBody['status'] == 'success';
      } else {
        return false;
      }
    } catch (e) {
      print('Error checking token validity: $e');
      return false;
    }
  }
}
