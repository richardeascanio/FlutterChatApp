import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/services/socket_service.dart';
import 'package:chat_app/services/auth_service.dart';

import 'package:chat_app/models/message.dart';

import 'package:chat_app/widgets/chat_message.dart';

class ChatPage extends StatefulWidget {

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {

  final _textCrtl = new TextEditingController();
  final _focusNode = new FocusNode();

  ChatService chatService;
  SocketService socketService;
  AuthService authService;

  List<ChatMessage> _messages = [];

  bool _isWriting = false;

  @override
  void initState() { 
    super.initState();
    this.chatService = Provider.of<ChatService>(context, listen: false);
    this.socketService = Provider.of<SocketService>(context, listen: false);
    this.authService = Provider.of<AuthService>(context, listen: false);

    this.socketService.socket.on('personal-message', _listenMessage);

    _loadChat(this.chatService.userTo.uid);
  }

  void _loadChat(String userId) async {

    List<Message> chat = await this.chatService.getChat(userId);
    
    final history = chat.map((m) => new ChatMessage(
      text: m.message,
      uid: m.from,
      animationController: AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 0)
      )..forward(),
    ));

    setState(() {
      
      _messages.insertAll(0, history);

    });

  }

  void _listenMessage(dynamic payload) {

    ChatMessage message = new ChatMessage(
      text: payload['message'],
      uid: payload['from'],
      animationController: AnimationController(vsync: this, duration: Duration(milliseconds: 300)),
    );
    setState(() {
      _messages.insert(0, message);
    });

    message.animationController.forward();

  }

  @override
  Widget build(BuildContext context) {

    final user = chatService.userTo;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Column(
          children: [
            CircleAvatar(
              child: Text(user.name.substring(0,2).toUpperCase(), style: TextStyle(fontSize: 12),),
              backgroundColor: Colors.blue[100],
              maxRadius: 14,
            ),
            SizedBox(height: 3,),
            Text(user.name, style: TextStyle(color: Colors.black87, fontSize: 12),)
          ],
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: Container(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (BuildContext context, int index) {
                  return _messages[index];
                },
              ),
            ),
            Divider(
              height: 1,
            ),
            Container(
              // TODO: CAJA DE TEXTO
              color: Colors.white,
              child: _inputChat(),
            )
          ],
        ),
      ),
    );
  }

  Widget _inputChat() {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[

            Flexible(
              child: TextField(
                controller: _textCrtl,
                onSubmitted: _isWriting ?
                  (text) => _handleSubmit(text) :
                  null,
                onChanged: (String text) {
                  setState(() { 
                    if (text.trim().length > 0) {
                      _isWriting = true;
                    } else {
                      _isWriting = false;
                    }
                  });
                },
                decoration: InputDecoration.collapsed(
                  hintText: 'Enviar mensaje' 
                ),
                focusNode: _focusNode,
              ),
            ),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: Platform.isIOS ?
              CupertinoButton(
                child: Text('Enviar'),
                onPressed: _isWriting ?
                  () => _handleSubmit(_textCrtl.text) :
                  null,
              ) :
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                child: IconTheme(
                  data: IconThemeData(
                    color: Colors.blue[400]
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.send
                    ),
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onPressed: _isWriting ?
                      () => _handleSubmit(_textCrtl.text) :
                      null,
                  ),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }

  _handleSubmit(String text) {
    
    _focusNode.requestFocus();
    _textCrtl.clear();

    final newMessage = new ChatMessage(
      uid: authService.user.uid, 
      text: text, 
      animationController: AnimationController(
        vsync: this, 
        duration: Duration(milliseconds: 200)
      ),
    );
    _messages.insert(0, newMessage);
    newMessage.animationController.forward();

    setState(() {
      _isWriting = false;
    });

    this.socketService.emit('personal-message', {

      'from': this.authService.user.uid,
      'to': this.chatService.userTo.uid,
      'message': text

    });
  }

  @override
  void dispose() {
    for (ChatMessage message in _messages) {
      message.animationController.dispose();
    }

    this.socketService.socket.off('personal-message');

    super.dispose();
  }
}