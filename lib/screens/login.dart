import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:nice_buttons/nice_buttons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_a_bike/services/auth.dart';
import 'package:share_a_bike/enum/api/response.dart';
import 'package:share_a_bike/screens/home.dart';
import 'package:share_a_bike/helper/server.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _serverController = TextEditingController();
  bool _prefilledFields = false;
  bool _isLoginAllowed = false;

  void _checkInputsValid() {
    if (_isUsernameValid() && _isPasswordValid() && _isServerValid()) {
      setState(() {
        _isLoginAllowed = true;
      });
    } else {
      setState(() {
        _isLoginAllowed = false;
      });
    }
  }

  bool _isUsernameValid() {
    if (_usernameController.text.isNotEmpty) {
      return true;
    }
    return false;
  }

  bool _isPasswordValid() {
    if (_passwordController.text.isNotEmpty) {
      return true;
    }
    return false;
  }

  bool _isServerValid() {
    if (_serverController.text.isNotEmpty) {
      return true;
    }
    return false;
  }

  void _persistServerConnectionString() {
    ServerHelper.saveServerConnectionString(_serverController.text);
  }

  @override
  Widget build(BuildContext context) {
    _usernameController.addListener(_checkInputsValid);
    _passwordController.addListener(_checkInputsValid);
    _serverController.addListener(_checkInputsValid);

    ServerHelper.loadServerConnectionString().then((value) {
      if (value != _serverController.text &&
          value.isNotEmpty &&
          !_prefilledFields) {
        _serverController.text = value;
        _prefilledFields = true;
        if (kDebugMode) {
          print(
              "[LoginScreen] pre-filled server connection string, length: ${value.length}");
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('log_in', style: TextStyle(fontSize: 28)).tr(),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'email'.tr()),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'password'.tr()),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _serverController,
              decoration: InputDecoration(labelText: 'server'.tr()),
              autocorrect: false,
            ),
            const SizedBox(height: 32.0),
            NiceButtons(
              stretch: true,
              startColor: _isLoginAllowed
                  ? Theme.of(context).primaryColor
                  : Colors.grey[500]!,
              endColor:
                  _isLoginAllowed ? const Color(0xFF529fff) : Colors.grey[400]!,
              borderColor: _isLoginAllowed
                  ? Theme.of(context).primaryColor
                  : Colors.grey[500]!,
              disabled: !_isLoginAllowed,
              progress: true,
              gradientOrientation: GradientOrientation.Horizontal,
              onTap: (finish) {
                Timer(const Duration(milliseconds: 250), () {
                  _persistServerConnectionString();
                  _performLogin().then((value) {
                    switch (value) {
                      case ApiResponse.success:
                        Timer(const Duration(milliseconds: 1600), () {
                          finish();
                          Timer(const Duration(milliseconds: 250), () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomeScreen()),
                            );
                          });
                        });
                        break;
                      case ApiResponse.unauthorized:
                        Timer(const Duration(milliseconds: 1600), () {
                          finish();
                          _showMessage('error.credentials'.tr());
                        });
                        break;
                      default:
                        Timer(const Duration(milliseconds: 1600), () {
                          finish();
                          _showMessage('error.unknown'.tr());
                        });
                        break;
                    }
                  });
                });
              },
              child: const Text(
                'log_in',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ).tr(),
            ),
          ],
        ),
      ),
    );
  }

  Future<ApiResponse> _performLogin() {
    String username = _usernameController.text;
    String password = _passwordController.text;
    var completer = Completer<ApiResponse>();

    AuthService.loginUser(username, password).then((res) => {
          if (res == ApiResponse.success)
            {
              completer.complete(ApiResponse.success),
            }
          else if (res == ApiResponse.unauthorized)
            {completer.complete(ApiResponse.unauthorized)}
          else
            {completer.complete(ApiResponse.error)}
        });

    return completer.future;
  }

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('error.label').tr(),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
