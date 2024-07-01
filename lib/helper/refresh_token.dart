import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RefreshTokenHelper {
  static const storage = FlutterSecureStorage();

  static void setRefreshToken(token) {
    if (kDebugMode) {
      print("[SETTING REFRESH TOKEN]: ${token.substring(0, 5)}...");
    }
    storage.write(key: 'refresh_token', value: token);
  }

  static Future<String> getRefreshToken() async {
    String token = await storage.read(key: 'refresh_token') ?? "";
    if (kDebugMode) {
      if (token.isNotEmpty) {
        print("[GETTING REFRESH TOKEN]: ${token.substring(0, 5)}...");
      } else {
        print("[REFRESH TOKEN EMPTY]");
      }
    }
    return token;
  }

  static void removeRefreshToken() {
    storage.delete(key: 'refresh_token');
  }
}
