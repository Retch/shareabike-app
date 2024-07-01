import 'package:shared_preferences/shared_preferences.dart';

class ServerHelper {
  static String _connectionString = '';

  static Future<String> loadServerConnectionString() async {
    if (_connectionString == '') {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _connectionString = prefs.getString('connectionString') ?? '';
      return _connectionString;
    } else {
      return Future.value(_connectionString);
    }
  }

  static void saveServerConnectionString(connectionString) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('connectionString', connectionString);
  }
}
