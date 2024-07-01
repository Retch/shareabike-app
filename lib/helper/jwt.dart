import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:share_a_bike/services/auth.dart';
import 'package:share_a_bike/enum/api/response.dart';

class JwtHelper {
  static String _token = "";

  static Future<String> getTokenFromStorage() async {
    if (!isTokenValid()) {
      var response = await AuthService.refreshToken();
      if (response['status'] == ApiResponse.success) {
        _token = response['token'];
        return _token;
      }
      return "";
    } else {
      return _token;
    }
  }

  static void setTokenInStorage(token) {
    _token = token;
  }

  static bool isTokenValid() {
    if (_token == "") {
      return false;
    }
    final jwtData = JwtDecoder.decode(_token);
    bool isValid =
        jwtData['exp'] > DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (kDebugMode) {
      print("[JWT] is valid: $isValid");
    }
    return isValid;
  }

  static String getUsername() {
    if (_token == "") {
      return "";
    }
    final jwtData = JwtDecoder.decode(_token);
    return jwtData['username'];
  }
}
