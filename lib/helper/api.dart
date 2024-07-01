import 'package:share_a_bike/helper/server.dart';

class ApiHelper {
  static Future<Uri> getUri(String path) {
    return ServerHelper.loadServerConnectionString().then((connectionString) {
      return _buildUri(connectionString, path);
    });
  }

  static Uri _buildUri(String conn, String path) {
    return Uri.parse("$conn/api$path");
  }

  static String extractRefreshTokenFromCookie(String cookieHeader) {
    List<String> cookies = cookieHeader.split(';');
    String refreshToken = '';

    for (String cookie in cookies) {
      if (cookie.trim().startsWith('refresh_token=')) {
        refreshToken = cookie.trim().substring('refresh_token='.length);
        break;
      }
    }
    return refreshToken;
  }
}
