import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:share_a_bike/helper/api.dart';
import 'package:share_a_bike/helper/jwt.dart';
import 'package:share_a_bike/helper/refresh_token.dart';
import 'package:share_a_bike/enum/api/response.dart';

class AuthService {
  static const String _loginPath = '/login_check';
  static const String _refreshPath = '/token/refresh';

  // static const String _verifyPath = '/jwt_check';
  static const String _invalidatePath = '/token/invalidate';

  static Future<ApiResponse> loginUser(String username, String password) async {
    Map<String, dynamic> jsonData = {
      'username': username,
      'password': password,
    };

    String jsonString = jsonEncode(jsonData);

    var uri = await ApiHelper.getUri(_loginPath);

    http.Response response = await http.post(
      uri,
      body: jsonString,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      String token = jsonResponse['token'];
      JwtHelper.setTokenInStorage(token);
      String cookieHeader = response.headers['set-cookie'] ?? '';
      String refreshToken =
          ApiHelper.extractRefreshTokenFromCookie(cookieHeader);
      RefreshTokenHelper.setRefreshToken(refreshToken);
      return ApiResponse.success;
    } else if (response.statusCode == 401) {
      return ApiResponse.unauthorized;
    } else {
      return ApiResponse.error;
    }
  }

  static Future<Map<String, dynamic>> refreshToken() async {
    var refreshToken = await RefreshTokenHelper.getRefreshToken();
    var uri = await ApiHelper.getUri(_refreshPath);

    http.Response response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      encoding: Encoding.getByName('utf-8'),
      body: {
        'refresh_token': refreshToken,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      String token = jsonResponse['token'];
      JwtHelper.setTokenInStorage(token);
      String cookieHeader = response.headers['set-cookie'] ?? '';
      String newRefreshToken =
          ApiHelper.extractRefreshTokenFromCookie(cookieHeader);
      RefreshTokenHelper.setRefreshToken(newRefreshToken);
      return {'status': ApiResponse.success, 'token': token};
    } else if (response.statusCode == 401) {
      return {'status': ApiResponse.unauthorized};
    } else {
      return {'status': ApiResponse.error};
    }
  }

  static Future<ApiResponse> logoutUser() async {
    var refresh = await RefreshTokenHelper.getRefreshToken();
    var uri = await ApiHelper.getUri(_invalidatePath);

    var response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'refresh_token=$refresh',
      },
    );

    if (response.statusCode == 200) {
      RefreshTokenHelper.removeRefreshToken();
      if (kDebugMode) {
        print("[INVALIDATED REFRESH TOKEN]");
      }
      return ApiResponse.success;
    } else {
      if (kDebugMode) {
        print("[ERROR INVALIDATING REFRESH TOKEN]");
      }
      return ApiResponse.error;
    }
  }
}
