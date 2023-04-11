import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;
  String email;
  String fullName;
  Timestamp createdAt;
  String gangId;
  List<String> savedPosts;
  String profileImageUrl;
  String gangJoinRequest;

  UserModel(
      {this.uid,
      this.email,
      this.fullName,
      this.createdAt,
      this.gangId,
      this.savedPosts,
      this.profileImageUrl,
      this.gangJoinRequest});

  UserModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    this.uid = doc.id;
    this.email = data['email'];
    this.fullName = data['fullname'];
    this.createdAt = data['createdAt'];
    this.gangId = data['gangId'];
    this.savedPosts = List<String>.from(data['savedPosts'] ?? []);
    this.profileImageUrl = data['profileImageUrl'];
    this.gangJoinRequest = data['gangJoinRequest'];
  }

  String nameAndIdJson() {
    return json.encode({
      'name': this.fullName,
      'uid': this.uid,
    });
  }
}
