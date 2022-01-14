import 'package:flutter/material.dart';

import 'ai_color.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Chat Page', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),);
  }
}
