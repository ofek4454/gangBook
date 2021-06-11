import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gangbook/models/chat_model.dart';
import 'package:gangbook/models/user_model.dart';
import 'package:gangbook/services/chat_db.dart';

class ChatState {
  ChatModel _chat;

  ChatState(this._chat);

  ChatModel get chat => _chat;

  Future<void> sendMessage(String message, UserModel sender) async {
    final _message = Message(
      message: message,
      createdAt: Timestamp.now(),
      sender: MessageSender(
        sender.uid,
        sender.fullName,
        sender.profileImageUrl,
      ),
    );
    try {
      await ChatDB().sendMessage(sender.gangId, _message);
    } catch (e) {
      print(e);
    }
  }
}
