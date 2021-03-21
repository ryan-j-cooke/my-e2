import 'dart:convert';
import 'dart:developer';
import 'package:MyE2/pages/models/AppState.dart';
import 'package:http/http.dart' as http;

import 'package:MyE2/utils/Endpoints.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Onboarding {
  static Future login(
    String email,
    String password,
    successCb,
    errorCb,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    print(email);

    print(password);

    try {
      print('doing login');

      final response = await http.post(
        Uri.https(API_HOST, '/identity/authenticate'),
        body: jsonEncode(
          <String, String>{
            'username': email.trim(),
            'password': password.trim(),
          },
        ),
      );

      final json = jsonDecode(response.body) as Map;
      inspect(json);
      if (response.statusCode == 200) {
        await prefs.setString('email', email);

        json.forEach((k, v) async {
          await prefs.setString(k, v);
        });

        print('logged in successfully');

        successCb();
      } else {
        if (json['message'] == 'Authentication failed') {
          errorCb('Username or Password was wrong');
        } else {
          errorCb(json['message']);
        }
      }
    } catch (e) {
      print('PROFILE ERROR: ');
      inspect(e);
      errorCb(e.toString());
    }
  }

  static Future refreshToken(
    AppState appState,
    String refreshToken,
    successCb,
    errorCb,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    print(refreshToken);

    try {
      print('doing login');

      final response = await http.post(
        Uri.https(API_HOST, '/identity/authenticate'),
        body: jsonEncode(
          <String, String>{
            'refresh_token': refreshToken,
          },
        ),
      );

      final json = jsonDecode(response.body) as Map;
      inspect(json);
      if (response.statusCode == 200) {
        json.forEach((k, v) async {
          await prefs.setString(k, v);
        });

        print('refresh successful');

        successCb();
      } else {
        appState.logout();
        errorCb();
      }
    } catch (e) {
      print('PROFILE ERROR: ');
      inspect(e);
      errorCb(e.toString());
    }
  }

  static Future register(
    String email,
    String username,
    String password,
    successCb,
    errorCb,
  ) async {
    try {
      print('doing register');
      final response = await http.post(
        Uri.https(API_HOST, '/identity/register'),
        body: jsonEncode(
          <String, String>{
            'email': email,
            'password': password,
            'username': username,
          },
        ),
      );

      if (response.statusCode == 200) {
        print('Successfully Registered');

        successCb();
      } else {
        if (response.statusCode == 400) {
          String message = response.body.toString();

          print(message);

          if (message == 'User already exists') {
            errorCb('A user already existed with that username');
          } else {
            errorCb('A user already existed with that email');
          }
        } else {
          errorCb(response.body.toString());
        }
      }
    } catch (e) {
      print('PROFILE ERROR: ');
      inspect(e);
      errorCb(e.toString());
    }
  }
}
