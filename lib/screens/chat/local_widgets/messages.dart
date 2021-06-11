import 'package:flutter/material.dart';
import 'package:gangbook/screens/chat/local_widgets/message_bubble.dart';
import 'package:gangbook/state_managment/chat_state.dart';
import 'package:provider/provider.dart';

class Messages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatState>(
      builder: (consumerCtx, chatState, child) {
        if (chatState == null)
          return Center(child: CircularProgressIndicator.adaptive());
        if (chatState.chat.messages.isEmpty) return Container();
        return ListView.builder(
          padding: EdgeInsets.only(top: 20),
          reverse: true,
          itemCount: chatState.chat.messages.length,
          itemBuilder: (lvCtx, i) => MessageBubble(chatState.chat.messages[i]),
        );
      },
    );
  }
}
