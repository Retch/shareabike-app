import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_a_bike/enum/api/response.dart';
import 'package:share_a_bike/screens/home.dart';
import 'package:share_a_bike/screens/login.dart';
import 'package:share_a_bike/screens/splash.dart';
import 'package:share_a_bike/helper/server.dart';
import 'package:share_a_bike/helper/refresh_token.dart';
import 'package:share_a_bike/services/auth.dart';
import 'package:share_a_bike/services/location.dart';

class AppBootstrap extends StatelessWidget {
  const AppBootstrap({Key? key}) : super(key: key);

  void _openLoginScreen(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    RefreshTokenHelper.getRefreshToken().then((token) {
      ServerHelper.loadServerConnectionString().then((connectionString) {
        if (kDebugMode) {
          print("[SERVER CONNECTION STRING] $connectionString");
          print("[REFRESH TOKEN] length: ${token.length}");
        }
        if (token != "" && connectionString != "") {
          AuthService.refreshToken().then((response) {
            if (response['status'] == ApiResponse.success) {
              LocationService.getCurrentLocationAndUpdateMapCenter();
              Timer(const Duration(seconds: 1), () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              });
            } else {
              if (response['status'] == ApiResponse.unauthorized) {
                RefreshTokenHelper.removeRefreshToken();
              }
              _openLoginScreen(context);
            }
          });
        } else {
          _openLoginScreen(context);
        }
      });
    });
    return const SplashScreen();
  }
}
