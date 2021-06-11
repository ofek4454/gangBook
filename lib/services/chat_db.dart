import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gangbook/models/chat_model.dart';

class ChatDB {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> sendMessage(String gangId, Message message) async {
    String retVal = 'error';
    try {
      await _firestore.collection('gangs').doc(gangId).collection('chat').add({
        'message': message.message,
        'sender': message.sender.toJson(),
        'createdAt': message.createdAt,
      });
      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }
}
