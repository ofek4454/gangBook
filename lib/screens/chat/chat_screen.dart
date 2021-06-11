import 'package:flutter/material.dart';
import 'package:gangbook/screens/chat/local_widgets/message_field.dart';
import 'package:gangbook/screens/chat/local_widgets/messages.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gang chat'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: Messages(),
          ),
          MessageField(),
        ],
      ),
    );
  }
}
