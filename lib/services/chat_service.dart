import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:chat_app/global/environment.dart';
import 'package:chat_app/services/auth_service.dart';

import 'package:chat_app/models/user.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/messages_response.dart';

class ChatService with ChangeNotifier {

  User userTo;

  Future<List<Message>> getChat(String userId) async {

    final resp = await http.get('${Environment.apiUrl}/messages/$userId',

      headers: {
        'Content-Type': 'application/json',
        'x-token': await AuthService.getToken()
      }

    );

    final messagesResponse = messagesResponseFromJson(resp.body);

    return messagesResponse.messages;

  }

}