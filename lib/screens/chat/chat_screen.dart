import 'package:flutter/material.dart';
import 'package:gangbook/screens/chat/local_widgets/message_field.dart';
import 'package:gangbook/screens/chat/local_widgets/messages.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        title: Text(
          'Gang chat',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Messages(),
            ),
            MessageField(),
          ],
        ),
      ),
    );
  }
}
