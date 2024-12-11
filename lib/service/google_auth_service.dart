import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in_web/web_only.dart';

import '../config/env_variables_config.dart';

import 'package:http/http.dart' as http;

class GoogleAuthService {
  // Method for requesting server authentication code
  Future<String?> requestServerAuthenticatioinCode() async {
    print("entering request server auth code");
    return requestServerAuthCode();
  }

  // methods to manage exchanges with backend
  Future<bool> sendAuthCodeToBackend(String authCode) async {
    print('Entering sendAuthCodeToBackend Future');
    print("Auth Code: $authCode");
    final response = await http.post(
      Uri.parse(Config.backendGoogleCallback),
      body: {
        'code': authCode,
      },
    );
    if (response.statusCode == 200) {
      print('Auth code sent to backend successfully');
      return true;
    } else {
      print('Failed to send Auth code to backend: ${response.statusCode}');
      return false;
    }
  }

  // Future<bool> isGoogleLoggedIn() async {
  //   try {
  //     print('Google Logged Out');
  //     return true;
  //   } catch (e) {
  //     print('Error checking login status: $e');
  //     return false;
  //   }
  // }
}
