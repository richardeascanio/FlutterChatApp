import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:chat_app/global/environment.dart';
import 'package:chat_app/models/login_response.dart';
import 'package:chat_app/models/user.dart';


class AuthService with ChangeNotifier {

  User user;
  bool _authenticating = false;

  bool get authenticating => this._authenticating;
  set authenticating(bool value) {
    this._authenticating = value;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    
    this.authenticating = true;

    final data = {
      'email': email,
      'password': password
    };

    final resp = await http.post('${Environment.apiUrl}/login', 

      body: jsonEncode(data),
      headers: {
        'Content-type': 'application/json'
      }

    );

    print(resp.body);
    this.authenticating = false;
    if (resp.statusCode == 200) {
      final loginResponse = loginResponseFromJson(resp.body);
      this.user = loginResponse.user;
      return true;
    } else {
      return false;
    }

  }

}