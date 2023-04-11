import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  List<Message> messages;

  ChatModel(this.messages);

  ChatModel.fromQuerySnapshot(QuerySnapshot chatCollection) {
    final chatDocs = chatCollection.docs;
    this.messages = [];
    chatDocs.forEach((messageData) {
      messages.add(Message.fromDocumentSnapshot(messageData));
    });
  }
}

class Message {
  String id;
  String message;
  MessageSender sender;
  Timestamp createdAt;

  Message({
    this.id,
    this.message,
    this.createdAt,
    this.sender,
  });

  Message.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    this.id = doc.id;
    this.message = data['message'];
    this.sender = MessageSender.fromJson(data['sender']);
    this.createdAt = data['createdAt'];
  }
}

class MessageSender {
  String uid;
  String image;
  String name;

  MessageSender(
    this.uid,
    this.name,
    this.image,
  );

  MessageSender.fromJson(String jsonData) {
    final data = json.decode(jsonData);
    this.uid = data['uid'];
    this.name = data['name'];
    this.image = data['image'];
  }

  String toJson() {
    return json.encode({
      'uid': this.uid,
      'name': this.name,
      'image': this.image,
    });
  }
}
